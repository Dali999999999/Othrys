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

/// Telemetry metrics for an active port forwarding tunnel.
class TunnelMetrics {
  int bytesTransmitted;
  int bytesReceived;
  final DateTime startedAt;

  TunnelMetrics({
    this.bytesTransmitted = 0,
    this.bytesReceived = 0,
    DateTime? startedAt,
  }) : startedAt = startedAt ?? DateTime.now();
}

/// Network manager controlling active SSH port forwarding sockets (local, remote, dynamic).
class TunnelManager {
  static final TunnelManager instance = TunnelManager();

  final Map<String, ServerSocket> _activeSockets = {};
  final Map<String, SSHRemoteForward> _activeRemoteForwards = {};
  final Map<String, SSHDynamicForward> _activeDynamicForwards = {};
  final Map<String, TunnelEntity> _activeTunnels = {};
  final Map<String, TunnelStatus> _statuses = {};
  final Map<String, String> _errorMessages = {};
  final Map<String, TunnelMetrics> _metrics = {};

  /// Checks if a tunnel currently has an active forwarding resource.
  bool isTunnelActive(String tunnelId) =>
      _activeSockets.containsKey(tunnelId) ||
      _activeRemoteForwards.containsKey(tunnelId) ||
      _activeDynamicForwards.containsKey(tunnelId);

  /// Gets the runtime status of a given tunnel ID.
  TunnelStatus getTunnelStatus(String tunnelId) {
    return _statuses[tunnelId] ?? TunnelStatus.inactive;
  }

  /// Gets the last error message for a tunnel, if any.
  String? getTunnelError(String tunnelId) => _errorMessages[tunnelId];

  /// Gets telemetry metrics for an active or recently active tunnel.
  TunnelMetrics? getTunnelMetrics(String tunnelId) => _metrics[tunnelId];

  /// Opens a port-forwarding tunnel according to its [tunnel.type].
  Future<Result<int>> openTunnel(TunnelEntity tunnel, SSHClient client) async {
    if (isTunnelActive(tunnel.id)) {
      await closeTunnel(tunnel.id);
    }

    _metrics[tunnel.id] = TunnelMetrics();

    final Result<int> result;
    switch (tunnel.type) {
      case TunnelType.local:
        result = await _openLocalTunnel(tunnel, client);
        break;
      case TunnelType.remote:
        result = await _openRemoteTunnel(tunnel, client);
        break;
      case TunnelType.dynamic:
        result = await _openDynamicTunnel(tunnel, client);
        break;
    }

    if (result.isSuccess) {
      _activeTunnels[tunnel.id] = tunnel;
    }
    return result;
  }

