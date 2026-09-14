import 'package:fluent_ui/fluent_ui.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_icons.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';

/// Standardized empty state view for empty lists, search results, and initial screens.
class AppEmptyState extends StatelessWidget {
  /// Hero visual iconography representing the context.
  final IconData icon;

  /// Main headline communicating the empty state.
  final String title;

  /// Optional descriptive subtitle.
  final String? subtitle;

  /// Optional call-to-action primary button label.
  final String? actionLabel;

  /// Callback triggered when the primary call-to-action button is clicked.
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: AppIconSize.hero,
              color: AppColors.surfaceBorder(context),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTypo.titleMedium(context).copyWith(
                color: AppColors.textSecondary(context),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle!,
                style: AppTypo.caption(context).copyWith(
                  color: AppColors.textMuted(context),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null) ...[
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
