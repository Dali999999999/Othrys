import 'package:flutter_test/flutter_test.dart';
import 'package:vpsmanager/core/network/ssh_session_manager.dart';
import 'package:vpsmanager/core/utils/result.dart';
import 'package:vpsmanager/features/docker/docker_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('DockerState initial values are correct', () {
    const state = DockerState();
    expect(state.containers, isEmpty);
    expect(state.isLoading, isFalse);
    expect(state.error, isNull);
  });

  test('DockerContainerEntity parses JSON from docker ps correctly', () {
    final json = {
      'ID': 'c1a2b3c4',
      'Names': 'nginx_proxy',
      'Image': 'nginx:alpine',
      'Status': 'Up 4 hours',
      'State': 'running',
      'Ports': '0.0.0.0:80->80/tcp',
    };

    final container = DockerContainerEntity.fromJson(json);
    expect(container.id, 'c1a2b3c4');
    expect(container.names, 'nginx_proxy');
    expect(container.isRunning, isTrue);
    expect(container.ports, '0.0.0.0:80->80/tcp');
  });

  test('DockerState copyWith updates properly', () {
    const initial = DockerState();
    const c = DockerContainerEntity(
      id: '123',
      names: 'redis',
      image: 'redis:latest',
      status: 'Up',
      state: 'running',
      ports: '6379/tcp',
    );

    final updated = initial.copyWith(
      containers: [c],
      isLoading: true,
      error: 'Test error',
    );

    expect(updated.containers.length, 1);
    expect(updated.isLoading, isTrue);
    expect(updated.error, 'Test error');
  });

  group('DockerController - Security & Compose', () {
    late _MockSSHSessionManager mockSsh;
    late DockerController controller;

    setUp(() {
      mockSsh = _MockSSHSessionManager();
      controller = DockerController(sshManager: mockSsh);
    });

    test('runComposeAction executes safe escaped compose command', () async {
      final res = await controller.runComposeAction('sess-1', '/opt/my_stack', 'up -d');
      expect(res.isSuccess, isTrue);
      expect(
        mockSsh.executedCommands.any((c) => c == "cd '/opt/my_stack' && docker 'compose' 'up' '-d'"),
        isTrue,
      );
    });

    test('runComposeAction rejects dangerous path with shell injection', () async {
      final res = await controller.runComposeAction('sess-1', '/opt/app; reboot', 'up -d');
      expect(res.isFailure, isTrue);
      expect((res as Failure).message, contains('Malicious shell sequence'));
      expect(mockSsh.executedCommands, isEmpty);
    });

    test('runComposeAction rejects disallowed compose action', () async {
      final res = await controller.runComposeAction('sess-1', '/opt/app', 'exec evil_command');
      expect(res.isFailure, isTrue);
      expect((res as Failure).message, contains('Disallowed compose action'));
      expect(mockSsh.executedCommands, isEmpty);
    });

    test('runComposeAction rejects dangerous token in action arguments', () async {
      final res = await controller.runComposeAction('sess-1', '/opt/app', 'up -d; rm -rf /');
      expect(res.isFailure, isTrue);
      expect((res as Failure).message, contains('Dangerous token detected'));
      expect(mockSsh.executedCommands, isEmpty);
    });
  });
}

class _MockSSHSessionManager extends Fake implements SSHSessionManager {
  final List<String> executedCommands = [];
  String output = 'OK';

  @override
  Future<String> executeCommand(String sessionId, String command, {bool runInPty = false}) async {
    executedCommands.add(command);
    return output;
  }
}