  /// Opens a local port-forwarding tunnel bound to a local socket.
  Future<Result<int>> _openLocalTunnel(TunnelEntity tunnel, SSHClient client) async {
    try {
      final rawHost = tunnel.bindAddress.trim();
      final bindHost = rawHost.isEmpty ? '127.0.0.1' : rawHost;
      final address = InternetAddress.tryParse(bindHost);
      final isLoopback = (address != null && address.isLoopback) || bindHost == 'localhost';
      if (!isLoopback) {
        return Failure('Security violation: tunnel bindAddress must be a local loopback address (127.0.0.1, ::1, localhost). Rejected: "$bindHost"');
      }
      final resolvedAddress = address ?? InternetAddress.loopbackIPv4;

      final serverSocket = await ServerSocket.bind(resolvedAddress, tunnel.localPort);
      final assignedPort = serverSocket.port;

      serverSocket.listen(
        (clientSocket) async {
          try {
            final remoteStream = await client.forwardLocal(tunnel.remoteHost, tunnel.remotePort);

            // Pipe clientSocket -> remoteStream (TX)
            clientSocket.listen(
              (data) {
                _metrics[tunnel.id]?.bytesTransmitted += data.length;
                remoteStream.sink.add(data);
              },
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

            // Pipe remoteStream -> clientSocket (RX)
            remoteStream.stream.listen(
              (data) {
                _metrics[tunnel.id]?.bytesReceived += data.length;
                clientSocket.add(data);
              },
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
        'Local tunnel "${tunnel.name}" opened on $bindHost:$assignedPort -> ${tunnel.remoteHost}:${tunnel.remotePort}',
      );

      return Success(assignedPort);
    } catch (e, st) {
      _statuses[tunnel.id] = TunnelStatus.error;
      _errorMessages[tunnel.id] = e.toString();
      AppLogger.instance.error('TunnelManager', 'Failed to open local tunnel "${tunnel.name}"', e, st);
      return Failure('Failed to open local tunnel: $e', e, st);
    }
  }

  /// Opens a remote port-forwarding tunnel bound on the remote host.
  Future<Result<int>> _openRemoteTunnel(TunnelEntity tunnel, SSHClient client) async {
    try {
      final rawHost = tunnel.bindAddress.trim();
      final bindHost = rawHost.isEmpty ? '127.0.0.1' : rawHost;
      final address = InternetAddress.tryParse(bindHost);
      final isLoopback = (address != null && address.isLoopback) || bindHost == 'localhost';
      if (!isLoopback) {
        return Failure('Security violation: tunnel bindAddress must be a loopback address (127.0.0.1, ::1, localhost). Rejected: "$bindHost"');
      }
      final remoteForward = await client.forwardRemote(
        host: bindHost,
        port: tunnel.remotePort,
      );

      if (remoteForward == null) {
        throw Exception('SSH server rejected remote port forward on $bindHost:${tunnel.remotePort}');
      }

      remoteForward.connections.listen(
        (remoteChannel) async {
          Socket? localSocket;
          try {
            localSocket = await Socket.connect('127.0.0.1', tunnel.localPort);

            // Pipe remoteChannel -> localSocket (RX)
            remoteChannel.stream.listen(
              (data) {
                _metrics[tunnel.id]?.bytesReceived += data.length;
                localSocket?.add(data);
              },
              onError: (err) {
                AppLogger.instance.warn('TunnelManager', 'Remote channel error: $err');
                localSocket?.destroy();
                remoteChannel.close();
              },
              onDone: () {
                localSocket?.destroy();
              },
              cancelOnError: true,
            );

            // Pipe localSocket -> remoteChannel (TX)
            localSocket.listen(
              (data) {
                _metrics[tunnel.id]?.bytesTransmitted += data.length;
                remoteChannel.sink.add(data);
              },
              onError: (err) {
                AppLogger.instance.warn('TunnelManager', 'Local socket error: $err');
                remoteChannel.close();
                localSocket?.destroy();
              },
              onDone: () {
                remoteChannel.close();
              },
              cancelOnError: true,
            );
          } catch (e) {
            AppLogger.instance.error('TunnelManager', 'Failed connecting to local target for remote tunnel', e);
            remoteChannel.close();
            localSocket?.destroy();
          }
        },
        onError: (err) {
          AppLogger.instance.error('TunnelManager', 'Remote forward stream error on tunnel ${tunnel.name}', err);
          _statuses[tunnel.id] = TunnelStatus.error;
          _errorMessages[tunnel.id] = err.toString();
        },
      );

      _activeRemoteForwards[tunnel.id] = remoteForward;
      _statuses[tunnel.id] = TunnelStatus.active;
      _errorMessages.remove(tunnel.id);

      AppLogger.instance.info(
        'TunnelManager',
        'Remote tunnel "${tunnel.name}" active on remote $bindHost:${remoteForward.port} -> local:${tunnel.localPort}',
      );

      return Success(remoteForward.port);
    } catch (e, st) {
      _statuses[tunnel.id] = TunnelStatus.error;
      _errorMessages[tunnel.id] = e.toString();
      AppLogger.instance.error('TunnelManager', 'Failed to open remote tunnel "${tunnel.name}"', e, st);
      return Failure('Failed to open remote tunnel: $e', e, st);
    }
  }

  /// Opens a dynamic SOCKS5 proxy tunnel bound to a local socket.
  Future<Result<int>> _openDynamicTunnel(TunnelEntity tunnel, SSHClient client) async {
    try {
      final rawHost = tunnel.bindAddress.trim();
      final bindHost = rawHost.isEmpty ? '127.0.0.1' : rawHost;
      final address = InternetAddress.tryParse(bindHost);
      final isLoopback = (address != null && address.isLoopback) || bindHost == 'localhost';
      if (!isLoopback) {
        return Failure('Security violation: tunnel bindAddress must be a local loopback address (127.0.0.1, ::1, localhost). Rejected: "$bindHost"');
      }
      final dynamicForward = await client.forwardDynamic(
        bindHost: bindHost,
        bindPort: tunnel.localPort,
      );

      _activeDynamicForwards[tunnel.id] = dynamicForward;
      _statuses[tunnel.id] = TunnelStatus.active;
      _errorMessages.remove(tunnel.id);

      AppLogger.instance.info(
        'TunnelManager',
        'Dynamic SOCKS5 tunnel "${tunnel.name}" listening on $bindHost:${dynamicForward.port}',
      );

      return Success(dynamicForward.port);
    } catch (e, st) {
      _statuses[tunnel.id] = TunnelStatus.error;
      _errorMessages[tunnel.id] = e.toString();
      AppLogger.instance.error('TunnelManager', 'Failed to open dynamic tunnel "${tunnel.name}"', e, st);
      return Failure('Failed to open dynamic tunnel: $e', e, st);
    }
  }

  /// Closes an active tunnel and releases network resources.
  Future<Result<void>> closeTunnel(String tunnelId) async {
    _activeTunnels.remove(tunnelId);
    final socket = _activeSockets.remove(tunnelId);
    if (socket != null) {
      try {
        await socket.close();
      } catch (e) {
        AppLogger.instance.warn('TunnelManager', 'Error closing socket for tunnel $tunnelId: $e');
      }
    }

    final remoteForward = _activeRemoteForwards.remove(tunnelId);
    if (remoteForward != null) {
      try {
        remoteForward.close();
      } catch (e) {
        AppLogger.instance.warn('TunnelManager', 'Error closing remote forward for tunnel $tunnelId: $e');
      }
    }

    final dynamicForward = _activeDynamicForwards.remove(tunnelId);
    if (dynamicForward != null) {
      try {
        dynamicForward.close();
      } catch (e) {
        AppLogger.instance.warn('TunnelManager', 'Error closing dynamic forward for tunnel $tunnelId: $e');
      }
    }

    _statuses[tunnelId] = TunnelStatus.inactive;
    _errorMessages.remove(tunnelId);
    return const Success(null);
  }

  /// Reliability Watchdog: automatically restores all previously active tunnels for [serverId]
  /// using the reconnected [client].
  Future<List<Result<int>>> restoreTunnelsForServer(String serverId, SSHClient client) async {
    final toRestore = _activeTunnels.values.where((t) => t.serverId == serverId).toList();
    if (toRestore.isEmpty) return const [];

    AppLogger.instance.info('TunnelManager', 'Watchdog: Restoring ${toRestore.length} tunnels for server $serverId');
    final results = <Result<int>>[];
    for (final tunnel in toRestore) {
      final res = await openTunnel(tunnel, client);
      results.add(res);
      if (res.isSuccess) {
        AppLogger.instance.info('TunnelManager', 'Watchdog: Successfully restored tunnel "${tunnel.name}"');
      } else {
        AppLogger.instance.warn('TunnelManager', 'Watchdog: Failed to restore tunnel "${tunnel.name}": ${res.failureOrNull?.message}');
      }
    }
    return results;
  }

  /// Closes all active tunnels and resets status maps.
  Future<void> dispose() async {
    _activeTunnels.clear();
    for (final socket in _activeSockets.values) {
      try {
        await socket.close();
      } catch (e) {
        AppLogger.instance.warn('TunnelManager', 'Error closing socket during dispose: $e');
      }
    }
    _activeSockets.clear();

    for (final remoteForward in _activeRemoteForwards.values) {
      try {
        remoteForward.close();
      } catch (e) {
        AppLogger.instance.warn('TunnelManager', 'Error closing remote forward during dispose: $e');
      }
    }
    _activeRemoteForwards.clear();

    for (final dynamicForward in _activeDynamicForwards.values) {
      try {
        dynamicForward.close();
      } catch (e) {
        AppLogger.instance.warn('TunnelManager', 'Error closing dynamic forward during dispose: $e');
      }
    }
    _activeDynamicForwards.clear();

    _statuses.clear();
    _errorMessages.clear();
  }
}
