import 'package:fluent_ui/fluent_ui.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';

/// Standardized section card container used for configuration forms, preferences, and grouped settings.
///
/// Replaces legacy single-use section cards across the codebase.
class AppSectionCard extends StatelessWidget {
  /// Section header title.
  final String title;

  /// Inner section body content.
  final Widget child;

  const AppSectionCard({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard(context),
        borderRadius: AppRadius.borderMd,
        border: Border.all(
          color: AppColors.surfaceBorder(context),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypo.body(context).copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}
