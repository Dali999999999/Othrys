import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dartssh2/dartssh2.dart';
import 'package:uuid/uuid.dart';
import '../enums/connection_state.dart';
import '../models/server_entity.dart';
import '../models/tunnel_entity.dart';
import '../models/activity_log_entity.dart';
import '../models/system_stats_entity.dart';
import '../models/user_privileges_entity.dart';
import '../security/command_sanitizer.dart';
import '../security/host_key_store.dart';
import '../storage/local_storage_service.dart';
import '../utils/logger.dart';
import 'active_ssh_session.dart';

export 'active_ssh_session.dart';
export '../models/user_privileges_entity.dart';

/// Central SSH and SFTP connection manager.
class SSHSessionManager {
  static final SSHSessionManager instance = SSHSessionManager();
  final HostKeyStore _hostKeyStore;

  SSHSessionManager({HostKeyStore? hostKeyStore}) : _hostKeyStore = hostKeyStore ?? HostKeyStore();

  final Map<String, ActiveSSHSession> _sessions = {};
  final StreamController<ActivityLogEntity> _activityStream = StreamController<ActivityLogEntity>.broadcast();
  final StreamController<MapEntry<String, ConnectionState>> _stateStream =
      StreamController<MapEntry<String, ConnectionState>>.broadcast();

  /// UI hook for interactive TOFU host key confirmation.
  Future<bool> Function(ServerEntity server, String fingerprint)? onHostKeyPrompt;

  Stream<ActivityLogEntity> get onActivity => _activityStream.stream;
  Stream<MapEntry<String, ConnectionState>> get onConnectionStateChanged => _stateStream.stream;

  List<ActiveSSHSession> get activeSessions => _sessions.values.toList();
  int get activeSessionCount => _sessions.length;
  ActiveSSHSession? getSession(String sessionId) => _sessions[sessionId];

  bool isConnected(String serverId) =>
      _sessions.values.any((s) => s.server.id == serverId && s.status == ConnectionState.connected);

  ActiveSSHSession? getSessionByServerId(String serverId) {
    try {
      return _sessions.values.firstWhere((s) => s.server.id == serverId);
    } catch (e) {
      return null;
    }
  }

  /// Injects an active session for unit testing privilege and command logic.
  void registerSessionForTesting(ActiveSSHSession session) {
    _sessions[session.sessionId] = session;
  }

  /// Clears test sessions.
  void clearSessionsForTesting() {
    _sessions.clear();
  }

  void _notifyState(String serverId, ConnectionState state) {
    _stateStream.add(MapEntry(serverId, state));
  }

  void _log(ActivityLevel level, String category, String message, {String? serverId, Map<String, dynamic>? meta}) {
    final log = ActivityLogEntity(
      id: const Uuid().v4(),
      serverId: serverId,
      timestamp: DateTime.now(),
      level: level,
      category: ActivityCategory.fromJson(category),
      message: message,
      metadata: meta,
    );
    _activityStream.add(log);
    LocalStorageService.instance.appendActivityLog(log);
  }

