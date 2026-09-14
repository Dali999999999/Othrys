import '../models/server_entity.dart';
import '../storage/local_storage_service.dart';
import '../utils/result.dart';

/// Contract defining persistence operations for [ServerEntity].
abstract class ServerRepository {
  /// Loads all servers with secrets decrypted in memory.
  Future<Result<List<ServerEntity>>> loadAll();

  /// Saves or creates a server profile.
  Future<Result<void>> save(ServerEntity server);

  /// Updates an existing server profile.
  Future<Result<void>> update(ServerEntity server);

  /// Deletes a server profile by its unique ID.
  Future<Result<void>> delete(String id);

  /// Fetches a single server profile by its ID.
  Future<Result<ServerEntity?>> getById(String id);
}

/// Local implementation of [ServerRepository] storing encrypted profiles in OS app support directory.
class LocalServerRepository implements ServerRepository {
  final LocalStorageService _storage;

  LocalServerRepository({LocalStorageService? storage})
      : _storage = storage ?? LocalStorageService.instance;

  @override
  Future<Result<List<ServerEntity>>> loadAll() => _storage.loadServers();

  @override
  Future<Result<void>> save(ServerEntity server) async {
    final listResult = await loadAll();
    if (listResult is Failure<List<ServerEntity>>) return Failure(listResult.message, listResult.exception, listResult.stackTrace);

    final current = (listResult as Success<List<ServerEntity>>).data;
    final index = current.indexWhere((s) => s.id == server.id);
    final List<ServerEntity> updated;

    if (index >= 0) {
      updated = List.from(current)..[index] = server;
    } else {
      updated = [...current, server];
    }

    return _storage.saveServers(updated);
  }

  @override
  Future<Result<void>> update(ServerEntity server) => save(server);

  @override
  Future<Result<void>> delete(String id) async {
    final listResult = await loadAll();
    if (listResult is Failure<List<ServerEntity>>) return Failure(listResult.message, listResult.exception, listResult.stackTrace);

    final current = (listResult as Success<List<ServerEntity>>).data;
    final filtered = current.where((s) => s.id != id).toList();
    return _storage.saveServers(filtered);
  }

  @override
  Future<Result<ServerEntity?>> getById(String id) async {
    final listResult = await loadAll();
    return listResult.fold(
      onSuccess: (servers) {
        final match = servers.where((s) => s.id == id);
        return Success(match.isNotEmpty ? match.first : null);
      },
      onFailure: (msg, ex, st) => Failure(msg, ex, st),
    );
  }
}
