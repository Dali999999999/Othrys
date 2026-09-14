import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/activity_log_entity.dart';
import '../../core/repositories/activity_repository.dart';
import '../../core/services/activity_service.dart';
import '../servers/server_controller.dart';

export '../../core/models/activity_log_entity.dart';

/// State representation for historical and live audit event streams.
class ActivityState {
  final List<ActivityLogEntity> logs;
  final String selectedCategory;
  final bool isLoading;
  final String? error;

  const ActivityState({
    this.logs = const [],
    this.selectedCategory = 'ALL',
    this.isLoading = false,
    this.error,
  });

  List<ActivityLogEntity> get filteredLogs {
    if (selectedCategory == 'ALL') return logs;
    return logs.where((l) => l.category.name.toUpperCase() == selectedCategory.toUpperCase()).toList();
  }

  ActivityState copyWith({
    List<ActivityLogEntity>? logs,
    String? selectedCategory,
    bool? isLoading,
    String? error,
  }) {
    return ActivityState(
      logs: logs ?? this.logs,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Controller synchronizing historical log entries and real-time broadcast events.
class ActivityController extends StateNotifier<ActivityState> {
  final ActivityRepository repository;
  final ActivityService? activityService;
  StreamSubscription<ActivityLogEntity>? _streamSubscription;

  ActivityController({
    required this.repository,
    this.activityService,
  }) : super(const ActivityState()) {
    loadLogs();
    _subscribeToLiveLogs();
  }

  void _subscribeToLiveLogs() {
    if (activityService == null) return;
    _streamSubscription = activityService!.onActivity.listen((newLog) {
      state = state.copyWith(logs: [newLog, ...state.logs]);
    });
  }

  /// Reloads audit logs from persistent repository.
  Future<void> loadLogs() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await repository.loadAll();
    result.fold(
      onSuccess: (list) {
        state = state.copyWith(logs: list, isLoading: false);
      },
      onFailure: (msg, ex, st) {
        state = state.copyWith(isLoading: false, error: msg);
      },
    );
  }

  /// Updates current active category filter.
  void setCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }
}

/// Riverpod provider for the Activity controller.
final activityControllerProvider =
    StateNotifierProvider.autoDispose<ActivityController, ActivityState>((ref) {
  return ActivityController(
    repository: ref.watch(activityRepositoryProvider),
    activityService: ref.watch(activityServiceProvider),
  );
});
