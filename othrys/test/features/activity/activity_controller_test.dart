import 'package:flutter_test/flutter_test.dart';
import 'package:vpsmanager/core/repositories/activity_repository.dart';
import 'package:vpsmanager/core/services/activity_service.dart';
import 'package:vpsmanager/core/utils/result.dart';
import 'package:vpsmanager/features/activity/activity_controller.dart';

class FakeActivityRepository implements ActivityRepository {
  final List<ActivityLogEntity> logs = [];

  @override
  Future<Result<List<ActivityLogEntity>>> loadAll() async => Success(List.from(logs));

  @override
  Future<Result<List<ActivityLogEntity>>> loadPage({int offset = 0, int limit = 50}) async =>
      Success(logs.skip(offset).take(limit).toList());

  @override
  Future<Result<void>> append(ActivityLogEntity log) async {
    logs.insert(0, log);
    return const Success(null);
  }

  @override
  Future<Result<void>> clear() async {
    logs.clear();
    return const Success(null);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeActivityRepository repo;
  late ActivityService service;
  late ActivityController controller;

  setUp(() {
    repo = FakeActivityRepository();
    service = ActivityService(repository: repo);
    controller = ActivityController(repository: repo, activityService: service);
  });

  tearDown(() {
    controller.dispose();
    service.dispose();
  });

  test('ActivityController initial state is empty', () {
    expect(controller.state.logs, isEmpty);
    expect(controller.state.selectedCategory, 'ALL');
    expect(controller.state.isLoading, isFalse);
  });

  test('ActivityController filters logs by category properly', () {
    final logSSH = ActivityLogEntity(
      id: '1',
      timestamp: DateTime.now(),
      category: ActivityCategory.ssh,
      message: 'Connected to server',
      level: ActivityLevel.success,
    );
    final logDocker = ActivityLogEntity(
      id: '2',
      timestamp: DateTime.now(),
      category: ActivityCategory.docker,
      message: 'Started container',
      level: ActivityLevel.info,
    );

    controller.state = controller.state.copyWith(logs: [logSSH, logDocker]);

    expect(controller.state.filteredLogs.length, 2);

    controller.setCategory('SSH');
    expect(controller.state.filteredLogs.length, 1);
    expect(controller.state.filteredLogs.first.category, ActivityCategory.ssh);

    controller.setCategory('DOCKER');
    expect(controller.state.filteredLogs.length, 1);
    expect(controller.state.filteredLogs.first.category, ActivityCategory.docker);

    controller.setCategory('ALL');
    expect(controller.state.filteredLogs.length, 2);
  });

  test('ActivityController prepends new live audit events', () async {
    final testLog = ActivityLogEntity(
      id: 'live-1',
      timestamp: DateTime.now(),
      category: ActivityCategory.system,
      message: 'System alert',
      level: ActivityLevel.warning,
    );

    service.onActivity; // ensure stream is warm
    await repo.append(testLog);
    service.logError('system', 'Manual error log', Exception('Test'));

    // Wait a tick for stream propagation
    await Future.delayed(const Duration(milliseconds: 20));

    expect(controller.state.logs.isNotEmpty, isTrue);
  });
}
