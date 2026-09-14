import 'dart:async';
import 'package:uuid/uuid.dart';
import '../models/activity_log_entity.dart';
import '../models/server_entity.dart';
import '../models/tunnel_entity.dart';
import '../repositories/activity_repository.dart';

/// Centralized domain service recording user actions, SSH events, and security audit entries.
class ActivityService {
  final ActivityRepository repository;
  final StreamController<ActivityLogEntity> _streamController = StreamController<ActivityLogEntity>.broadcast();

  ActivityService({required this.repository});

  /// Real-time stream of recorded activity events.
  Stream<ActivityLogEntity> get onActivity => _streamController.stream;

  Future<void> _record({
    String? serverId,
    required ActivityLevel level,
    required ActivityCategory category,
    required String message,
    Map<String, dynamic>? metadata,
  }) async {
    final log = ActivityLogEntity(
      id: const Uuid().v4(),
      serverId: serverId,
      timestamp: DateTime.now(),
      level: level,
      category: category,
      message: message,
      metadata: metadata,
    );

    _streamController.add(log);
    await repository.append(log);
  }

  /// Logs server connection established.
  Future<void> logConnect(ServerEntity server) => _record(
        serverId: server.id,
        level: ActivityLevel.success,
        category: ActivityCategory.ssh,
        message: 'Connected to ${server.name} (${server.username}@${server.host})',
        metadata: {'host': server.host, 'port': server.port},
      );

  /// Logs server disconnect.
  Future<void> logDisconnect(ServerEntity server) => _record(
        serverId: server.id,
        level: ActivityLevel.info,
        category: ActivityCategory.ssh,
        message: 'Disconnected from ${server.name}',
      );

  /// Logs systemd service state modification.
  Future<void> logServiceAction(ServerEntity server, String service, String action) => _record(
        serverId: server.id,
        level: ActivityLevel.info,
        category: ActivityCategory.services,
        message: 'Action "$action" executed on service $service',
        metadata: {'service': service, 'action': action},
      );

  /// Logs docker container action.
  Future<void> logDockerAction(ServerEntity server, String container, String action) => _record(
        serverId: server.id,
        level: action == 'rm' ? ActivityLevel.warning : ActivityLevel.info,
        category: ActivityCategory.docker,
        message: 'Action "$action" executed on container $container',
        metadata: {'container': container, 'action': action},
      );

  /// Logs SFTP file operation.
  Future<void> logFileAction(ServerEntity server, String path, String action) => _record(
        serverId: server.id,
        level: ActivityLevel.info,
        category: ActivityCategory.files,
        message: 'File operation "$action" on $path',
        metadata: {'path': path, 'action': action},
      );

  /// Logs port forwarding tunnel event.
  Future<void> logTunnelAction(TunnelEntity tunnel, String action) => _record(
        serverId: tunnel.serverId,
        level: ActivityLevel.info,
        category: ActivityCategory.tunnels,
        message: 'Tunnel "${tunnel.name}" $action (127.0.0.1:${tunnel.localPort} -> ${tunnel.remoteHost}:${tunnel.remotePort})',
      );

  /// Logs a custom action on a server.
  Future<void> logCustomAction(ServerEntity server, String message, {ActivityCategory category = ActivityCategory.system}) => _record(
        serverId: server.id,
        level: ActivityLevel.info,
        category: category,
        message: message,
      );

  /// Logs an error event.
  Future<void> logError(String categoryName, String message, [Object? error]) => _record(
        level: ActivityLevel.error,
        category: ActivityCategory.fromJson(categoryName),
        message: error != null ? '$message: $error' : message,
      );

  void dispose() {
    _streamController.close();
  }
}