  /// Connects to a remote server with automatic retry logic and host key validation.
  Future<ActiveSSHSession> connect(ServerEntity server, {int maxRetries = 3}) async {
    final sessionId = const Uuid().v4();
    _log(ActivityLevel.info, 'SSH', 'Connecting to ${server.name} (${server.host}:${server.port})...');
    _notifyState(server.id, ConnectionState.connecting);

    await _hostKeyStore.load();

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final client = await _establishConnection(server);

        // Probe remote user privileges (UID, groups, passwordless sudo capability)
        UserPrivileges privileges;
        try {
          final probeOutput = await client.run(
            'id -u && id -un && id -Gn && (sudo -n true 2>/dev/null && echo "SUDO:YES" || echo "SUDO:NO")',
          ).timeout(const Duration(seconds: 5));
          final raw = utf8.decode(probeOutput, allowMalformed: true);
          privileges = UserPrivileges.fromRaw(raw);
        } catch (e) {
          AppLogger.instance.warn('SSHSessionManager', 'Could not probe remote privileges: $e');
          privileges = UserPrivileges.unknown(username: server.username);
        }

        final session = ActiveSSHSession(
          sessionId: sessionId,
          server: server,
          client: client,
          status: ConnectionState.connected,
          privileges: privileges,
        );

        _sessions[sessionId] = session;
        _setupKeepalive(session);
        _notifyState(server.id, ConnectionState.connected);

        _log(ActivityLevel.success, 'SSH', 'Connected to ${server.name} (${server.username}@${server.host})');
        _log(
          ActivityLevel.info,
          'SSH',
          'Privileges: ${privileges.username} (UID ${privileges.uid}) - Role: ${privileges.role.name.toUpperCase()}',
          meta: {
            'role': privileges.role.name,
            'isRoot': privileges.isRoot,
            'canManageSystem': privileges.canManageSystem,
            'canManageDocker': privileges.canManageDocker,
          },
        );
        return session;
      } catch (e, st) {
        final delaySeconds = attempt * 2;
        if (attempt < maxRetries) {
          _log(ActivityLevel.warning, 'SSH', 'Connection attempt $attempt/$maxRetries failed. Retrying in ${delaySeconds}s...', meta: {'error': e.toString()});
          await Future.delayed(Duration(seconds: delaySeconds));
        } else {
          _notifyState(server.id, ConnectionState.error);
          _log(ActivityLevel.error, 'SSH', 'Failed to connect to ${server.name}: $e', meta: {'error': e.toString()});
          AppLogger.instance.error('SSHSessionManager', 'Connection to ${server.name} failed: $e', e, st);
          rethrow;
        }
      }
    }

    throw Exception('Connection failed after $maxRetries attempts');
  }

  /// Tests connection to a remote server with an ephemeral session and closes it immediately.
  Future<String> testConnection(ServerEntity server, {Duration timeout = const Duration(seconds: 10)}) async {
    SSHClient? client;
    try {
      client = await _establishConnection(server).timeout(timeout);
      await client.authenticated.timeout(timeout);

      try {
        final unameBytes = await client.run('uname -s').timeout(const Duration(seconds: 3));
        final uname = utf8.decode(unameBytes).trim();
        if (uname.isNotEmpty) {
          return uname;
        }
      } catch (e) {
        AppLogger.instance.warn('SSHSessionManager', 'Could not fetch remote uname during test: $e');
      }
      return 'Connected';
    } finally {
      client?.close();
    }
  }

  Future<SSHClient> _establishConnection(ServerEntity server) async {
    if (server.bastionId != null && server.bastionId!.isNotEmpty) {
      final allServersResult = await LocalStorageService.instance.loadServers();
      final allServers = allServersResult.getOrElse(() => []);
      final bastionServer = allServers.firstWhere((s) => s.id == server.bastionId);

      _log(ActivityLevel.info, 'SSH', 'Connecting through Bastion Jump Host ${bastionServer.name}...');
      final bastionClient = await _establishDirectClient(bastionServer);
      final forwardedStream = await bastionClient.forwardLocal(server.host, server.port);

      return _authenticateWithSocket(socket: forwardedStream, server: server);
    }
    return _establishDirectClient(server);
  }

  Future<SSHClient> _establishDirectClient(ServerEntity server) async {
    final socket = await SSHSocket.connect(
      server.host,
      server.port,
      timeout: const Duration(seconds: 15),
    );
    return _authenticateWithSocket(socket: socket, server: server);
  }

  Future<SSHClient> _authenticateWithSocket({required dynamic socket, required ServerEntity server}) async {
    List<SSHKeyPair> keyPairs = [];

    if (server.authType.name == 'privateKey' && server.privateKey != null) {
      try {
        keyPairs = SSHKeyPair.fromPem(server.privateKey!, server.passphrase);
      } catch (e, st) {
        AppLogger.instance.error('SSHSessionManager', 'Failed to parse SSH private key: $e', e, st);
        _log(ActivityLevel.error, 'SSH', 'Failed to parse SSH private key: $e');
      }
    }

    return SSHClient(
      socket,
      username: server.username,
      onPasswordRequest: () => server.password ?? '',
      identities: keyPairs,
      onVerifyHostKey: (type, fingerprint) {
        final fpHex = fingerprint.map((b) => b.toRadixString(16).padLeft(2, '0')).join(':');
        final status = _hostKeyStore.verifyHostKeySync(server.host, server.port, fpHex);

        if (status == HostKeyStatus.trusted) {
          return true;
        } else if (status == HostKeyStatus.unknown) {
          // Trust on first use after persisting to encrypted host key store
          _hostKeyStore.trustHost(server.host, server.port, fpHex);
          _log(ActivityLevel.info, 'SSH', 'New host key trusted for ${server.host}:$fpHex');
          return true;
        } else {
          _log(ActivityLevel.error, 'SSH', 'CRITICAL SECURITY: Host key changed for ${server.host}! Possible MITM attack.');
          return false;
        }
      },
    );
  }

  void _setupKeepalive(ActiveSSHSession session) {
    session.keepaliveTimer?.cancel();
    session.keepaliveTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      try {
        final result = await session.client.run('echo 1');
        if (result.isEmpty) {
          _handleConnectionLost(session);
        }
      } catch (e) {
        _handleConnectionLost(session);
      }
    });
  }

  void _handleConnectionLost(ActiveSSHSession session) {
    session.status = ConnectionState.reconnecting;
    _notifyState(session.server.id, ConnectionState.reconnecting);
    _log(ActivityLevel.warning, 'SSH', 'Connection lost to ${session.server.name}. Reconnecting...');

    // Dispose old session before attempting to reconnect (prevents resource leaks)
    session.dispose();

    connect(session.server, maxRetries: 3).then((newSession) {
      _sessions[session.sessionId] = newSession;
      _log(ActivityLevel.success, 'SSH', 'Auto-reconnected to ${session.server.name}');
    }).catchError((e, st) {
      session.status = ConnectionState.disconnected;
      _notifyState(session.server.id, ConnectionState.disconnected);
      _log(ActivityLevel.error, 'SSH', 'Auto-reconnect failed for ${session.server.name}: $e');
      AppLogger.instance.error('SSHSessionManager', 'Auto-reconnect failed: $e', e, st);
    });
  }

  /// Executes a single shell command and returns UTF-8 decoded output.
  Future<String> executeCommand(String sessionId, String command) async {
    final session = _sessions[sessionId];
    if (session == null || session.status != ConnectionState.connected) {
      throw Exception('SSH session not found or disconnected');
    }
    final output = await session.client.run(command);
    return utf8.decode(output, allowMalformed: true);
  }

  /// Executes a command safely using CommandSanitizer argument escaping and privilege awareness.
  Future<String> executeSafeCommand(String sessionId, String binary, List<String> args) {
    final session = _sessions[sessionId];
    var effectiveBinary = binary;
    var effectiveArgs = List<String>.from(args);

    if (session != null && session.privileges != null) {
      final priv = session.privileges!;
      if (binary == 'sudo') {
        if (priv.isRoot && args.isNotEmpty) {
          // As root, strip redundant sudo prefix
          effectiveBinary = args[0];
          effectiveArgs = args.sublist(1);
        } else if (!priv.canSudoWithoutPassword && !priv.isRoot) {
          // Standard user without passwordless sudo: reject cleanly
          throw Exception(
            'Permission denied: user "${priv.username}" does not have root/sudo privileges to execute "$args".',
          );
        }
      }
    }

    final safeCmd = CommandSanitizer.buildSafeCommand(effectiveBinary, effectiveArgs);
    return executeCommand(sessionId, safeCmd);
  }

  /// Returns or initializes cached SFTP client for the active session.
  Future<SftpClient> getSftp(String sessionId) async {
    final session = _sessions[sessionId];
    if (session == null) throw Exception('Session not found');
    if (session.sftpClient != null) return session.sftpClient!;
    final sftp = await session.client.sftp();
    session.sftpClient = sftp;
    return sftp;
  }

  /// Creates a Local Port Forwarding Tunnel.
  Future<TunnelEntity> createLocalTunnel({
    required String sessionId,
    required String name,
    required int localPort,
    required String remoteHost,
    required int remotePort,
    bool isSystemInternal = false,
  }) async {
    final session = _sessions[sessionId];
    if (session == null) throw Exception('Session not found');

    final serverSocket = await ServerSocket.bind(InternetAddress.loopbackIPv4, localPort);
    final assignedPort = serverSocket.port;

    serverSocket.listen((clientSocket) async {
      try {
        final remoteStream = await session.client.forwardLocal(remoteHost, remotePort);
        clientSocket.listen(
          remoteStream.sink.add,
          onError: (e) => remoteStream.close(),
          onDone: () => remoteStream.close(),
        );
        remoteStream.stream.listen(
          clientSocket.add,
          onError: (e) => clientSocket.close(),
          onDone: () => clientSocket.close(),
        );
      } catch (e) {
        clientSocket.close();
      }
    });

    final tunnel = TunnelEntity(
      id: const Uuid().v4(),
      serverId: session.server.id,
      name: name,
      localPort: assignedPort,
      remoteHost: remoteHost,
      remotePort: remotePort,
      isSystemInternal: isSystemInternal,
    );

    session.activeTunnelServers.add(serverSocket);
    session.activeTunnels.add(tunnel);

    _log(ActivityLevel.info, 'SSH', 'Created local tunnel: 127.0.0.1:$assignedPort -> $remoteHost:$remotePort');
    return tunnel;
  }

  /// Fetches system metrics from the remote server.
  Future<SystemOverview> fetchSystemOverview(String sessionId) async {
    final cmd = 'uptime && free -b && df -k / && uname -s -r';
    final output = await executeCommand(sessionId, cmd);
    final lines = output.trim().split('\n');

    double cpuPercent = 0.0;
    int memUsed = 0;
    int memTotal = 1;
    int diskUsed = 0;
    int diskTotal = 1;
    String uptime = 'Unknown';
    String osKernel = 'Linux';

    try {
      if (lines.isNotEmpty) {
        final uptimeLine = lines[0];
        final loadMatch = RegExp(r'load average:\s*([0-9.]+)').firstMatch(uptimeLine);
        if (loadMatch != null) {
          final load = double.tryParse(loadMatch.group(1) ?? '0') ?? 0;
          cpuPercent = (load * 100).clamp(0.0, 100.0);
        }
        if (uptimeLine.contains('up ')) {
          uptime = uptimeLine.split('up ')[1].split(',')[0].trim();
        }
      }

      final memLine = lines.firstWhere((l) => l.startsWith('Mem:'), orElse: () => '');
      if (memLine.isNotEmpty) {
        final parts = memLine.split(RegExp(r'\s+'));
        if (parts.length >= 3) {
          memTotal = int.tryParse(parts[1]) ?? 1;
          memUsed = int.tryParse(parts[2]) ?? 0;
        }
      }

      final diskLine = lines.firstWhere((l) => l.contains('/'), orElse: () => '');
      if (diskLine.isNotEmpty) {
        final parts = diskLine.split(RegExp(r'\s+'));
        if (parts.length >= 4) {
          diskTotal = (int.tryParse(parts[1]) ?? 1) * 1024;
          diskUsed = (int.tryParse(parts[2]) ?? 0) * 1024;
        }
      }

      if (lines.length > 3) {
        osKernel = lines.last.trim();
      }
    } catch (e) {
      AppLogger.instance.warn('SSHSessionManager', 'Error parsing system overview: $e');
    }

    return SystemOverview(
      cpuUsagePercent: double.parse(cpuPercent.toStringAsFixed(1)),
      memoryUsagePercent: double.parse(((memUsed / memTotal) * 100).toStringAsFixed(1)),
      memoryUsedBytes: memUsed,
      memoryTotalBytes: memTotal,
      diskUsagePercent: double.parse(((diskUsed / diskTotal) * 100).toStringAsFixed(1)),
      diskUsedBytes: diskUsed,
      diskTotalBytes: diskTotal,
      uptime: uptime,
      osName: 'Linux Server',
      kernel: osKernel,
    );
  }

  /// Closes a session cleanly and terminates all associated tunnels.
  void disconnect(String sessionId) {
    final session = _sessions.remove(sessionId);
    if (session != null) {
      session.dispose();
      _notifyState(session.server.id, ConnectionState.disconnected);
      _log(ActivityLevel.info, 'SSH', 'Disconnected from ${session.server.name}');
    }
  }

  /// Disconnects all active sessions on application exit.
  void disconnectAll() {
    for (final session in _sessions.values) {
      session.dispose();
      _notifyState(session.server.id, ConnectionState.disconnected);
    }
    _sessions.clear();
  }
}
