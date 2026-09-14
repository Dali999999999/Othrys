import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/utils/formatters.dart';
import '../../core/l10n/l10n.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_icons.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../shared/widgets/app_badge.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_metric_card.dart';
import '../../shared/widgets/connection_guard.dart';
import '../servers/server_controller.dart';
import 'monitoring_controller.dart';

/// Presentation-only dashboard displaying real-time system metrics (CPU, RAM, Disk).
class MonitoringView extends ConsumerStatefulWidget {
  const MonitoringView({super.key});

  @override
  ConsumerState<MonitoringView> createState() => _MonitoringViewState();
}

class _MonitoringViewState extends ConsumerState<MonitoringView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = ref.read(serverControllerProvider).activeSession;
      if (session != null) {
        ref.read(monitoringControllerProvider.notifier).startPolling(session.sessionId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ConnectionGuard(
      customMessage: context.l10n.monitoringGuardMessage,
      child: _buildMonitoringPage(context),
    );
  }

  Widget _buildMonitoringPage(BuildContext context) {
    final activeSession = ref.watch(serverControllerProvider).activeSession!;
    final monitoringState = ref.watch(monitoringControllerProvider);
    final overview = monitoringState.overview;

    return ScaffoldPage(
      header: PageHeader(
        title: Text(context.l10n.monitoringTitle(activeSession.server.name)),
        commandBar: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (monitoringState.isLoading && overview.isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(right: AppSpacing.sm),
                child: SizedBox(
                  width: 14,
                  height: 14,
                  child: ProgressRing(strokeWidth: 2),
                ),
              ),
            AppBadge(
              label: context.l10n.monitoringUptimeLabel(overview.uptime),
              variant: AppBadgeVariant.neutral,
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              icon: const Icon(FluentIcons.refresh, size: AppIconSize.md),
              onPressed: () {
                ref.read(monitoringControllerProvider.notifier).fetchStats();
              },
            ),
          ],
        ),
      ),
      content: monitoringState.isLoading && overview.isEmpty
          ? const Center(child: ProgressRing())
          : SingleChildScrollView(
              padding: AppSpacing.pageContent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (monitoringState.error != null) ...[
                    InfoBar(
                      title: Text(context.l10n.monitoringWarning),
                      content: Text(monitoringState.error!),
                      severity: InfoBarSeverity.warning,
                      action: Button(
                        onPressed: () => ref.read(monitoringControllerProvider.notifier).fetchStats(),
                        child: Text(context.l10n.commonRetry),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: AppMetricCard(
                          label: context.l10n.monitoringCpuTitle,
                          value: '${overview.cpuUsagePercent}%',
                          subtitle: context.l10n.monitoringCpuKernel(overview.kernel),
                          percent: overview.cpuUsagePercent,
                          color: overview.cpuUsagePercent > 80 ? AppColors.danger : AppColors.brandCyan,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: AppMetricCard(
                          label: context.l10n.monitoringRamTitle,
                          value: '${overview.memoryUsagePercent}%',
                          subtitle:
                              '${Formatters.formatBytes(overview.memoryUsedBytes)} / ${Formatters.formatBytes(overview.memoryTotalBytes)}',
                          percent: overview.memoryUsagePercent,
                          color: overview.memoryUsagePercent > 85 ? AppColors.warning : AppColors.success,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: AppMetricCard(
                          label: context.l10n.monitoringDiskTitle,
                          value: '${overview.diskUsagePercent}%',
                          subtitle:
                              '${Formatters.formatBytes(overview.diskUsedBytes)} / ${Formatters.formatBytes(overview.diskTotalBytes)}',
                          percent: overview.diskUsagePercent,
                          color: overview.diskUsagePercent > 90 ? AppColors.danger : AppColors.brandViolet,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  AppCard(
                    padding: AppSpacing.cardPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.monitoringCpuTrend,
                          style: AppTypo.body(context).copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        SizedBox(
                          height: 200,
                          child: monitoringState.cpuHistory.isEmpty
                              ? Center(
                                  child: Text(
                                    context.l10n.monitoringCollecting,
                                    style: AppTypo.bodySmall(context),
                                  ),
                                )
                              : LineChart(
                                  LineChartData(
                                    minY: 0,
                                    maxY: 100,
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                      getDrawingHorizontalLine: (_) => FlLine(
                                        color: AppColors.surfaceBorder(context),
                                        strokeWidth: 1,
                                      ),
                                    ),
                                    titlesData: const FlTitlesData(
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(showTitles: true, reservedSize: 32),
                                      ),
                                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: monitoringState.cpuHistory,
                                        isCurved: true,
                                        color: AppColors.brandCyan,
                                        barWidth: 2,
                                        belowBarData: BarAreaData(
                                          show: true,
                                          color: AppColors.selectionBackground(AppColors.brandCyan),
                                        ),
                                        dotData: const FlDotData(show: false),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
