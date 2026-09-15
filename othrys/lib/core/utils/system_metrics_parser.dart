import '../models/system_stats_entity.dart';
import 'logger.dart';

/// Unified parser for Linux system telemetry and metrics (uptime, free, df, uname).
class SystemMetricsParser {
  SystemMetricsParser._();

  /// Parses the multi-command system overview output:
  /// `uptime && free -b && df -k / && uname -s -r`
  static SystemOverview parseOverview(String output) {
    final lines = output.trim().split('\n');

    double cpuPercent = 0.0;
    int memUsed = 0;
    int memTotal = 1;
    int swapUsed = 0;
    int swapTotal = 0;
    int diskUsed = 0;
    int diskTotal = 1;
    String uptime = 'Unknown';
    String osKernel = 'Linux';

    try {
      // 1. Uptime and load average
      if (lines.isNotEmpty) {
        final uptimeLine = lines.firstWhere((l) => l.contains('load average:') || l.contains('up '), orElse: () => lines[0]);
        final loadMatch = RegExp(r'load average:\s*([0-9.]+)').firstMatch(uptimeLine);
        if (loadMatch != null) {
          final load = double.tryParse(loadMatch.group(1) ?? '0') ?? 0;
          cpuPercent = (load * 100).clamp(0.0, 100.0);
        }
        if (uptimeLine.contains('up ')) {
          uptime = uptimeLine.split('up ')[1].split(',')[0].trim();
        }
      }

      // 2. Memory & Swap from `free -b`
      final memLine = lines.firstWhere((l) => l.trim().startsWith('Mem:'), orElse: () => '');
      if (memLine.isNotEmpty) {
        final parts = memLine.trim().split(RegExp(r'\s+'));
        if (parts.length >= 3) {
          memTotal = int.tryParse(parts[1]) ?? 1;
          memUsed = int.tryParse(parts[2]) ?? 0;
        }
      }

      final swapLine = lines.firstWhere((l) => l.trim().startsWith('Swap:'), orElse: () => '');
      if (swapLine.isNotEmpty) {
        final parts = swapLine.trim().split(RegExp(r'\s+'));
        if (parts.length >= 3) {
          swapTotal = int.tryParse(parts[1]) ?? 0;
          swapUsed = int.tryParse(parts[2]) ?? 0;
        }
      }

      // 3. Disk from `df -k /`
      final diskLine = lines.firstWhere((l) => l.contains('/'), orElse: () => '');
      if (diskLine.isNotEmpty) {
        final parts = diskLine.trim().split(RegExp(r'\s+'));
        if (parts.length >= 4) {
          diskTotal = (int.tryParse(parts[1]) ?? 1) * 1024;
          diskUsed = (int.tryParse(parts[2]) ?? 0) * 1024;
        }
      }

      // 4. Kernel / OS info
      final kernelLine = lines.lastWhere((l) => !l.startsWith('Mem:') && !l.startsWith('Swap:') && !l.contains('/'), orElse: () => '');
      if (kernelLine.isNotEmpty) {
        osKernel = kernelLine.trim();
      }
    } catch (e) {
      AppLogger.instance.warn('SystemMetricsParser', 'Error parsing system metrics: $e');
    }

    final safeMemTotal = memTotal > 0 ? memTotal : 1;
    final safeDiskTotal = diskTotal > 0 ? diskTotal : 1;

    return SystemOverview(
      cpuUsagePercent: double.parse(cpuPercent.toStringAsFixed(1)),
      memoryUsagePercent: double.parse(((memUsed / safeMemTotal) * 100).toStringAsFixed(1)),
      memoryUsedBytes: memUsed,
      memoryTotalBytes: safeMemTotal,
      swapUsedBytes: swapUsed,
      swapTotalBytes: swapTotal,
      diskUsagePercent: double.parse(((diskUsed / safeDiskTotal) * 100).toStringAsFixed(1)),
      diskUsedBytes: diskUsed,
      diskTotalBytes: safeDiskTotal,
      uptime: uptime,
      osName: 'Linux Server',
      kernel: osKernel,
    );
  }
}
