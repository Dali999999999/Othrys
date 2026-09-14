import '../models/tunnel_entity.dart';
import '../storage/local_storage_service.dart';
import '../utils/result.dart';

/// Contract defining persistence operations for [TunnelEntity].
abstract class TunnelRepository {
  /// Loads all configured port forwarding tunnels.
  Future<Result<List<TunnelEntity>>> loadAll();

  /// Loads tunnels linked to a specific server ID.
  Future<Result<List<TunnelEntity>>> loadByServerId(String serverId);

  /// Saves or creates a tunnel configuration.
  Future<Result<void>> save(TunnelEntity tunnel);

  /// Deletes a tunnel configuration by ID.
  Future<Result<void>> delete(String id);

  /// Gets a tunnel configuration by ID.
  Future<Result<TunnelEntity?>> getById(String id);
}

/// Local implementation of [TunnelRepository].
class LocalTunnelRepository implements TunnelRepository {
  final LocalStorageService _storage;

  LocalTunnelRepository({LocalStorageService? storage})
      : _storage = storage ?? LocalStorageService.instance;

  @override
  Future<Result<List<TunnelEntity>>> loadAll() => _storage.loadTunnels();

  @override
  Future<Result<List<TunnelEntity>>> loadByServerId(String serverId) async {
    final listResult = await loadAll();
    return listResult.fold(
      onSuccess: (tunnels) => Success(tunnels.where((t) => t.serverId == serverId).toList()),
      onFailure: (msg, ex, st) => Failure(msg, ex, st),
    );
  }

  @override
  Future<Result<void>> save(TunnelEntity tunnel) async {
    final listResult = await loadAll();
    if (listResult is Failure<List<TunnelEntity>>) return Failure(listResult.message, listResult.exception, listResult.stackTrace);

    final current = (listResult as Success<List<TunnelEntity>>).data;
    final index = current.indexWhere((t) => t.id == tunnel.id);
    final List<TunnelEntity> updated;

    if (index >= 0) {
      updated = List.from(current)..[index] = tunnel;
    } else {
      updated = [...current, tunnel];
    }

    return _storage.saveTunnels(updated);
  }

  @override
  Future<Result<void>> delete(String id) async {
    final listResult = await loadAll();
    if (listResult is Failure<List<TunnelEntity>>) return Failure(listResult.message, listResult.exception, listResult.stackTrace);

    final current = (listResult as Success<List<TunnelEntity>>).data;
    final filtered = current.where((t) => t.id != id).toList();
    return _storage.saveTunnels(filtered);
  }

  @override
  Future<Result<TunnelEntity?>> getById(String id) async {
    final listResult = await loadAll();
    return listResult.fold(
      onSuccess: (tunnels) {
        final match = tunnels.where((t) => t.id == id);
        return Success(match.isNotEmpty ? match.first : null);
      },
      onFailure: (msg, ex, st) => Failure(msg, ex, st),
    );
  }
}
