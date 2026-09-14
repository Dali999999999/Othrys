import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/app_update_service.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

/// Top banner notifying users of available Othrys updates with direct 1-click update action.
class AppUpdateBanner extends ConsumerWidget {
  const AppUpdateBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appUpdateServiceProvider);
    final update = state.availableUpdate;

    if (update == null || state.userDismissed) {
      return const SizedBox.shrink();
    }

    final notifier = ref.read(appUpdateServiceProvider.notifier);

    Widget actionWidget;
    if (state.isDownloading) {
      actionWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 120,
            child: ProgressBar(value: (state.downloadProgress * 100).clamp(0.0, 100.0)),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '${(state.downloadProgress * 100).toInt()}%',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      );
    } else if (state.isReadyToInstall) {
      actionWidget = FilledButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(AppColors.success),
        ),
        onPressed: () => notifier.launchInstallerAndExit(),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(FluentIcons.sync_occurence, size: 14),
            SizedBox(width: AppSpacing.xs),
            Text('Installer et relancer'),
          ],
        ),
      );
    } else {
      actionWidget = FilledButton(
        onPressed: () => notifier.downloadUpdate(),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(FluentIcons.cloud_download, size: 14),
            SizedBox(width: AppSpacing.xs),
            Text('Mettre à jour'),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      child: InfoBar(
        title: Text('Mise à jour Othrys v${update.version} disponible'),
        content: Text(
          state.isDownloading
              ? 'Téléchargement de la nouvelle version en cours...'
              : state.isReadyToInstall
                  ? 'Téléchargement terminé. Cliquez pour mettre à jour instantanément.'
                  : 'Une nouvelle version d\'Othrys est disponible sur GitHub.',
        ),
        severity: state.isReadyToInstall ? InfoBarSeverity.success : InfoBarSeverity.info,
        action: actionWidget,
        onClose: () => notifier.dismissBanner(),
      ),
    );
  }
}
