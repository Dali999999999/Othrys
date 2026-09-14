import 'package:flutter_test/flutter_test.dart';
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
}
