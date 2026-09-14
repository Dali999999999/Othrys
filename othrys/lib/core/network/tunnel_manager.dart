import 'dart:async';
import 'dart:io';
import 'package:dartssh2/dartssh2.dart';
import '../models/tunnel_entity.dart';
import '../utils/logger.dart';
import '../utils/result.dart';

/// Runtime status of a port forwarding tunnel.
enum TunnelStatus {
  active,
  inactive,
  error,
}

/// Network manager controlling active SSH port forwarding sockets.
class TunnelManager {
  static final TunnelManager instance = TunnelManager();

  final Map<String, ServerSocket> _activeSockets = {};
  final Map<String, TunnelStatus> _statuses = {};
  final Map<String, String> _errorMessages = {};

  /// Checks if a tunnel currently has an open listening socket.
  bool isTunnelActive(String tunnelId) => _activeSockets.containsKey(tunnelId);

  /// Gets the runtime status of a given tunnel ID.
  TunnelStatus getTunnelStatus(String tunnelId) {
    return _statuses[tunnelId] ?? TunnelStatus.inactive;
  }

  /// Gets the last error message for a tunnel, if any.
  String? getTunnelError(String tunnelId) => _errorMessages[tunnelId];

  /// Opens a local port-forwarding tunnel bound to local loopback and tunneled via [client].
  Future<Result<int>> openTunnel(TunnelEntity tunnel, SSHClient client) async {
    if (_activeSockets.containsKey(tunnel.id)) {
      await closeTunnel(tunnel.id);
    }

    try {
      final bindHost = tunnel.bindAddress.isNotEmpty ? tunnel.bindAddress : '127.0.0.1';
      final address = InternetAddress.tryParse(bindHost) ?? InternetAddress.loopbackIPv4;

      final serverSocket = await ServerSocket.bind(address, tunnel.localPort);
      final assignedPort = serverSocket.port;

      serverSocket.listen(
        (clientSocket) async {
          try {
            final remoteStream = await client.forwardLocal(tunnel.remoteHost, tunnel.remotePort);

            // Pipe clientSocket -> remoteStream
            clientSocket.listen(
              remoteStream.sink.add,
              onError: (err) {
                AppLogger.instance.warn('TunnelManager', 'Client socket error: $err');
                remoteStream.sink.close();
                clientSocket.destroy();
              },
              onDone: () {
                remoteStream.sink.close();
              },
              cancelOnError: true,
            );

            // Pipe remoteStream -> clientSocket
            remoteStream.stream.listen(
              clientSocket.add,
              onError: (err) {
                AppLogger.instance.warn('TunnelManager', 'Remote stream error: $err');
                clientSocket.destroy();
                remoteStream.sink.close();
              },
              onDone: () {
                clientSocket.destroy();
              },
              cancelOnError: true,
            );
          } catch (e) {
            AppLogger.instance.error('TunnelManager', 'Error establishing forwarded channel', e);
            clientSocket.destroy();
          }
        },
        onError: (err) {
          AppLogger.instance.error('TunnelManager', 'ServerSocket error on tunnel ${tunnel.name}', err);
          _statuses[tunnel.id] = TunnelStatus.error;
          _errorMessages[tunnel.id] = err.toString();
        },
      );

      _activeSockets[tunnel.id] = serverSocket;
      _statuses[tunnel.id] = TunnelStatus.active;
      _errorMessages.remove(tunnel.id);

      AppLogger.instance.info(
        'TunnelManager',
        'Tunnel "${tunnel.name}" opened on $bindHost:$assignedPort -> ${tunnel.remoteHost}:${tunnel.remotePort}',
      );

      return Success(assignedPort);
    } catch (e, st) {
      _statuses[tunnel.id] = TunnelStatus.error;
      _errorMessages[tunnel.id] = e.toString();
      AppLogger.instance.error('TunnelManager', 'Failed to open tunnel "${tunnel.name}"', e, st);
      return Failure('Failed to open tunnel: $e', e, st);
    }
  }

  /// Closes an active tunnel socket and releases local port resources.
  Future<Result<void>> closeTunnel(String tunnelId) async {
    final socket = _activeSockets.remove(tunnelId);
    if (socket != null) {
      try {
        await socket.close();
      } catch (e) {
        AppLogger.instance.warn('TunnelManager', 'Error while closing socket for tunnel $tunnelId: $e');
      }
    }
    _statuses[tunnelId] = TunnelStatus.inactive;
    _errorMessages.remove(tunnelId);
    return const Success(null);
  }

  /// Closes all active tunnels.
  Future<void> dispose() async {
    for (final socket in _activeSockets.values) {
      try {
        await socket.close();
      } catch (e) {
        AppLogger.instance.warn('TunnelManager', 'Error closing socket during dispose: $e');
      }
    }
    _activeSockets.clear();
    _statuses.clear();
    _errorMessages.clear();
  }
}
