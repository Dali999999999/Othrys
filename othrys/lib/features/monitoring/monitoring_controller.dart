import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/system_stats_entity.dart';
import '../../core/network/is_ssh_session_manager.dart';
import '../../core/providers/core_providers.dart';
import '../../core/utils/logger.dart';

/// Telemetry parsing result holding the computed overview along with raw CPU jiffies.
class ParsedTelemetry {
  final SystemOverview overview;
  final int? cpuTotal;
  final int? cpuIdle;

  const ParsedTelemetry({
    required this.overview,
    this.cpuTotal,
    this.cpuIdle,
  });
}

/// State representation for live system monitoring dashboard.
class MonitoringState {
  final SystemOverview overview;
  final List<FlSpot> cpuHistory;
  final bool isPolling;
  final bool isLoading;
  final String? error;
  final int tick;

  const MonitoringState({
    this.overview = const SystemOverview.empty(),
    this.cpuHistory = const [],
    this.isPolling = false,
    this.isLoading = false,
    this.error,
    this.tick = 0,
  });

  MonitoringState copyWith({
    SystemOverview? overview,
    List<FlSpot>? cpuHistory,
    bool? isPolling,
    bool? isLoading,
    String? error,
    int? tick,
  }) {
    return MonitoringState(
      overview: overview ?? this.overview,
      cpuHistory: cpuHistory ?? this.cpuHistory,
      isPolling: isPolling ?? this.isPolling,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      tick: tick ?? this.tick,
    );
  }
}

/// Controller managing polling lifecycle and metric trend buffers for a target VPS.
class MonitoringController extends StateNotifier<MonitoringState> {
  final ISSHSessionManager sshManager;
  Timer? _pollingTimer;
  String? _currentSessionId;
  int? _prevCpuTotal;
  int? _prevCpuIdle;

  MonitoringController({required this.sshManager})
      : super(const MonitoringState());

  /// Sets up automatic periodic telemetry collection for [sessionId].
  void startPolling(String sessionId, {Duration interval = const Duration(seconds: 3)}) {
    _currentSessionId = sessionId;
    _prevCpuTotal = null;
    _prevCpuIdle = null;
    state = state.copyWith(isPolling: true, isLoading: state.overview == const SystemOverview.empty());
    fetchStats();

    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(interval, (_) {
      fetchStats();
    });
  }

