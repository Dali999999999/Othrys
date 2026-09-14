import 'package:flutter_test/flutter_test.dart';
import 'package:vpsmanager/core/models/docker_container_entity.dart';
import 'package:vpsmanager/core/models/service_entry_entity.dart';
import 'package:vpsmanager/core/models/file_entry_entity.dart';

void main() {
  group('Domain Entities (Phase 2.1)', () {
    test('DockerContainerEntity roundtrip and isRunning', () {
      const container = DockerContainerEntity(
        id: 'c123',
        names: 'nginx-proxy',
        image: 'nginx:alpine',
        status: 'Up 2 hours',
        state: 'running',
        ports: '80->80',
      );

      final json = container.toJson();
      final restored = DockerContainerEntity.fromJson(json);

      expect(restored, equals(container));
      expect(restored.isRunning, isTrue);
    });

    test('ServiceEntryEntity roundtrip and isRunning', () {
      const service = ServiceEntryEntity(
        unit: 'nginx.service',
        load: 'loaded',
        active: 'active',
        sub: 'running',
        description: 'A high performance web server',
      );

      final json = service.toJson();
      final restored = ServiceEntryEntity.fromJson(json);

      expect(restored, equals(service));
      expect(restored.isRunning, isTrue);
    });

    test('FileEntryEntity roundtrip and equality', () {
      final now = DateTime(2026, 9, 11, 20, 0, 0);
      final file = FileEntryEntity(
        name: 'app.log',
        path: '/var/log/app.log',
        isDirectory: false,
        size: 2048,
        modifiedTime: now,
      );

      final json = file.toJson();
      final restored = FileEntryEntity.fromJson(json);

      expect(restored, equals(file));
      expect(restored.isDirectory, isFalse);
      expect(restored.size, 2048);
    });
  });
}
