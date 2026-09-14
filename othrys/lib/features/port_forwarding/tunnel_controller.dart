import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/tunnel_entity.dart';
import '../../core/network/ssh_session_manager.dart';
import '../../core/network/tunnel_manager.dart';
import '../../core/repositories/tunnel_repository.dart';
import '../../core/services/activity_service.dart';
import '../../core/utils/result.dart';
import '../../core/providers/core_providers.dart';

export '../../core/models/tunnel_entity.dart';
export '../../core/network/tunnel_manager.dart';
export '../../core/providers/core_providers.dart';

/// State representation for configured and active SSH tunnels.
class TunnelState {
  final List<TunnelEntity> tunnels;
  final Map<String, bool> activeStatuses;
  final bool isLoading;
  final String? error;

  const TunnelState({
    this.tunnels = const [],
    this.activeStatuses = const {},
    this.isLoading = false,
    this.error,
  });

  TunnelState copyWith({
    List<TunnelEntity>? tunnels,
    Map<String, bool>? activeStatuses,
    bool? isLoading,
    String? error,
  }) =>
      TunnelState(
        tunnels: tunnels ?? this.tunnels,
        activeStatuses: activeStatuses ?? this.activeStatuses,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class TunnelController extends StateNotifier<TunnelState> {
  final TunnelRepository repository;
  final SSHSessionManager sshManager;
  final TunnelManager tunnelManager;
  final ActivityService? activityService;

  TunnelController({
    required this.repository,
    required this.sshManager,
    TunnelManager? tunnelManager,
    this.activityService,
  })  : tunnelManager = tunnelManager ?? TunnelManager.instance,
        super(const TunnelState());

  /// Loads all saved tunnels for a specific server or globally.
  Future<Result<List<TunnelEntity>>> loadTunnels({String? serverId, bool isSilent = false}) async {
    if (!isSilent && state.tunnels.isEmpty) {
      state = state.copyWith(isLoading: true, error: null);
    } else {
      state = state.copyWith(error: null);
    }
    final result = serverId != null
        ? await repository.loadByServerId(serverId)
        : await repository.loadAll();
    result.fold(
      onSuccess: (list) {
        final statuses = <String, bool>{};
        for (final t in list) {
          statuses[t.id] = tunnelManager.isTunnelActive(t.id);
        }
        state = state.copyWith(tunnels: list, activeStatuses: statuses, isLoading: false);
      },
      onFailure: (msg, ex, st) => state = state.copyWith(isLoading: false, error: msg),
    );
    return result;
  }

  /// Creates and saves a new tunnel configuration.
  Future<Result<void>> createTunnel(TunnelEntity tunnel) async {
    final prevTunnels = state.tunnels;
    state = state.copyWith(
      tunnels: [...state.tunnels, tunnel],
      activeStatuses: {...state.activeStatuses, tunnel.id: false},
    );
    final result = await repository.save(tunnel);
    if (result.isSuccess) {
      await loadTunnels(serverId: tunnel.serverId, isSilent: true);
      activityService?.logTunnelAction(tunnel, 'created');
    } else {
      state = state.copyWith(tunnels: prevTunnels);
    }
    return result;
  }

  /// Deletes a tunnel configuration.
  Future<Result<void>> deleteTunnel(String id, {String? serverId, TunnelEntity? tunnel}) async {
    final prevTunnels = state.tunnels;
    final prevStatuses = state.activeStatuses;

    if (tunnelManager.isTunnelActive(id)) {
      await tunnelManager.closeTunnel(id);
    }

    final updatedTunnels = state.tunnels.where((t) => t.id != id).toList();
    final updatedStatuses = Map<String, bool>.from(state.activeStatuses)..remove(id);
    state = state.copyWith(tunnels: updatedTunnels, activeStatuses: updatedStatuses);

    final result = await repository.delete(id);
    if (result.isSuccess) {
      await loadTunnels(serverId: serverId, isSilent: true);
      if (tunnel != null) {
        activityService?.logTunnelAction(tunnel, 'deleted');
      }
    } else {
      state = state.copyWith(tunnels: prevTunnels, activeStatuses: prevStatuses);
    }
    return result;
  }

  /// Toggles an SSH port-forwarding tunnel runtime state.
  Future<Result<bool>> toggleTunnel(String sessionId, TunnelEntity tunnel) async {
    final currentStatus = state.activeStatuses[tunnel.id] ?? false;

    if (currentStatus) {
      // Deactivate tunnel
      await tunnelManager.closeTunnel(tunnel.id);
      final updated = Map<String, bool>.from(state.activeStatuses)..[tunnel.id] = false;
      state = state.copyWith(activeStatuses: updated, error: null);
      activityService?.logTunnelAction(tunnel, 'closed');
      return const Success(false);
    } else {
      // Activate tunnel
      final session = sshManager.getSession(sessionId);
      if (session == null) {
        return const Failure('No active SSH session found for this server.');
      }

      final openResult = await tunnelManager.openTunnel(tunnel, session.client);
      if (openResult.isFailure) {
        final updated = Map<String, bool>.from(state.activeStatuses)..[tunnel.id] = false;
        state = state.copyWith(activeStatuses: updated, error: openResult.failureOrNull?.message);
        activityService?.logError('tunnels', 'Failed to start tunnel "${tunnel.name}"', openResult.failureOrNull?.message);
        return Failure(openResult.failureOrNull?.message ?? 'Failed to open tunnel');
      }

      final updated = Map<String, bool>.from(state.activeStatuses)..[tunnel.id] = true;
      state = state.copyWith(activeStatuses: updated, error: null);
      activityService?.logTunnelAction(tunnel, 'started');
      return const Success(true);
    }
  }
}

final tunnelControllerProvider =
    StateNotifierProvider.autoDispose<TunnelController, TunnelState>((ref) => TunnelController(
          repository: ref.watch(tunnelRepositoryProvider),
          sshManager: ref.watch(sshSessionManagerProvider),
          tunnelManager: ref.watch(tunnelManagerProvider),
          activityService: ref.watch(activityServiceProvider),
        ));

