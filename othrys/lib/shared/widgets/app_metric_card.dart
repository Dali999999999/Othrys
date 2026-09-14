import 'package:fluent_ui/fluent_ui.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import 'app_card.dart';

/// Monitoring metric card component rendering high-precision gauges (CPU, RAM, Disk).
class AppMetricCard extends StatelessWidget {
  /// Metric label/title (e.g. "CPU Utilization", "Memory").
  final String label;

  /// Large formatted value (e.g. "87%", "4.2 GB").
  final String value;

  /// Secondary technical context or breakdown (e.g. "3.2 GB / 8.0 GB").
  final String subtitle;

  /// Percentage value between 0.0 and 100.0 for the progress indicator.
  final double percent;

  /// Semantic indicator color applied to the value and progress bar.
  final Color color;

  const AppMetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypo.caption(context).copyWith(
              color: AppColors.textMuted(context),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            style: AppTypo.displayLarge(context).copyWith(
              color: color,
            ),
            child: Text(value),
          ),
          const SizedBox(height: AppSpacing.sm + 2),
          ProgressBar(
            value: percent.clamp(0.0, 100.0),
            backgroundColor: AppColors.surfaceElevated(context),
            activeColor: color,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtitle,
            style: AppTypo.micro(context).copyWith(
              fontFamily: AppTypo.fontMono,
              color: AppColors.textFaint(context),
            ),
          ),
        ],
      ),
    );
  }
}
