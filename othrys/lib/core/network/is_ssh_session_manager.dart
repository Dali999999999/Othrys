import 'dart:async';
import 'dart:typed_data';
import 'package:dartssh2/dartssh2.dart';
import '../enums/connection_state.dart';
import '../models/activity_log_entity.dart';
import '../models/server_entity.dart';
import '../models/system_stats_entity.dart';
import '../models/tunnel_entity.dart';
import 'active_ssh_session.dart';

/// Abstract contract for SSH session lifecycle, command execution, and remote tunnels.
abstract class ISSHSessionManager {
  /// UI hook for interactive TOFU host key confirmation.
  Future<bool> Function(ServerEntity server, String fingerprint)? get onHostKeyPrompt;
  set onHostKeyPrompt(Future<bool> Function(ServerEntity server, String fingerprint)? handler);

  /// Broadcast stream for connection activity events.
  Stream<ActivityLogEntity> get onActivity;

  /// Broadcast stream for server connection state changes.
  Stream<MapEntry<String, ConnectionState>> get onConnectionStateChanged;

  /// Returns all currently open SSH sessions.
  List<ActiveSSHSession> get activeSessions;

  /// Total number of active SSH sessions.
  int get activeSessionCount;

  /// Retrieves an active session by session ID.
  ActiveSSHSession? getSession(String sessionId);

  /// Checks if a specific server ID is currently connected.
  bool isConnected(String serverId);

  /// Retrieves an active session by associated server ID.
  ActiveSSHSession? getSessionByServerId(String serverId);

  /// Connects to a remote server.
  Future<ActiveSSHSession> connect(ServerEntity server, {int maxRetries = 2});

  /// Tests connection to a remote server with an ephemeral session.
  Future<String> testConnection(ServerEntity server, {Duration timeout = const Duration(seconds: 10)});

  /// Closes a session cleanly and terminates all associated tunnels.
  void disconnect(String sessionId);

  /// Disconnects all active sessions.
  void disconnectAll();

  /// Executes a shell command and returns UTF-8 decoded output.
  Future<String> executeCommand(String sessionId, String command);

  /// Executes a command safely using CommandSanitizer argument escaping and privilege awareness.
  Future<String> executeSafeCommand(String sessionId, String binary, List<String> args);

  /// Executes a command and pipes stdin data directly into the remote process standard input.
  Future<String> executeCommandWithStdin(String sessionId, String command, Uint8List stdinData);

  /// Executes a safely escaped command and pipes stdin data into standard input.
  Future<String> executeSafeCommandWithStdin(String sessionId, String binary, List<String> args, Uint8List stdinData);

  /// Returns or initializes cached SFTP client for the active session.
  Future<SftpClient> getSftp(String sessionId);

  /// Creates a Local Port Forwarding Tunnel.
  Future<TunnelEntity> createLocalTunnel({
    required String sessionId,
    required String name,
    required int localPort,
    required String remoteHost,
    required int remotePort,
    bool isSystemInternal = false,
  });

  /// Fetches system metrics from the remote server.
  Future<SystemOverview> fetchSystemOverview(String sessionId);
}
