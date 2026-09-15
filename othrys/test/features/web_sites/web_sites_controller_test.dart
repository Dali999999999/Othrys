import 'package:flutter_test/flutter_test.dart';
import 'package:othrys/core/network/ssh_session_manager.dart';
import 'package:othrys/core/utils/result.dart';
import 'package:othrys/features/web_sites/web_sites_controller.dart';

class _MockSSHSessionManager extends Fake implements SSHSessionManager {
  final List<String> executedCommands = [];
  String nextCommandOutput = '';

  @override
  Future<String> executeCommand(
    String sessionId,
    String command, {
    Duration timeout = const Duration(seconds: 15),
  }) async {
    executedCommands.add(command);
    return nextCommandOutput;
  }

  @override
  Future<String> executeSafeCommand(
    String sessionId,
    String baseCommand,
    List<String> arguments, {
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final full = '$baseCommand ${arguments.join(' ')}';
    executedCommands.add(full);
    return '';
  }
}

void main() {
  group('WebSitesController.generateNginxConfig', () {
    test('generates valid Reverse Proxy configuration with WebSocket headers', () {
      const site = WebSiteEntity(
        domain: 'api.example.com',
        type: WebSiteType.reverseProxy,
        target: '3000',
      );

      final conf = WebSitesController.generateNginxConfig(site);

      expect(conf, contains('server_name api.example.com;'));
      expect(conf, contains('proxy_pass http://127.0.0.1:3000;'));
      expect(conf, contains('proxy_set_header Upgrade \$http_upgrade;'));
      expect(conf, contains('proxy_set_header Connection "upgrade";'));
      expect(conf, contains('proxy_set_header Host \$host;'));
    });

    test('generates valid Static Site configuration with SPA fallback', () {
      const site = WebSiteEntity(
        domain: 'app.example.com',
        type: WebSiteType.staticSite,
        target: '/var/www/my-frontend/dist',
      );

      final conf = WebSitesController.generateNginxConfig(site);

      expect(conf, contains('server_name app.example.com;'));
      expect(conf, contains('root /var/www/my-frontend/dist;'));
      expect(conf, contains('try_files \$uri \$uri/ /index.html;'));
    });
  });

  group('WebSitesController actions', () {
    test('probeNginx accurately identifies binary presence', () async {
      final mock = _MockSSHSessionManager();
      final controller = WebSitesController(sshManager: mock);

      mock.nextCommandOutput = '/usr/sbin/nginx';
      await controller.probeNginx('sess-1');

      expect(controller.state.isNginxInstalled, isTrue);
    });

    test('createSite writes config, symlinks, tests nginx, and reloads', () async {
      final mock = _MockSSHSessionManager();
      final controller = WebSitesController(sshManager: mock);

      const site = WebSiteEntity(
        domain: 'shop.example.com',
        type: WebSiteType.reverseProxy,
        target: '8080',
      );

      final res = await controller.createSite('sess-1', site);

      expect(res, isA<Success<void>>());
      expect(mock.executedCommands.any((c) => c.contains('/etc/nginx/sites-available/shop.example.com')), isTrue);
      expect(mock.executedCommands.any((c) => c.contains('/etc/nginx/sites-enabled/')), isTrue);
      expect(mock.executedCommands.any((c) => c.contains('nginx -t')), isTrue);
      expect(mock.executedCommands.any((c) => c.contains('systemctl reload nginx')), isTrue);
    });

    test('toggleSite updates enabled symlink and reloads nginx', () async {
      final mock = _MockSSHSessionManager();
      final controller = WebSitesController(sshManager: mock);

      const site = WebSiteEntity(
        domain: 'blog.example.com',
        type: WebSiteType.staticSite,
        target: '/var/www/blog',
        isEnabled: false,
      );

      final res = await controller.toggleSite('sess-1', site, true);

      expect(res, isA<Success<void>>());
      expect(mock.executedCommands.any((c) => c.contains('ln -sf /etc/nginx/sites-available/blog.example.com')), isTrue);
      expect(mock.executedCommands.any((c) => c.contains('systemctl reload nginx')), isTrue);
    });

    test('deleteSite removes configs and reloads nginx', () async {
      final mock = _MockSSHSessionManager();
      final controller = WebSitesController(sshManager: mock);

      const site = WebSiteEntity(
        domain: 'old.example.com',
        type: WebSiteType.staticSite,
        target: '/var/www/old',
      );

      final res = await controller.deleteSite('sess-1', site);

      expect(res, isA<Success<void>>());
      expect(mock.executedCommands.any((c) => c.contains('rm -f /etc/nginx/sites-enabled/old.example.com')), isTrue);
      expect(mock.executedCommands.any((c) => c.contains('rm -f /etc/nginx/sites-available/old.example.com')), isTrue);
      expect(mock.executedCommands.any((c) => c.contains('systemctl reload nginx')), isTrue);
    });
  });
}
