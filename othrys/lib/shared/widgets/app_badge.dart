import 'package:fluent_ui/fluent_ui.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_icons.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';

/// Semantic variants for badge pills.
enum AppBadgeVariant {
  /// Operational, active, or enabled indicator.
  success,

  /// High thresholds, attention, or pending state.
  warning,

  /// Errors, failed jobs, or critical alerts.
  danger,

  /// Neutral informational tags, groups, or metrics (Brand Cyan).
  info,

  /// Primary brand accent tags (Brand Blue).
  accent,

  /// Secondary muted tags with elevated surface background.
  neutral,
}

/// Standardized informational badge / status pill.
///
/// Complies with the 12% background and 35% border overlay pattern of the Design System.
class AppBadge extends StatelessWidget {
  /// Display text label.
  final String label;

  /// Semantic visual styling.
  final AppBadgeVariant variant;

  /// Optional leading icon with standardized micro size (10px).
  final IconData? icon;

  const AppBadge({
    super.key,
    required this.label,
    this.variant = AppBadgeVariant.info,
    this.icon,
  });

  Color _resolveSemanticColor(BuildContext context) {
    return switch (variant) {
      AppBadgeVariant.success => AppColors.success,
      AppBadgeVariant.warning => AppColors.warning,
      AppBadgeVariant.danger => AppColors.danger,
      AppBadgeVariant.info => AppColors.brandCyan,
      AppBadgeVariant.accent => AppColors.brandBlue,
      AppBadgeVariant.neutral => AppColors.textSecondary(context),
    };
  }

  @override
  Widget build(BuildContext context) {
    final semanticColor = _resolveSemanticColor(context);
    final isNeutral = variant == AppBadgeVariant.neutral;

    final backgroundColor = isNeutral
        ? AppColors.surfaceElevated(context)
        : AppColors.badgeBackground(semanticColor);

    final border = isNeutral
        ? null
        : Border.all(
            color: AppColors.badgeBorder(semanticColor),
            width: 1,
          );

    final textStyle = AppTypo.nano(context).copyWith(
      color: semanticColor,
      fontWeight: FontWeight.w600,
    );

    return Container(
      padding: AppSpacing.badgePadding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.borderSm,
        border: border,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: AppIconSize.xs,
              color: semanticColor,
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: textStyle,
          ),
        ],
      ),
    );
  }
}
