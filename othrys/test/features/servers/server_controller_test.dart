import 'package:flutter_test/flutter_test.dart';
import 'package:vpsmanager/core/network/ssh_session_manager.dart';
import 'package:vpsmanager/core/repositories/server_repository.dart';
import 'package:vpsmanager/core/services/activity_service.dart';
import 'package:vpsmanager/core/repositories/activity_repository.dart';
import 'package:vpsmanager/core/models/activity_log_entity.dart';
import 'package:vpsmanager/core/utils/result.dart';
import 'package:vpsmanager/features/servers/server_controller.dart';

class FakeServerRepository implements ServerRepository {
  final List<ServerEntity> storage = [];

  @override
  Future<Result<List<ServerEntity>>> loadAll() async {
    return Success(List.from(storage));
  }

  @override
  Future<Result<void>> save(ServerEntity server) async {
    final idx = storage.indexWhere((s) => s.id == server.id);
    if (idx >= 0) {
      storage[idx] = server;
    } else {
      storage.add(server);
    }
    return const Success(null);
  }

  @override
  Future<Result<void>> update(ServerEntity server) async {
    return save(server);
  }

  @override
  Future<Result<void>> delete(String id) async {
    storage.removeWhere((s) => s.id == id);
    return const Success(null);
  }

  @override
  Future<Result<ServerEntity?>> getById(String id) async {
    final match = storage.where((s) => s.id == id).firstOrNull;
    return Success(match);
  }
}

class FakeActivityRepository implements ActivityRepository {
  final List<ActivityLogEntity> logs = [];

  @override
  Future<Result<List<ActivityLogEntity>>> loadAll() async {
    return Success(List.from(logs));
  }

  @override
  Future<Result<void>> append(ActivityLogEntity log) async {
    logs.add(log);
    return const Success(null);
  }

  @override
  Future<Result<List<ActivityLogEntity>>> loadPage({int offset = 0, int limit = 50}) async {
    return Success(logs.skip(offset).take(limit).toList());
  }

  @override
  Future<Result<void>> clear() async {
    logs.clear();
    return const Success(null);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeServerRepository fakeRepo;
  late FakeActivityRepository fakeActivityRepo;
  late ActivityService activityService;
  late ServerController controller;

  final testServer = ServerEntity(
    id: 'srv-1',
    name: 'Production VPS',
    host: '192.168.1.100',
    port: 22,
    username: 'root',
    authType: AuthMethod.password,
    password: 'secret',
  );

  setUp(() {
    fakeRepo = FakeServerRepository();
    fakeActivityRepo = FakeActivityRepository();
    activityService = ActivityService(repository: fakeActivityRepo);
    controller = ServerController(
      repository: fakeRepo,
      sshManager: SSHSessionManager.instance,
      activityService: activityService,
    );
  });

  tearDown(() {
    activityService.dispose();
  });

  test('ServerController initial state is empty', () {
    expect(controller.state.servers, isEmpty);
    expect(controller.state.selectedServer, isNull);
    expect(controller.state.isLoading, isFalse);
  });

  test('ServerController saves server and reloads list', () async {
    final saveResult = await controller.saveServer(testServer);
    expect(saveResult.isSuccess, isTrue);
    expect(controller.state.servers.length, 1);
    expect(controller.state.selectedServer?.name, 'Production VPS');
  });

  test('ServerController selects server properly', () async {
    await controller.saveServer(testServer);
    final secondServer = testServer.copyWith(id: 'srv-2', name: 'Staging');
    await controller.saveServer(secondServer);

    controller.selectServer(secondServer);
    expect(controller.state.selectedServer?.id, 'srv-2');
  });

  test('ServerController deletes server correctly', () async {
    await controller.saveServer(testServer);
    expect(controller.state.servers.length, 1);

    final deleteResult = await controller.deleteServer(testServer.id);
    expect(deleteResult.isSuccess, isTrue);
    expect(controller.state.servers, isEmpty);
  });
}
