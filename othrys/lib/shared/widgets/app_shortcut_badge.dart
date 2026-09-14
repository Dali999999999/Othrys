import 'package:fluent_ui/fluent_ui.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';

/// Styled keyboard shortcut indicator pill (e.g. "Ctrl+K", "Esc").
class AppShortcutBadge extends StatelessWidget {
  /// Keyboard shortcut combination text.
  final String shortcut;

  const AppShortcutBadge({
    super.key,
    required this.shortcut,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.badgePadding,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: AppRadius.borderSm,
      ),
      child: Text(
        shortcut,
        style: AppTypo.nano(context).copyWith(
          color: AppColors.accentBlue,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
