import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_icons.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/l10n/l10n.dart';
import '../../core/services/settings_service.dart';
import '../servers/server_dialog.dart';
import '../../shared/widgets/app_brand_mark.dart';

/// Presentation view for first-launch onboarding and initial server configuration.
class WelcomeView extends ConsumerWidget {
  final VoidCallback onFinish;

  const WelcomeView({super.key, required this.onFinish});

  Future<void> _openAddServer(BuildContext context, WidgetRef ref) async {
    await ref.read(settingsServiceProvider.notifier).setFirstLaunchCompleted();
    onFinish();
    if (context.mounted) {
      await showDialog(
        context: context,
        builder: (ctx) => const ServerDialog(),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: AppColors.surfaceBase(context),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl, vertical: AppSpacing.xxl),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 580),
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard(context),
          borderRadius: AppRadius.borderMd,
          border: Border.all(color: AppColors.surfaceBorder(context), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppBrandMark.hero(),
            const SizedBox(height: AppSpacing.xl),
            Text(
              context.l10n.onboardingWelcome,
              style: AppTypo.displayLarge(context).copyWith(
                fontSize: 22,
                color: AppColors.textPrimary(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              context.l10n.onboardingSubtitle,
              style: AppTypo.bodySmall(context).copyWith(
                color: AppColors.textMuted(context),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFeatureBadge(context, FluentIcons.command_prompt, 'Terminal PTY'),
                _buildFeatureBadge(context, FluentIcons.package, 'Docker & Units'),
                _buildFeatureBadge(context, FluentIcons.branch_fork2, 'SSH Tunnels'),
                _buildFeatureBadge(context, FluentIcons.folder_open, 'SFTP Manager'),
              ],
            ),
            const SizedBox(height: AppSpacing.xxxl),
            FilledButton(
              onPressed: () => _openAddServer(context, ref),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(FluentIcons.add, size: AppIconSize.md),
                  const SizedBox(width: AppSpacing.sm),
                  Text(context.l10n.onboardingAddServer),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureBadge(BuildContext context, IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppIconSize.lg, color: AppColors.textSecondary(context)),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTypo.micro(context).copyWith(
            color: AppColors.textMuted(context),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
