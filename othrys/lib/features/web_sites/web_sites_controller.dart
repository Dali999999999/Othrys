import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/web_site_entity.dart';
import '../../core/network/is_ssh_session_manager.dart';
import '../../core/security/command_sanitizer.dart';
import '../../core/services/activity_service.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/result.dart';
import '../servers/server_controller.dart';

export '../../core/models/web_site_entity.dart';

/// State representation for remote web sites and Nginx configuration.
class WebSitesState {
  final bool isNginxInstalled;
  final bool isCertbotInstalled;
  final List<WebSiteEntity> sites;
  final bool isLoading;
  final String? error;
  final Set<String> pendingDomains;

  const WebSitesState({
    this.isNginxInstalled = false,
    this.isCertbotInstalled = false,
    this.sites = const [],
    this.isLoading = false,
    this.error,
    this.pendingDomains = const {},
  });

  WebSitesState copyWith({
    bool? isNginxInstalled,
    bool? isCertbotInstalled,
    List<WebSiteEntity>? sites,
    bool? isLoading,
    String? error,
    Set<String>? pendingDomains,
  }) {
    return WebSitesState(
      isNginxInstalled: isNginxInstalled ?? this.isNginxInstalled,
      isCertbotInstalled: isCertbotInstalled ?? this.isCertbotInstalled,
      sites: sites ?? this.sites,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      pendingDomains: pendingDomains ?? this.pendingDomains,
    );
  }
}

/// Controller orchestrating Nginx virtual hosts, reverse proxies, and Certbot SSL certificates.
class WebSitesController extends StateNotifier<WebSitesState> {
  final ISSHSessionManager sshManager;
  final ActivityService? activityService;

  WebSitesController({
    required this.sshManager,
    this.activityService,
  }) : super(const WebSitesState());

  /// Checks whether Nginx and Certbot are installed on the remote VPS.
  Future<void> probeNginx(String sessionId) async {
    bool hasNginx = false;
    bool hasCertbot = false;

    try {
      final out = await sshManager.executeCommand(sessionId, 'which nginx 2>/dev/null || true');
      hasNginx = out.trim().isNotEmpty;
    } catch (e) {
      AppLogger.instance.warn('WebSitesController', 'Could not probe nginx: $e');
    }

    try {
      final out = await sshManager.executeCommand(sessionId, 'which certbot 2>/dev/null || true');
      hasCertbot = out.trim().isNotEmpty;
    } catch (e) {
      AppLogger.instance.warn('WebSitesController', 'Could not probe certbot: $e');
    }

    state = state.copyWith(isNginxInstalled: hasNginx, isCertbotInstalled: hasCertbot);
  }

