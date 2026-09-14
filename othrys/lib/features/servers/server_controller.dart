import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/server_entity.dart';
import '../../core/models/activity_log_entity.dart';
import '../../core/network/ssh_session_manager.dart';
import '../../core/repositories/server_repository.dart';
import '../../core/services/activity_service.dart';
import '../../core/utils/result.dart';

import '../../core/providers/core_providers.dart';

export '../../core/models/server_entity.dart';
export '../../core/network/active_ssh_session.dart';
export '../../core/providers/core_providers.dart';

/// Immutable state for servers management view.
class ServerState {
  final List<ServerEntity> servers;
  final ServerEntity? selectedServer;
  final ActiveSSHSession? activeSession;
  final bool isLoading;
  final String? errorMessage;

  const ServerState({
    this.servers = const [],
    this.selectedServer,
    this.activeSession,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isConnected => activeSession != null;

  ServerState copyWith({
    List<ServerEntity>? servers,
    ServerEntity? selectedServer,
    ActiveSSHSession? activeSession,
    bool? isLoading,
    String? errorMessage,
    bool clearActiveSession = false,
  }) {
    return ServerState(
      servers: servers ?? this.servers,
      selectedServer: selectedServer ?? this.selectedServer,
      activeSession: clearActiveSession ? null : (activeSession ?? this.activeSession),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Feature controller managing servers lifecycle, connection states, and persistence.
class ServerController extends StateNotifier<ServerState> {
  final ServerRepository repository;
  final SSHSessionManager sshManager;
  final ActivityService? activityService;

  ServerController({
    required this.repository,
    required this.sshManager,
    this.activityService,
  }) : super(const ServerState()) {
    loadServers();
  }

  /// Loads all servers from repository.
  Future<void> loadServers() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await repository.loadAll();
    result.fold(
      onSuccess: (servers) {
        state = state.copyWith(
          servers: servers,
          isLoading: false,
          selectedServer: servers.isNotEmpty ? (state.selectedServer ?? servers.first) : null,
        );
      },
      onFailure: (msg, ex, st) {
        state = state.copyWith(isLoading: false, errorMessage: msg);
      },
    );
  }

  /// Selects active working server profile.
  void selectServer(ServerEntity server) {
    final active = sshManager.getSessionByServerId(server.id);
    state = state.copyWith(
      selectedServer: server,
      activeSession: active,
    );
  }

  /// Saves or updates a server profile.
  Future<Result<void>> saveServer(ServerEntity server) async {
    final saveResult = await repository.save(server);
    if (saveResult.isSuccess) {
      await loadServers();
      state = state.copyWith(selectedServer: server);
    }
    return saveResult;
  }

  /// Deletes a server profile and disconnects if active.
  Future<Result<void>> deleteServer(String serverId) async {
    final active = sshManager.getSessionByServerId(serverId);
    if (active != null) {
      sshManager.disconnect(active.sessionId);
    }

    final deleteResult = await repository.delete(serverId);
    if (deleteResult.isSuccess) {
      await loadServers();
      if (state.selectedServer?.id == serverId) {
        state = state.copyWith(clearActiveSession: true);
      }
    }
    return deleteResult;
  }

  /// Connects to a server profile and initiates keepalive & tracking.
  Future<Result<ActiveSSHSession>> connectToServer(ServerEntity server) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final session = await sshManager.connect(server);
      final updatedServer = server.copyWith(lastConnected: DateTime.now());
      await repository.update(updatedServer);

      activityService?.logConnect(updatedServer);

      state = state.copyWith(
        isLoading: false,
        selectedServer: updatedServer,
        activeSession: session,
      );
      return Success(session);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return Failure('Failed to connect to ${server.name}', e);
    }
  }

  /// Disconnects the current active SSH session.
  void disconnectCurrent() {
    if (state.activeSession != null) {
      final currentServer = state.selectedServer;
      if (currentServer != null) {
        activityService?.logDisconnect(currentServer);
      }
      sshManager.disconnect(state.activeSession!.sessionId);
      state = state.copyWith(clearActiveSession: true);
    }
  }
}

final serverControllerProvider = StateNotifierProvider<ServerController, ServerState>((ref) {
  return ServerController(
    repository: ref.watch(serverRepositoryProvider),
    sshManager: ref.watch(sshSessionManagerProvider),
    activityService: ref.watch(activityServiceProvider),
  );
});

final serverProvider = serverControllerProvider;

final activityStreamProvider = StreamProvider<ActivityLogEntity>((ref) {
  return ref.watch(activityServiceProvider).onActivity;
});
