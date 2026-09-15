import 'package:flutter_test/flutter_test.dart';
import 'package:othrys/core/models/activity_log_entity.dart';

void main() {
  group('ActivityLogEntity', () {
    test('JSON round-trip preserves all fields', () {
      final now = DateTime.now();
      final log = ActivityLogEntity(
        id: 'act-1',
        serverId: 'srv-10',
        timestamp: now,
        level: ActivityLevel.success,
        category: ActivityCategory.ssh,
        message: 'Connected to server',
        metadata: {'ip': '1.2.3.4'},
      );

      final json = log.toJson();
      final reconstructed = ActivityLogEntity.fromJson(json);

      expect(reconstructed.id, 'act-1');
      expect(reconstructed.serverId, 'srv-10');
      expect(reconstructed.level, ActivityLevel.success);
      expect(reconstructed.category, ActivityCategory.ssh);
      expect(reconstructed.message, 'Connected to server');
      expect(reconstructed.metadata?['ip'], '1.2.3.4');
      expect(reconstructed, equals(log));
    });

    test('fromJson handles corrupted timestamp gracefully', () {
      final json = {
        'id': 'act-2',
        'timestamp': 'invalid-date-string',
        'level': 'warning',
        'category': 'docker',
        'message': 'Container restart',
      };

      final log = ActivityLogEntity.fromJson(json);
      expect(log.id, 'act-2');
      expect(log.level, ActivityLevel.warning);
      expect(log.category, ActivityCategory.docker);
      expect(log.timestamp, isNotNull);
    });
  });
}