  /// Halts active polling timer.
  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _prevCpuTotal = null;
    _prevCpuIdle = null;
    state = state.copyWith(isPolling: false);
  }

  /// Performs a single telemetry snapshot fetch.
  Future<void> fetchStats() async {
    final sessionId = _currentSessionId;
    if (sessionId == null) return;

    try {
      final cmd = 'echo "===UPTIME===" && uptime && '
          'echo "===CPU===" && head -n 1 /proc/stat && '
          'echo "===MEM===" && free -b && '
          'echo "===DISK===" && df -P -k / && '
          'echo "===OS===" && uname -s -r';

      final output = await sshManager.executeCommand(sessionId, cmd);
      final telemetry = parseTelemetry(
        output,
        prevCpuTotal: _prevCpuTotal,
        prevCpuIdle: _prevCpuIdle,
      );

      _prevCpuTotal = telemetry.cpuTotal;
      _prevCpuIdle = telemetry.cpuIdle;

      final nextTick = state.tick + 1;
      final history = List<FlSpot>.from(state.cpuHistory)
        ..add(FlSpot(nextTick.toDouble(), telemetry.overview.cpuUsagePercent));

      if (history.length > 20) {
        history.removeAt(0);
      }

      state = state.copyWith(
        overview: telemetry.overview,
        cpuHistory: history,
        isLoading: false,
        error: null,
        tick: nextTick,
      );
    } catch (e, st) {
      AppLogger.instance.error('MonitoringController', 'Failed to fetch metrics: $e', e, st);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to poll server metrics: $e',
      );
    }
  }

  /// Legacy helper for testing compatibility.
  static SystemOverview parseOverview(String rawOutput) {
    return parseTelemetry(rawOutput).overview;
  }

  /// Parses raw command outputs into a [ParsedTelemetry] entity with exact disk, RAM and CPU metrics.
  static ParsedTelemetry parseTelemetry(
    String rawOutput, {
    int? prevCpuTotal,
    int? prevCpuIdle,
  }) {
    final lines = rawOutput.split('\n');

    final sections = <String, List<String>>{};
    String currentSection = 'DEFAULT';
    sections[currentSection] = [];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.startsWith('===') && trimmed.endsWith('===')) {
        currentSection = trimmed.replaceAll('=', '').trim();
        sections[currentSection] = [];
      } else {
        sections[currentSection]?.add(line);
      }
    }

    final hasSections = sections.length > 1;
    final allLines = lines.map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

    double cpuPercent = 0.0;
    int? currentCpuTotal;
    int? currentCpuIdle;
    int memUsed = 0;
    int memTotal = 1;
    int swapUsed = 0;
    int swapTotal = 0;
    int diskUsed = 0;
    int diskTotal = 1;
    String uptime = 'Unknown';
    String osKernel = 'Linux';

    try {
      // 1. Uptime & Load Average
      final uptimeLines = hasSections ? (sections['UPTIME'] ?? []) : allLines;
      for (final line in uptimeLines) {
        if (line.contains('load average:')) {
          final loadMatch = RegExp(r'load average:\s*([0-9.]+)').firstMatch(line);
          if (loadMatch != null) {
            final load = double.tryParse(loadMatch.group(1) ?? '0') ?? 0;
            cpuPercent = (load * 100).clamp(0.0, 100.0);
          }
          if (line.contains('up ')) {
            uptime = line.split('up ')[1].split(',')[0].trim();
          }
          break;
        }
      }

      // 2. CPU Jiffies (Instantaneous % from /proc/stat)
      final cpuLines = hasSections ? (sections['CPU'] ?? []) : allLines;
      for (final line in cpuLines) {
        final trimmed = line.trim();
        if (trimmed.startsWith('cpu ') || trimmed.startsWith('cpu0 ')) {
          final parts = trimmed.split(RegExp(r'\s+'));
          if (parts.length >= 5) {
            final user = int.tryParse(parts[1]) ?? 0;
            final nice = int.tryParse(parts[2]) ?? 0;
            final system = int.tryParse(parts[3]) ?? 0;
            final idle = int.tryParse(parts[4]) ?? 0;
            final iowait = parts.length > 5 ? (int.tryParse(parts[5]) ?? 0) : 0;
            final irq = parts.length > 6 ? (int.tryParse(parts[6]) ?? 0) : 0;
            final softirq = parts.length > 7 ? (int.tryParse(parts[7]) ?? 0) : 0;
            final steal = parts.length > 8 ? (int.tryParse(parts[8]) ?? 0) : 0;

            final total = user + nice + system + idle + iowait + irq + softirq + steal;
            final idleTotal = idle + iowait;

            currentCpuTotal = total;
            currentCpuIdle = idleTotal;

            if (prevCpuTotal != null && prevCpuIdle != null) {
              final totalDelta = total - prevCpuTotal;
              final idleDelta = idleTotal - prevCpuIdle;
              if (totalDelta > 0) {
                final usage = ((totalDelta - idleDelta) / totalDelta) * 100.0;
                cpuPercent = usage.clamp(0.0, 100.0);
              }
            }
          }
          break;
        }
      }

      // 3. Memory & Swap
      final memLines = hasSections ? (sections['MEM'] ?? []) : allLines;
      for (final line in memLines) {
        final trimmed = line.trim();
        if (trimmed.startsWith('Mem:')) {
          final parts = trimmed.split(RegExp(r'\s+'));
          if (parts.length >= 3) {
            memTotal = int.tryParse(parts[1]) ?? 1;
            memUsed = int.tryParse(parts[2]) ?? 0;
          }
        } else if (trimmed.startsWith('Swap:')) {
          final parts = trimmed.split(RegExp(r'\s+'));
          if (parts.length >= 3) {
            swapTotal = int.tryParse(parts[1]) ?? 0;
            swapUsed = int.tryParse(parts[2]) ?? 0;
          }
        }
      }

      // 4. Disk Usage for root partition ('/')
      final diskLines = hasSections ? (sections['DISK'] ?? []) : allLines;
      for (final line in diskLines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith('Filesystem')) continue;
        final parts = trimmed.split(RegExp(r'\s+'));
        // Guaranteed root partition: mounted on '/' (last element)
        if (parts.length >= 4 && parts.last == '/') {
          // df -P -k produces: Filesystem 1024-blocks Used Available Capacity Mounted on
          final totalKb = int.tryParse(parts[1]) ?? 1;
          final usedKb = int.tryParse(parts[2]) ?? 0;
          diskTotal = totalKb * 1024;
          diskUsed = usedKb * 1024;
          break;
        }
      }

      // 5. OS & Kernel
      if (hasSections) {
        final osLines = sections['OS'] ?? [];
        for (final line in osLines) {
          final trimmed = line.trim();
          if (trimmed.isNotEmpty && !trimmed.startsWith('===')) {
            osKernel = trimmed;
            break;
          }
        }
      } else if (allLines.isNotEmpty) {
        osKernel = allLines.last;
      }
    } catch (e) {
      AppLogger.instance.warn('MonitoringController', 'Error parsing system overview: $e');
    }

    final double diskPercent = diskTotal > 0
        ? double.parse(((diskUsed / diskTotal) * 100).toStringAsFixed(1))
        : 0.0;
    final double memPercent = memTotal > 0
        ? double.parse(((memUsed / memTotal) * 100).toStringAsFixed(1))
        : 0.0;

    return ParsedTelemetry(
      overview: SystemOverview(
        cpuUsagePercent: double.parse(cpuPercent.toStringAsFixed(1)),
        memoryUsagePercent: memPercent,
        memoryUsedBytes: memUsed,
        memoryTotalBytes: memTotal,
        swapUsedBytes: swapUsed,
        swapTotalBytes: swapTotal,
        diskUsagePercent: diskPercent,
        diskUsedBytes: diskUsed,
        diskTotalBytes: diskTotal,
        uptime: uptime,
        osName: 'Linux Server',
        kernel: osKernel,
      ),
      cpuTotal: currentCpuTotal,
      cpuIdle: currentCpuIdle,
    );
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}

/// Auto-disposed provider to automatically stop polling when leaving the view.
final monitoringControllerProvider =
    StateNotifierProvider.autoDispose<MonitoringController, MonitoringState>((ref) {
  final controller = MonitoringController(
    sshManager: ref.watch(sshSessionManagerProvider),
  );
  ref.onDispose(() {
    controller.stopPolling();
  });
  return controller;
});
