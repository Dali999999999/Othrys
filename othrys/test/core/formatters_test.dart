import 'package:flutter_test/flutter_test.dart';
import 'package:vpsmanager/core/utils/formatters.dart';

void main() {
  group('Formatters', () {
    test('formatBytes formats bytes into human readable binary units', () {
      expect(Formatters.formatBytes(0), '0 B');
      expect(Formatters.formatBytes(512), '512.0 B');
      expect(Formatters.formatBytes(1024), '1.0 KB');
      expect(Formatters.formatBytes(1048576), '1.0 MB');
      expect(Formatters.formatBytes(1073741824), '1.0 GB');
    });

    test('formatDuration formats Duration into readable uptime', () {
      expect(Formatters.formatDuration(const Duration(seconds: 45)), '0m');
      expect(Formatters.formatDuration(const Duration(minutes: 5, seconds: 12)), '5m');
      expect(Formatters.formatDuration(const Duration(hours: 3, minutes: 20)), '3h 20m');
      expect(Formatters.formatDuration(const Duration(days: 2, hours: 5, minutes: 10)), '2d 5h 10m');
    });

    test('formatDateTime formats DateTime object', () {
      final dt = DateTime(2026, 9, 11, 14, 30, 0);
      expect(Formatters.formatDateTime(dt), '2026-09-11 14:30:00');
    });
  });
}
