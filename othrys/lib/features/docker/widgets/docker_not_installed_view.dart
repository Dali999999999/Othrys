import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_icons.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/l10n/l10n.dart';
import '../../../shared/widgets/app_card.dart';

/// Single-responsibility view displayed when Docker is not installed on remote host.
class DockerNotInstalledView extends StatelessWidget {
  final VoidCallback onRefresh;

  const DockerNotInstalledView({
    super.key,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: AppCard(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                FluentIcons.warning,
                size: AppIconSize.hero,
                color: AppColors.warning,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                context.l10n.dockerNotInstalledTitle,
                style: AppTypo.titleMedium(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                context.l10n.dockerNotInstalledSubtitle,
                textAlign: TextAlign.center,
                style: AppTypo.caption(context).copyWith(
                  color: AppColors.textMuted(context),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.consoleBackground,
                  borderRadius: AppRadius.borderSm,
                  border: Border.all(color: AppColors.surfaceBorder(context)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        context.l10n.dockerInstallCommand,
                        style: AppTypo.codeAccent(context),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(FluentIcons.copy, size: AppIconSize.md),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: context.l10n.dockerInstallCommand));
                        displayInfoBar(context, builder: (ctx, close) {
                          return InfoBar(
                            title: Text(context.l10n.commonSuccess),
                            content: Text(context.l10n.dockerCopyCommand),
                            severity: InfoBarSeverity.success,
                            onClose: close,
                          );
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: onRefresh,
                child: Text(context.l10n.commonRefresh),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
