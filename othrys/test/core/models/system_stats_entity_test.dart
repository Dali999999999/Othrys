import 'package:flutter_test/flutter_test.dart';
import 'package:othrys/core/models/system_stats_entity.dart';

void main() {
  group('SystemOverview', () {
    test('JSON round-trip preserves all fields', () {
      const stats = SystemOverview(
        cpuUsagePercent: 34.5,
        memoryUsagePercent: 62.1,
        memoryUsedBytes: 4000000000,
        memoryTotalBytes: 8000000000,
        swapUsedBytes: 500000000,
        swapTotalBytes: 2000000000,
        diskUsagePercent: 45.0,
        diskUsedBytes: 20000000000,
        diskTotalBytes: 50000000000,
        rxBytes: 102400,
        txBytes: 204800,
        rxBytesPerSec: 5000,
        txBytesPerSec: 8000,
        uptime: '12 days, 4 hours',
        osName: 'Ubuntu 24.04 LTS',
        kernel: '6.8.0-generic',
      );

      final json = stats.toJson();
      final reconstructed = SystemOverview.fromJson(json);

      expect(reconstructed.cpuUsagePercent, 34.5);
      expect(reconstructed.memoryUsedBytes, 4000000000);
      expect(reconstructed.memoryTotalBytes, 8000000000);
      expect(reconstructed.swapUsedBytes, 500000000);
      expect(reconstructed.uptime, '12 days, 4 hours');
      expect(reconstructed.kernel, '6.8.0-generic');
      expect(reconstructed, equals(stats));
    });

    test('empty factory creates zeroed overview', () {
      final empty = SystemOverview.empty();
      expect(empty.cpuUsagePercent, 0.0);
      expect(empty.memoryUsedBytes, 0);
      expect(empty.diskUsedBytes, 0);
      expect(empty.uptime, '---');
    });
  });
}
