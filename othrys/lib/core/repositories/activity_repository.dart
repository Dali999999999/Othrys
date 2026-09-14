import '../models/activity_log_entity.dart';
import '../storage/local_storage_service.dart';
import '../utils/result.dart';

/// Contract defining persistence operations for [ActivityLogEntity].
abstract class ActivityRepository {
  /// Loads all activity logs.
  Future<Result<List<ActivityLogEntity>>> loadAll();

  /// Loads paginated activity logs.
  Future<Result<List<ActivityLogEntity>>> loadPage({int offset = 0, int limit = 50});

  /// Appends a new activity log entry with automatic rolling window purge.
  Future<Result<void>> append(ActivityLogEntity log);

  /// Clears all activity logs.
  Future<Result<void>> clear();
}

/// Local implementation of [ActivityRepository].
class LocalActivityRepository implements ActivityRepository {
  final LocalStorageService _storage;

  LocalActivityRepository({LocalStorageService? storage})
      : _storage = storage ?? LocalStorageService.instance;

  @override
  Future<Result<List<ActivityLogEntity>>> loadAll() async {
    try {
      final list = await _storage.loadActivityLogs(limit: 1000);
      return Success(list);
    } catch (e, st) {
      return Failure('Failed to load activity logs', e, st);
    }
  }

  @override
  Future<Result<List<ActivityLogEntity>>> loadPage({int offset = 0, int limit = 50}) async {
    final allResult = await loadAll();
    return allResult.fold(
      onSuccess: (logs) {
        if (offset >= logs.length) return const Success([]);
        final paged = logs.skip(offset).take(limit).toList();
        return Success(paged);
      },
      onFailure: (msg, ex, st) => Failure(msg, ex, st),
    );
  }

  @override
  Future<Result<void>> append(ActivityLogEntity log) async {
    try {
      await _storage.appendActivityLog(log);
      return const Success(null);
    } catch (e, st) {
      return Failure('Failed to append activity log', e, st);
    }
  }

  @override
  Future<Result<void>> clear() async {
    try {
      await _storage.clearActivityLogs();
      return const Success(null);
    } catch (e, st) {
      return Failure('Failed to clear activity logs', e, st);
    }
  }
}