  /// Installs Nginx on Debian/Ubuntu systems.
  Future<Result<void>> installNginx(String sessionId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await sshManager.executeSafeCommand(
        sessionId,
        'sudo',
        ['apt-get', 'update'],
      );
      await sshManager.executeSafeCommand(
        sessionId,
        'sudo',
        ['apt-get', 'install', '-y', 'nginx'],
      );
      await probeNginx(sessionId);
      await loadSites(sessionId);
      state = state.copyWith(isLoading: false);
      return const Success(null);
    } catch (e, st) {
      final msg = 'Failed to install Nginx: $e';
      AppLogger.instance.error('WebSitesController', msg, e, st);
      state = state.copyWith(isLoading: false, error: msg);
      return Failure(msg, e, st);
    }
  }

  /// Refreshes Nginx virtual hosts list.
  Future<Result<List<WebSiteEntity>>> loadSites(String sessionId, {bool isSilent = false}) async {
    if (!isSilent) {
      state = state.copyWith(isLoading: state.sites.isEmpty, error: null);
    }
    try {
      await probeNginx(sessionId);
      if (!state.isNginxInstalled) {
        state = state.copyWith(isLoading: false, sites: []);
        return const Success([]);
      }

      final out = await sshManager.executeCommand(
        sessionId,
        'ls -1 /etc/nginx/sites-available/ 2>/dev/null || true',
      );

      final files = out
          .trim()
          .split('\n')
          .map((f) => f.trim())
          .where((f) => f.isNotEmpty && f != 'default')
          .toList();

      final List<WebSiteEntity> result = [];

      for (final file in files) {
        bool isEnabled = false;
        final escapedFile = CommandSanitizer.escapeArg(file);
        try {
          final symlinkCheck = await sshManager.executeCommand(
            sessionId,
            'test -L /etc/nginx/sites-enabled/$escapedFile && echo "YES" || true',
          );
          isEnabled = symlinkCheck.trim() == 'YES';
        } catch (e) {
          AppLogger.instance.warn('WebSitesController', 'Could not check symlink for $file: $e');
        }

        String content = '';
        try {
          content = await sshManager.executeCommand(
            sessionId,
            'cat /etc/nginx/sites-available/$escapedFile 2>/dev/null || true',
          );
        } catch (e) {
          AppLogger.instance.warn('WebSitesController', 'Could not read content for $file: $e');
        }

        final isSsl = content.contains('ssl_certificate');
        final isProxy = content.contains('proxy_pass');

        String target = '';
        if (isProxy) {
          final match = RegExp(r'proxy_pass\s+([^;]+);').firstMatch(content);
          target = match?.group(1)?.trim() ?? '';
        } else {
          final match = RegExp(r'root\s+([^;]+);').firstMatch(content);
          target = match?.group(1)?.trim() ?? '';
        }

        result.add(WebSiteEntity(
          domain: file.endsWith('.conf') ? file.substring(0, file.length - 5) : file,
          type: isProxy ? WebSiteType.reverseProxy : WebSiteType.staticSite,
          target: target,
          isEnabled: isEnabled,
          hasSsl: isSsl,
          configFile: '/etc/nginx/sites-available/$file',
        ));
      }

      state = state.copyWith(sites: result, isLoading: false);
      return Success(result);
    } catch (e, st) {
      final msg = 'Failed to load websites: $e';
      AppLogger.instance.error('WebSitesController', msg, e, st);
      state = state.copyWith(isLoading: false, error: msg);
      return Failure(msg, e, st);
    }
  }

  /// Generates configuration for reverse proxy or static website.
  static String generateNginxConfig(WebSiteEntity site) {
    if (site.type == WebSiteType.reverseProxy) {
      final passTarget = site.target.startsWith('http')
          ? site.target
          : 'http://127.0.0.1:${site.target.replaceAll(RegExp(r'[^0-9]'), '')}';

      return '''
server {
    listen 80;
    listen [::]:80;
    server_name ${site.domain};

    location / {
        proxy_pass $passTarget;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
''';
    } else {
      return '''
server {
    listen 80;
    listen [::]:80;
    server_name ${site.domain};
    root ${site.target};
    index index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.html;
    }
}
''';
    }
  }

  /// Creates a new Nginx website configuration and optionally provisions SSL.
  Future<Result<void>> createSite(
    String sessionId,
    WebSiteEntity site, {
    bool enableSsl = false,
    String? sslEmail,
    ServerEntity? server,
  }) async {
    try {
      if (!CommandSanitizer.isValidHostname(site.domain)) {
        return Failure('Invalid domain name: "${site.domain}"');
      }
      final sanitizedDomain = site.domain.trim();
      final configFile = '/etc/nginx/sites-available/$sanitizedDomain';
      final configContent = generateNginxConfig(site);

      final escaped = configContent.replaceAll("'", "'\\''");
      await sshManager.executeSafeCommand(
        sessionId,
        'sudo',
        ['bash', '-c', "echo '$escaped' > $configFile && chmod 644 $configFile"],
      );

      await sshManager.executeSafeCommand(
        sessionId,
        'sudo',
        ['ln', '-sf', configFile, '/etc/nginx/sites-enabled/'],
      );

      await sshManager.executeSafeCommand(
        sessionId,
        'sudo',
        ['nginx', '-t'],
      );

      await sshManager.executeSafeCommand(
        sessionId,
        'sudo',
        ['systemctl', 'reload', 'nginx'],
      );

      if (server != null) {
        activityService?.logCustomAction(server, 'Created site ${site.domain} (${site.type.label})');
      }

      if (enableSsl && sslEmail != null && sslEmail.isNotEmpty) {
        await provisionSsl(sessionId, site.domain, sslEmail, server: server);
      }

      await loadSites(sessionId);
      return const Success(null);
    } catch (e, st) {
      final msg = 'Failed to create site ${site.domain}: $e';
      AppLogger.instance.error('WebSitesController', msg, e, st);
      return Failure(msg, e, st);
    }
  }

  /// Toggles site enabled/disabled state via symlink in /etc/nginx/sites-enabled/.
  Future<Result<void>> toggleSite(
    String sessionId,
    WebSiteEntity site,
    bool enable, {
    ServerEntity? server,
  }) async {
    final domain = site.domain;
    final previousSites = state.sites;

    // Optimistic UI update: flip immediately
    final updatedSites = state.sites.map((s) {
      if (s.domain == domain) {
        return s.copyWith(isEnabled: enable);
      }
      return s;
    }).toList();

    state = state.copyWith(
      sites: updatedSites,
      pendingDomains: {...state.pendingDomains, domain},
      error: null,
    );

    try {
      if (enable) {
        await sshManager.executeSafeCommand(
          sessionId,
          'sudo',
          ['ln', '-sf', '/etc/nginx/sites-available/$domain', '/etc/nginx/sites-enabled/$domain'],
        );
      } else {
        await sshManager.executeSafeCommand(
          sessionId,
          'sudo',
          ['rm', '-f', '/etc/nginx/sites-enabled/$domain'],
        );
      }

      await sshManager.executeSafeCommand(sessionId, 'sudo', ['nginx', '-t']);
      await sshManager.executeSafeCommand(sessionId, 'sudo', ['systemctl', 'reload', 'nginx']);

      if (server != null) {
        activityService?.logCustomAction(server, '${enable ? "Enabled" : "Disabled"} site $domain');
      }

      state = state.copyWith(
        pendingDomains: Set<String>.from(state.pendingDomains)..remove(domain),
      );
      return const Success(null);
    } catch (e, st) {
      final msg = 'Failed to toggle site ${site.domain}: $e';
      AppLogger.instance.error('WebSitesController', msg, e, st);
      // Roll back optimistic update on failure
      state = state.copyWith(
        sites: previousSites,
        pendingDomains: Set<String>.from(state.pendingDomains)..remove(domain),
        error: msg,
      );
      return Failure(msg, e, st);
    }
  }

  /// Deletes a website configuration file and its enabled symlink.
  Future<Result<void>> deleteSite(
    String sessionId,
    WebSiteEntity site, {
    ServerEntity? server,
  }) async {
    final domain = site.domain;
    final previousSites = state.sites;

    // Optimistic removal: remove immediately from list
    state = state.copyWith(
      sites: state.sites.where((s) => s.domain != domain).toList(),
      error: null,
    );

    try {
      await sshManager.executeSafeCommand(sessionId, 'sudo', ['rm', '-f', '/etc/nginx/sites-enabled/$domain']);
      await sshManager.executeSafeCommand(sessionId, 'sudo', ['rm', '-f', '/etc/nginx/sites-available/$domain']);
      await sshManager.executeSafeCommand(sessionId, 'sudo', ['systemctl', 'reload', 'nginx']);

      if (server != null) {
        activityService?.logCustomAction(server, 'Deleted site $domain');
      }

      return const Success(null);
    } catch (e, st) {
      final msg = 'Failed to delete site ${site.domain}: $e';
      AppLogger.instance.error('WebSitesController', msg, e, st);
      state = state.copyWith(sites: previousSites, error: msg);
      return Failure(msg, e, st);
    }
  }

  /// Provisions Let's Encrypt SSL certificate via Certbot for a given domain.
  Future<Result<void>> provisionSsl(
    String sessionId,
    String domain,
    String email, {
    ServerEntity? server,
  }) async {
    state = state.copyWith(
      pendingDomains: {...state.pendingDomains, domain},
      error: null,
    );
    try {
      if (!state.isCertbotInstalled) {
        await sshManager.executeSafeCommand(
          sessionId,
          'sudo',
          ['apt-get', 'install', '-y', 'certbot', 'python3-certbot-nginx'],
        );
        state = state.copyWith(isCertbotInstalled: true);
      }

      await sshManager.executeSafeCommand(
        sessionId,
        'sudo',
        [
          'certbot',
          '--nginx',
          '-d',
          domain,
          '--non-interactive',
          '--agree-tos',
          '--redirect',
          '-m',
          email,
        ],
      );

      if (server != null) {
        activityService?.logCustomAction(server, 'Provisioned SSL certificate for $domain');
      }

      final updated = state.sites.map((s) => s.domain == domain ? s.copyWith(hasSsl: true) : s).toList();
      state = state.copyWith(
        sites: updated,
        pendingDomains: Set<String>.from(state.pendingDomains)..remove(domain),
      );
      // Silently refresh site details in background
      await loadSites(sessionId, isSilent: true);
      return const Success(null);
    } catch (e, st) {
      final msg = 'Failed to provision SSL for $domain: $e';
      AppLogger.instance.error('WebSitesController', msg, e, st);
      state = state.copyWith(
        pendingDomains: Set<String>.from(state.pendingDomains)..remove(domain),
        error: msg,
      );
      return Failure(msg, e, st);
    }
  }

  /// Tests SSL renewal for installed certificates.
  Future<Result<String>> testSslRenewal(String sessionId) async {
    try {
      final out = await sshManager.executeSafeCommand(
        sessionId,
        'sudo',
        ['certbot', 'renew', '--dry-run'],
      );
      return Success(out);
    } catch (e, st) {
      final msg = 'SSL renewal test failed: $e';
      AppLogger.instance.error('WebSitesController', msg, e, st);
      return Failure(msg, e, st);
    }
  }
}

/// Riverpod provider for WebSitesController.
final webSitesControllerProvider =
    StateNotifierProvider.autoDispose<WebSitesController, WebSitesState>((ref) {
  return WebSitesController(
    sshManager: ref.watch(sshSessionManagerProvider),
    activityService: ref.watch(activityServiceProvider),
  );
});
