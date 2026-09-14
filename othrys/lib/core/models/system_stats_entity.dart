/// Live system statistics model capturing CPU, RAM, Swap, Disk and Network metrics.
class SystemOverview {
  final double cpuUsagePercent;
  final double memoryUsagePercent;
  final int memoryUsedBytes;
  final int memoryTotalBytes;
  final int swapUsedBytes;
  final int swapTotalBytes;
  final double diskUsagePercent;
  final int diskUsedBytes;
  final int diskTotalBytes;
  final int rxBytes;
  final int txBytes;
  final int rxBytesPerSec;
  final int txBytesPerSec;
  final String uptime;
  final String osName;
  final String kernel;

  const SystemOverview({
    required this.cpuUsagePercent,
    required this.memoryUsagePercent,
    required this.memoryUsedBytes,
    required this.memoryTotalBytes,
    this.swapUsedBytes = 0,
    this.swapTotalBytes = 0,
    required this.diskUsagePercent,
    required this.diskUsedBytes,
    required this.diskTotalBytes,
    this.rxBytes = 0,
    this.txBytes = 0,
    this.rxBytesPerSec = 0,
    this.txBytesPerSec = 0,
    required this.uptime,
    required this.osName,
    required this.kernel,
  });

  const SystemOverview.empty()
      : this(
          cpuUsagePercent: 0,
          memoryUsagePercent: 0,
          memoryUsedBytes: 0,
          memoryTotalBytes: 1,
          swapUsedBytes: 0,
          swapTotalBytes: 0,
          diskUsagePercent: 0,
          diskUsedBytes: 0,
          diskTotalBytes: 1,
          rxBytes: 0,
          txBytes: 0,
          rxBytesPerSec: 0,
          txBytesPerSec: 0,
          uptime: '---',
          osName: 'Detecting...',
          kernel: '---',
        );

  bool get isEmpty => uptime == '---' && osName == 'Detecting...';
  bool get isNotEmpty => !isEmpty;

  Map<String, dynamic> toJson() => {
        'cpuUsagePercent': cpuUsagePercent,
        'memoryUsagePercent': memoryUsagePercent,
        'memoryUsedBytes': memoryUsedBytes,
        'memoryTotalBytes': memoryTotalBytes,
        'swapUsedBytes': swapUsedBytes,
        'swapTotalBytes': swapTotalBytes,
        'diskUsagePercent': diskUsagePercent,
        'diskUsedBytes': diskUsedBytes,
        'diskTotalBytes': diskTotalBytes,
        'rxBytes': rxBytes,
        'txBytes': txBytes,
        'rxBytesPerSec': rxBytesPerSec,
        'txBytesPerSec': txBytesPerSec,
        'uptime': uptime,
        'osName': osName,
        'kernel': kernel,
      };

  factory SystemOverview.fromJson(Map<String, dynamic> json) => SystemOverview(
        cpuUsagePercent: (json['cpuUsagePercent'] as num?)?.toDouble() ?? 0.0,
        memoryUsagePercent: (json['memoryUsagePercent'] as num?)?.toDouble() ?? 0.0,
        memoryUsedBytes: (json['memoryUsedBytes'] as num?)?.toInt() ?? 0,
        memoryTotalBytes: (json['memoryTotalBytes'] as num?)?.toInt() ?? 1,
        swapUsedBytes: (json['swapUsedBytes'] as num?)?.toInt() ?? 0,
        swapTotalBytes: (json['swapTotalBytes'] as num?)?.toInt() ?? 0,
        diskUsagePercent: (json['diskUsagePercent'] as num?)?.toDouble() ?? 0.0,
        diskUsedBytes: (json['diskUsedBytes'] as num?)?.toInt() ?? 0,
        diskTotalBytes: (json['diskTotalBytes'] as num?)?.toInt() ?? 1,
        rxBytes: (json['rxBytes'] as num?)?.toInt() ?? 0,
        txBytes: (json['txBytes'] as num?)?.toInt() ?? 0,
        rxBytesPerSec: (json['rxBytesPerSec'] as num?)?.toInt() ?? 0,
        txBytesPerSec: (json['txBytesPerSec'] as num?)?.toInt() ?? 0,
        uptime: json['uptime'] as String? ?? '---',
        osName: json['osName'] as String? ?? 'Linux Server',
        kernel: json['kernel'] as String? ?? '---',
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemOverview &&
          runtimeType == other.runtimeType &&
          cpuUsagePercent == other.cpuUsagePercent &&
          memoryUsagePercent == other.memoryUsagePercent &&
          memoryUsedBytes == other.memoryUsedBytes &&
          memoryTotalBytes == other.memoryTotalBytes &&
          diskUsagePercent == other.diskUsagePercent &&
          diskUsedBytes == other.diskUsedBytes &&
          diskTotalBytes == other.diskTotalBytes &&
          uptime == other.uptime &&
          kernel == other.kernel;

  @override
  int get hashCode => Object.hash(
        cpuUsagePercent,
        memoryUsagePercent,
        memoryUsedBytes,
        memoryTotalBytes,
        diskUsagePercent,
        diskUsedBytes,
        diskTotalBytes,
        uptime,
        kernel,
      );
}
