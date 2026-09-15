import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/activity_log_entity.dart';
import '../../core/models/server_admin_entities.dart';
import '../../core/network/ssh_session_manager.dart';
import '../../core/security/command_sanitizer.dart';
import '../../core/services/activity_service.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/result.dart';
import '../servers/server_controller.dart';

export '../../core/models/server_admin_entities.dart';

/// State representation for Server Administration and Security.
class ServerAdminState {
  final FirewallStatus firewall;
  final List<ListeningPort> listeningPorts;
  final List<LinuxUser> users;
  final SystemUpdateInfo updateInfo;
  final bool isLoading;
  final String? errorMessage;

  const ServerAdminState({
    this.firewall = const FirewallStatus(),
    this.listeningPorts = const [],
    this.users = const [],
    this.updateInfo = const SystemUpdateInfo(),
    this.isLoading = false,
    this.errorMessage,
  });

  ServerAdminState copyWith({
    FirewallStatus? firewall,
    List<ListeningPort>? listeningPorts,
    List<LinuxUser>? users,
    SystemUpdateInfo? updateInfo,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ServerAdminState(
      firewall: firewall ?? this.firewall,
      listeningPorts: listeningPorts ?? this.listeningPorts,
      users: users ?? this.users,
      updateInfo: updateInfo ?? this.updateInfo,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Controller orchestrating UFW firewall, listening ports, user accounts, and system updates.
class ServerAdminController extends StateNotifier<ServerAdminState> {
  final SSHSessionManager _ssh;
  final ActivityService? _activity;

  ServerAdminController(this._ssh, this._activity) : super(const ServerAdminState());

  /// Refreshes all administrative modules for the active SSH session.
  Future<void> refresh(String sessionId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await Future.wait([
        loadFirewall(sessionId),
        loadListeningPorts(sessionId),
        loadSystemUsers(sessionId),
        loadSystemInfo(sessionId),
      ]);
      state = state.copyWith(isLoading: false);
    } catch (e, st) {
      AppLogger.instance.error('ServerAdminController', 'Failed to refresh admin data: $e', e, st);
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Loads and parses UFW firewall status and numbered rules.
  Future<void> loadFirewall(String sessionId) async {
    try {
      final probe = await _ssh.executeCommand(sessionId, 'which ufw || echo "NO_UFW"');
      if (probe.contains('NO_UFW') || probe.trim().isEmpty) {
        state = state.copyWith(firewall: const FirewallStatus(isInstalled: false));
        return;
      }

      final statusRes = await _ssh.executeCommand(sessionId, 'sudo ufw status verbose');
      final isEnabled = statusRes.contains('Status: active');

      String defaultIn = 'deny';
      String defaultOut = 'allow';
      final defaultMatch = RegExp(r'Default:\s+([a-z]+)\s+\(incoming\),\s+([a-z]+)\s+\(outgoing\)').firstMatch(statusRes);
      if (defaultMatch != null) {
        defaultIn = defaultMatch.group(1) ?? 'deny';
        defaultOut = defaultMatch.group(2) ?? 'allow';
      }

      final rulesRes = await _ssh.executeCommand(sessionId, 'sudo ufw status numbered');
      final rules = parseUfwNumberedRules(rulesRes);

      state = state.copyWith(
        firewall: FirewallStatus(
          isInstalled: true,
          isEnabled: isEnabled,
          defaultIncoming: defaultIn,
          defaultOutgoing: defaultOut,
          rules: rules,
        ),
      );
    } catch (e, st) {
      AppLogger.instance.error('ServerAdminController', 'loadFirewall error: $e', e, st);
    }
  }

  /// Parses `sudo ufw status numbered` output.
  static List<FirewallRule> parseUfwNumberedRules(String raw) {
    final rules = <FirewallRule>[];
    final lines = raw.split(RegExp(r'\r?\n'));
    final lineRegex = RegExp(r'^\[\s*(\d+)\]\s+(.*?)\s+(ALLOW|DENY|LIMIT|REJECT)\s*(IN|OUT)?\s+(.*?)$', caseSensitive: false);

    for (final line in lines) {
      final trimmed = line.trim();
      final match = lineRegex.firstMatch(trimmed);
      if (match != null) {
        final num = int.tryParse(match.group(1) ?? '') ?? 0;
        final targetRaw = match.group(2)?.trim() ?? '';
        final actionStr = match.group(3)?.trim() ?? 'ALLOW';
        final dirStr = match.group(4)?.trim() ?? 'IN';
        final sourceRaw = match.group(5)?.trim() ?? 'Anywhere';

        final isV6 = targetRaw.contains('(v6)') || sourceRaw.contains('(v6)');
        final cleanTarget = targetRaw.replaceAll('(v6)', '').trim();
        final cleanSource = sourceRaw.replaceAll('(v6)', '').trim();

        rules.add(FirewallRule(
          number: num,
          target: cleanTarget,
          action: FirewallAction.fromString(actionStr),
          direction: FirewallDirection.fromString(dirStr),
          source: cleanSource,
          isV6: isV6,
        ));
      }
    }
    return rules;
  }

  /// Toggles the UFW firewall on or off.
  Future<Result<void>> toggleFirewall(String sessionId, bool enable, {ServerEntity? server}) async {
    final prevFirewall = state.firewall;
    // Optimistically update the enabled state
    state = state.copyWith(
      firewall: prevFirewall.copyWith(isEnabled: enable),
    );
    try {
      final cmd = enable ? 'sudo ufw --force enable' : 'sudo ufw disable';
      await _ssh.executeCommand(sessionId, cmd);

      if (server != null && _activity != null) {
        _activity.logCustomAction(
          server,
          enable ? 'UFW Firewall Enabled' : 'UFW Firewall Disabled',
          category: ActivityCategory.system,
        );
      }
      await loadFirewall(sessionId);
      return const Success(null);
    } catch (e, st) {
      // Rollback on remote failure
      state = state.copyWith(firewall: prevFirewall);
      return Failure('toggleFirewall error: $e', e, st);
    }
  }

  /// Adds a new UFW firewall rule.
  Future<Result<void>> addFirewallRule(
    String sessionId, {
    required String port,
    String proto = 'tcp',
    String action = 'allow',
    String? sourceIp,
    ServerEntity? server,
  }) async {
    try {
      final safePort = port.replaceAll(' ', '').trim();
      final safeProto = proto.toLowerCase().trim();
      final safeAction = action.toLowerCase().trim();

      String cmd;
      if (sourceIp != null && sourceIp.trim().isNotEmpty && sourceIp.trim().toLowerCase() != 'anywhere') {
        final cleanIp = sourceIp.trim();
        cmd = 'sudo ufw $safeAction proto $safeProto from \'$cleanIp\' to any port $safePort';
      } else {
        cmd = 'sudo ufw $safeAction $safePort/$safeProto';
      }

      await _ssh.executeCommand(sessionId, cmd);

      if (server != null && _activity != null) {
        _activity.logCustomAction(
          server,
          'Firewall Rule Added: $safeAction $safePort/$safeProto',
          category: ActivityCategory.system,
        );
      }
      await loadFirewall(sessionId);
      return const Success(null);
    } catch (e, st) {
      return Failure('addFirewallRule error: $e', e, st);
    }
  }

  /// Deletes an existing UFW rule by number.
  Future<Result<void>> deleteFirewallRule(String sessionId, int ruleNumber, {ServerEntity? server}) async {
    final prevFirewall = state.firewall;
    // Optimistically remove the rule from state
    final updatedRules = prevFirewall.rules.where((r) => r.number != ruleNumber).toList();
    state = state.copyWith(
      firewall: prevFirewall.copyWith(rules: updatedRules),
    );
    try {
      await _ssh.executeCommand(sessionId, 'echo "y" | sudo ufw delete $ruleNumber');

      if (server != null && _activity != null) {
        _activity.logCustomAction(
          server,
          'Firewall Rule Deleted: #$ruleNumber',
          category: ActivityCategory.system,
        );
      }
      await loadFirewall(sessionId);
      return const Success(null);
    } catch (e, st) {
      // Rollback on failure
      state = state.copyWith(firewall: prevFirewall);
      return Failure('deleteFirewallRule error: $e', e, st);
    }
  }

  /// Loads and parses open listening ports using `ss -tulpn`.
  Future<void> loadListeningPorts(String sessionId) async {
    try {
      final output = await _ssh.executeCommand(sessionId, 'sudo ss -tulpn');
      final ports = parseListeningPorts(output);
      state = state.copyWith(listeningPorts: ports);
    } catch (e, st) {
      AppLogger.instance.error('ServerAdminController', 'loadListeningPorts error: $e', e, st);
    }
  }

  /// Parses `ss -tulpn` output.
  static List<ListeningPort> parseListeningPorts(String raw) {
    final list = <ListeningPort>[];
    final lines = raw.split(RegExp(r'\r?\n'));

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('Netid') || trimmed.isEmpty) continue;

      final parts = trimmed.split(RegExp(r'\s+'));
      if (parts.length >= 5) {
        final proto = parts[0].toLowerCase();
        final localEndpoint = parts[4];

        final colonIdx = localEndpoint.lastIndexOf(':');
        if (colonIdx != -1) {
          final addr = localEndpoint.substring(0, colonIdx);
          final portStr = localEndpoint.substring(colonIdx + 1);
          final port = int.tryParse(portStr) ?? 0;

          String? process;
          int? pid;
          if (parts.length >= 7) {
            final procPart = parts.sublist(6).join(' ');
            final match = RegExp(r'users:\(\("([^"]+)",pid=(\d+)').firstMatch(procPart);
            if (match != null) {
              process = match.group(1);
              pid = int.tryParse(match.group(2) ?? '');
            }
          }

          if (port > 0) {
            list.add(ListeningPort(
              protocol: proto,
              localAddress: addr.isEmpty ? '*' : addr,
              port: port,
              processName: process,
              pid: pid,
            ));
          }
        }
      }
    }
    return list;
  }

  /// Loads system users and sudoer permissions.
  Future<void> loadSystemUsers(String sessionId) async {
    try {
      final passwdRes = await _ssh.executeCommand(sessionId, 'cat /etc/passwd');
      final groupRes = await _ssh.executeCommand(sessionId, 'cat /etc/group');
      final users = parseLinuxUsers(passwdRes, groupRes);
      state = state.copyWith(users: users);
    } catch (e, st) {
      AppLogger.instance.error('ServerAdminController', 'loadSystemUsers error: $e', e, st);
    }
  }

  /// Parses `/etc/passwd` and detects members of sudo/wheel groups.
  static List<LinuxUser> parseLinuxUsers(String passwdRaw, String groupRaw) {
    final sudoMembers = <String>{};
    for (final line in groupRaw.split(RegExp(r'\r?\n'))) {
      final parts = line.split(':');
      if (parts.isNotEmpty && (parts[0] == 'sudo' || parts[0] == 'wheel' || parts[0] == 'admin')) {
        if (parts.length >= 4) {
          sudoMembers.addAll(parts[3].split(',').map((u) => u.trim()).where((u) => u.isNotEmpty));
        }
      }
    }

    final users = <LinuxUser>[];
    for (final line in passwdRaw.split(RegExp(r'\r?\n'))) {
      final parts = line.split(':');
      if (parts.length >= 7) {
        final username = parts[0];
        final uid = int.tryParse(parts[2]) ?? -1;
        final gid = int.tryParse(parts[3]) ?? -1;
        final home = parts[5];
        final shell = parts[6];

        final isInteractive = !shell.contains('nologin') && !shell.contains('false');
        if (uid == 0 || uid >= 1000 || isInteractive) {
          users.add(LinuxUser(
            username: username,
            uid: uid,
            gid: gid,
            homeDir: home,
            shell: shell,
            isSudoer: uid == 0 || sudoMembers.contains(username),
          ));
        }
      }
    }
    return users;
  }

  static const Set<String> _allowedShells = {
    '/bin/bash',
    '/bin/sh',
    '/bin/zsh',
    '/usr/bin/bash',
    '/usr/bin/sh',
    '/usr/bin/zsh',
    '/bin/false',
    '/usr/sbin/nologin',
  };

  /// Creates a new Linux user account and sets initial password safely via stdin.
  Future<Result<void>> createSystemUser(
    String sessionId,
    String username,
    String password, {
    bool grantSudo = false,
    String shell = '/bin/bash',
    ServerEntity? server,
  }) async {
    try {
      final trimmedUser = username.trim();
      final safeUser = CommandSanitizer.sanitizeIdentifier(trimmedUser);

      // Validate Linux username format strictly (POSIX user names)
      if (!RegExp(r'^[a-z_][a-z0-9_-]*[$]?$').hasMatch(safeUser)) {
        return const Failure('Invalid username format: must start with lowercase letter or underscore');
      }

      // Validate shell against strict whitelist
      final trimmedShell = shell.trim();
      if (!_allowedShells.contains(trimmedShell)) {
        return Failure('Disallowed shell "$shell". Must be one of ${_allowedShells.join(', ')}');
      }

      // Validate password does not contain characters that could corrupt chpasswd record
      if (password.contains('\n') || password.contains('\r') || password.contains('\x00')) {
        return const Failure('Password contains forbidden line breaks or null characters');
      }
      if (password.contains(':')) {
        return const Failure('Password cannot contain colon character (:) used as delimiter in chpasswd');
      }
      if (password.isEmpty) {
        return const Failure('Password cannot be empty');
      }

      // 1. Create user with separated arguments via executeSafeCommand
      await _ssh.executeSafeCommand(sessionId, 'sudo', [
        'useradd',
        '-m',
        '-s',
        trimmedShell,
        safeUser,
      ]);

      // 2. Set password via chpasswd through encrypted stdin without shell interpolation
      final chpasswdInput = Uint8List.fromList(utf8.encode('$safeUser:$password\n'));
      await _ssh.executeSafeCommandWithStdin(
        sessionId,
        'sudo',
        ['chpasswd'],
        chpasswdInput,
      );

      // 3. Grant sudo if requested
      if (grantSudo) {
        try {
          await _ssh.executeSafeCommand(sessionId, 'sudo', ['usermod', '-aG', 'sudo', safeUser]);
        } catch (e) {
          AppLogger.instance.info('ServerAdminController', 'sudo group assignment failed ($e), falling back to wheel group');
          await _ssh.executeSafeCommand(sessionId, 'sudo', ['usermod', '-aG', 'wheel', safeUser]);
        }
      }

      if (server != null && _activity != null) {
        _activity.logCustomAction(
          server,
          'User Created: $safeUser (sudo: $grantSudo)',
          category: ActivityCategory.system,
        );
      }
      await loadSystemUsers(sessionId);
      return const Success(null);
    } catch (e, st) {
      return Failure('createSystemUser error: $e', e, st);
    }
  }

  /// Deletes a Linux user account and their home directory safely.
  Future<Result<void>> deleteSystemUser(
    String sessionId,
    String username, {
    ServerEntity? server,
  }) async {
    try {
      final safeUser = CommandSanitizer.sanitizeIdentifier(username);
      if (safeUser == 'root') {
        return const Failure('Cannot delete root user account');
      }
      try {
        await _ssh.executeSafeCommand(sessionId, 'sudo', ['userdel', '-r', safeUser]);
      } catch (e) {
        AppLogger.instance.info('ServerAdminController', 'userdel -r failed ($e), falling back to userdel without home directory removal');
        await _ssh.executeSafeCommand(sessionId, 'sudo', ['userdel', safeUser]);
      }

      if (server != null && _activity != null) {
        _activity.logCustomAction(
          server,
          'User Deleted: $safeUser',
          category: ActivityCategory.system,
        );
      }
      await loadSystemUsers(sessionId);
      return const Success(null);
    } catch (e, st) {
      return Failure('deleteSystemUser error: $e', e, st);
    }
  }

  /// Adds an authorized public SSH key to a user account.
  Future<Result<void>> addAuthorizedKey(
    String sessionId,
    String username,
    String publicKey, {
    ServerEntity? server,
  }) async {
    try {
      final safeUser = CommandSanitizer.sanitizeIdentifier(username);
      final trimmedKey = publicKey.trim();
      if (!trimmedKey.startsWith('ssh-') && !trimmedKey.startsWith('ecdsa-')) {
        return const Failure('Invalid SSH public key format (must start with ssh- or ecdsa-)');
      }
      if (trimmedKey.contains('\n') || trimmedKey.contains('\r') || trimmedKey.contains('\x00')) {
        return const Failure('SSH public key must not contain line breaks or null characters');
      }

      await _ssh.executeCommand(
        sessionId,
        "sudo -u '$safeUser' mkdir -p ~/.ssh && sudo -u '$safeUser' chmod 700 ~/.ssh",
      );
      await _ssh.executeCommandWithStdin(
        sessionId,
        "sudo -u '$safeUser' tee -a ~/.ssh/authorized_keys > /dev/null",
        Uint8List.fromList(utf8.encode('$trimmedKey\n')),
      );
      await _ssh.executeCommand(
        sessionId,
        "sudo -u '$safeUser' chmod 600 ~/.ssh/authorized_keys",
      );

      if (server != null && _activity != null) {
        _activity.logCustomAction(
          server,
          'SSH Key Added for $safeUser',
          category: ActivityCategory.system,
        );
      }
      return const Success(null);
    } catch (e, st) {
      return Failure('addAuthorizedKey error: $e', e, st);
    }
  }

  /// Loads host metadata and upgradable packages.
  Future<void> loadSystemInfo(String sessionId) async {
    try {
      final infoRes = await _ssh.executeCommand(
        sessionId,
        'hostname && uname -r && (cat /etc/os-release | grep PRETTY_NAME | cut -d= -f2 | tr -d \'"\') && uptime -p',
      );
      final infoLines = infoRes.split(RegExp(r'\r?\n')).map((l) => l.trim()).toList();
      final host = infoLines.isNotEmpty ? infoLines[0] : '';
      final kernel = infoLines.length > 1 ? infoLines[1] : '';
      final os = infoLines.length > 2 ? infoLines[2] : '';
      final uptime = infoLines.length > 3 ? infoLines[3] : '';

      final aptRes = await _ssh.executeCommand(sessionId, 'apt list --upgradable 2>/dev/null | grep -v "Listing..." || true');
      final pkgLines = aptRes.split(RegExp(r'\r?\n')).where((l) => l.contains('/')).toList();

      state = state.copyWith(
        updateInfo: SystemUpdateInfo(
          hostname: host,
          kernelVersion: kernel,
          osRelease: os,
          uptime: uptime,
          upgradableCount: pkgLines.length,
          upgradablePackages: pkgLines,
        ),
      );
    } catch (e, st) {
      AppLogger.instance.error('ServerAdminController', 'loadSystemInfo error: $e', e, st);
    }
  }

  /// Applies system OS package upgrades.
  Future<Result<String>> applySystemUpdates(String sessionId, {ServerEntity? server}) async {
    try {
      final output = await _ssh.executeCommand(
        sessionId,
        'sudo DEBIAN_FRONTEND=noninteractive apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y',
      );

      if (server != null && _activity != null) {
        _activity.logCustomAction(
          server,
          'System OS Packages Upgraded',
          category: ActivityCategory.system,
        );
      }
      await loadSystemInfo(sessionId);
      return Success(output);
    } catch (e, st) {
      return Failure('applySystemUpdates error: $e', e, st);
    }
  }

  /// Changes the remote server hostname.
  Future<Result<void>> setHostname(String sessionId, String newHostname, {ServerEntity? server}) async {
    try {
      final safeHost = CommandSanitizer.sanitizeIdentifier(newHostname);
      await _ssh.executeCommand(sessionId, 'sudo hostnamectl set-hostname \'$safeHost\'');

      if (server != null && _activity != null) {
        _activity.logCustomAction(
          server,
          'Hostname Changed to $safeHost',
          category: ActivityCategory.system,
        );
      }
      await loadSystemInfo(sessionId);
      return const Success(null);
    } catch (e, st) {
      return Failure('setHostname error: $e', e, st);
    }
  }

  /// Triggers a remote server reboot.
  Future<Result<void>> rebootServer(String sessionId, {ServerEntity? server}) async {
    try {
      if (server != null && _activity != null) {
        _activity.logCustomAction(
          server,
          'Remote Reboot Initiated',
          category: ActivityCategory.system,
        );
      }
      await _ssh.executeCommand(sessionId, 'sudo reboot &');
      return const Success(null);
    } catch (e, st) {
      return Failure('rebootServer error: $e', e, st);
    }
  }
}

/// Provider exposing ServerAdminController.
final serverAdminControllerProvider = StateNotifierProvider<ServerAdminController, ServerAdminState>((ref) {
  return ServerAdminController(
    ref.watch(sshSessionManagerProvider),
    ref.watch(activityServiceProvider),
  );
});
