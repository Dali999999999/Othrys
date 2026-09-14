import 'dart:async';
import 'dart:io';
import 'package:dartssh2/dartssh2.dart';
import '../enums/connection_state.dart';
import '../models/server_entity.dart';
import '../models/tunnel_entity.dart';
import '../models/user_privileges_entity.dart';

/// Represents an active SSH and SFTP session to a remote VPS.
class ActiveSSHSession {
  final String sessionId;
  final ServerEntity server;
  SSHClient client;
  SftpClient? sftpClient;
  ConnectionState status;
  UserPrivileges? privileges;
  final List<ServerSocket> activeTunnelServers = [];
  final List<TunnelEntity> activeTunnels = [];
  Timer? keepaliveTimer;

  ActiveSSHSession({
    required this.sessionId,
    required this.server,
    required this.client,
    this.status = ConnectionState.connected,
    this.privileges,
  });

  /// Fully cleans up timers, sockets, SFTP channels and SSH connection.
  void dispose() {
    keepaliveTimer?.cancel();
    keepaliveTimer = null;

    for (final serverSocket in activeTunnelServers) {
      serverSocket.close();
    }
    activeTunnelServers.clear();
    activeTunnels.clear();

    try {
      sftpClient?.close();
    } catch (e) {
      // Ignored if socket already closed
    }
    sftpClient = null;

    try {
      client.close();
    } catch (e) {
      // Ignored if socket already closed
    }
    status = ConnectionState.disconnected;
  }
}
