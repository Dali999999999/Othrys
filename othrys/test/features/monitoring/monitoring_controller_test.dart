import 'package:flutter_test/flutter_test.dart';
import 'package:vpsmanager/core/network/ssh_session_manager.dart';
import 'package:vpsmanager/features/monitoring/monitoring_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('MonitoringController initial state has empty overview and zero spots', () {
    final controller = MonitoringController(sshManager: SSHSessionManager.instance);
    expect(controller.state.overview.cpuUsagePercent, 0.0);
    expect(controller.state.cpuHistory, isEmpty);
    expect(controller.state.isPolling, isFalse);
    expect(controller.state.isLoading, isFalse);
  });

  test('MonitoringController.parseOverview accurately extracts Linux telemetry from tagged sections', () {
    const rawOutput = '''
===UPTIME===
 00:09:52 up 67 days, 14:12,  1 user,  load average: 0.15, 0.10, 0.05
===CPU===
cpu  225500 3400 229000 22625563 62900 1270 4560 0 0 0
===MEM===
               total        used        free      shared  buff/cache   available
Mem:      8248565760   834789376  5678120960   102400000  1735655424  7123456789
Swap:     2147483648           0  2147483648
===DISK===
Filesystem     1024-blocks      Used Available Capacity Mounted on
/dev/sda1         41251136  15823400  23311352      41% /
===OS===
Linux 6.8.0-134-generic
''';

    final overview = MonitoringController.parseOverview(rawOutput);

    expect(overview.uptime, '67 days');
    expect(overview.memoryTotalBytes, 8248565760);
    expect(overview.memoryUsedBytes, 834789376);
    expect(overview.memoryUsagePercent, closeTo(10.1, 0.1));
    expect(overview.swapTotalBytes, 2147483648);
    expect(overview.swapUsedBytes, 0);
    // Crucial check: df is parsed, NOT buff/cache
    expect(overview.diskTotalBytes, 41251136 * 1024);
    expect(overview.diskUsedBytes, 15823400 * 1024);
    expect(overview.diskUsagePercent, closeTo(38.4, 0.1));
    expect(overview.kernel, 'Linux 6.8.0-134-generic');
  });

  test('MonitoringController.parseTelemetry computes instantaneous CPU delta between ticks', () {
    const tick1 = '''
===CPU===
cpu  1000 0 1000 8000 0 0 0 0 0 0
''';
    final result1 = MonitoringController.parseTelemetry(tick1);
    expect(result1.cpuTotal, 10000);
    expect(result1.cpuIdle, 8000);

    // 100 total units elapsed: 50 active, 50 idle => 50% CPU
    const tick2 = '''
===CPU===
cpu  1030 0 1020 8050 0 0 0 0 0 0
''';
    final result2 = MonitoringController.parseTelemetry(
      tick2,
      prevCpuTotal: result1.cpuTotal,
      prevCpuIdle: result1.cpuIdle,
    );
    expect(result2.overview.cpuUsagePercent, 50.0);
  });

  test('MonitoringController.parseOverview legacy fallback format compatibility', () {
    const legacyOutput = '''
 14:32:10 up 12 days,  3:45,  2 users,  load average: 0.45, 0.52, 0.60
Mem:     16777216    8388608    4194304     1048576    4194304    7340032
/dev/sda1        104857600  41943040  62914560  40% /
Linux 5.15.0-91-generic
''';

    final overview = MonitoringController.parseOverview(legacyOutput);

    expect(overview.cpuUsagePercent, 45.0);
    expect(overview.uptime, '12 days');
    expect(overview.memoryTotalBytes, 16777216);
    expect(overview.memoryUsedBytes, 8388608);
    expect(overview.diskTotalBytes, 104857600 * 1024);
    expect(overview.diskUsedBytes, 41943040 * 1024);
    expect(overview.kernel, 'Linux 5.15.0-91-generic');
  });

  test('MonitoringController stopPolling resets isPolling flag', () {
    final controller = MonitoringController(sshManager: SSHSessionManager.instance);
    controller.stopPolling();
    expect(controller.state.isPolling, isFalse);
  });
}
