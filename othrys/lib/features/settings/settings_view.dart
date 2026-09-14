import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/l10n/l10n.dart';
import '../../core/services/settings_service.dart';
import '../../core/services/app_update_service.dart';
import '../../shared/widgets/app_section_card.dart';
import '../../shared/widgets/app_brand_mark.dart';
import 'widgets/backup_restore_card.dart';

/// Presentation view for user preferences, appearance, localization, backup, and about.
class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsServiceProvider);
    final settingsNotifier = ref.read(settingsServiceProvider.notifier);

    return ScaffoldPage.scrollable(
      header: PageHeader(title: Text(context.l10n.settingsTitle)),
      padding: AppSpacing.pageContent,
      children: [
        // Theme Selector
        AppSectionCard(
          title: context.l10n.settingsTheme,
          child: SizedBox(
            width: 250,
            child: ComboBox<ThemeMode>(
              value: settings.themeMode,
              isExpanded: true,
              items: [
                ComboBoxItem(
                  value: ThemeMode.dark,
                  child: Text(context.l10n.settingsThemeDark),
                ),
                ComboBoxItem(
                  value: ThemeMode.light,
                  child: Text(context.l10n.settingsThemeLight),
                ),
                ComboBoxItem(
                  value: ThemeMode.system,
                  child: Text(context.l10n.settingsThemeSystem),
                ),
              ],
              onChanged: (val) {
                if (val != null) settingsNotifier.setThemeMode(val);
              },
            ),
          ),
        ),

        // Language Selector
        AppSectionCard(
          title: context.l10n.settingsLanguage,
          child: SizedBox(
            width: 250,
            child: ComboBox<String>(
              value: settings.locale?.languageCode ?? 'system',
              isExpanded: true,
              items: [
                ComboBoxItem(
                  value: 'fr',
                  child: Text(context.l10n.settingsLangFr),
                ),
                ComboBoxItem(
                  value: 'en',
                  child: Text(context.l10n.settingsLangEn),
                ),
                ComboBoxItem(
                  value: 'system',
                  child: Text(context.l10n.settingsThemeSystem),
                ),
              ],
              onChanged: (val) {
                if (val == 'fr') {
                  settingsNotifier.setLocale(const Locale('fr'));
                } else if (val == 'en') {
                  settingsNotifier.setLocale(const Locale('en'));
                } else {
                  settingsNotifier.setLocale(null);
                }
              },
            ),
          ),
        ),

        // Terminal Preferences
        AppSectionCard(
          title: context.l10n.settingsTerminalFontSize(settings.terminalFontSize),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Slider(
                min: 10,
                max: 22,
                divisions: 12,
                value: settings.terminalFontSize.toDouble(),
                onChanged: (v) => settingsNotifier.setTerminalFontSize(v.round()),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'JetBrains Mono, Consolas, monospace preview at ${settings.terminalFontSize}px',
                style: AppTypo.codeMuted(context).copyWith(
                  fontSize: settings.terminalFontSize.toDouble(),
                ),
              ),
            ],
          ),
        ),

        // Monitoring Polling Interval
        AppSectionCard(
          title: context.l10n.settingsMonitoringInterval(settings.monitoringInterval),
          child: Slider(
            min: 3,
            max: 30,
            divisions: 27,
            value: settings.monitoringInterval.toDouble(),
            onChanged: (v) => settingsNotifier.setMonitoringInterval(v.round()),
          ),
        ),

        // Encrypted Backup & Restore
        const BackupRestoreCard(),

        // About Section
        AppSectionCard(
          title: context.l10n.settingsAbout,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppBrandMark.about(),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Othrys — Industrial DevOps Suite',
                      style: AppTypo.body(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${context.l10n.settingsVersion}: 0.1.0 (Release MVP)',
                      style: AppTypo.caption(context).copyWith(
                        color: AppColors.textMuted(context),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      context.l10n.settingsLicense,
                      style: AppTypo.caption(context).copyWith(
                        color: AppColors.textMuted(context),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${context.l10n.settingsGitHub}: https://github.com/Dali999999999/Othrys',
                      style: AppTypo.caption(context).copyWith(
                        color: AppColors.brandCyan,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Consumer(
                      builder: (context, ref, _) {
                        final updateState = ref.watch(appUpdateServiceProvider);
                        final updateNotifier = ref.read(appUpdateServiceProvider.notifier);

                        if (updateState.isChecking) {
                          return const Row(
                            children: [
                              SizedBox(width: 14, height: 14, child: ProgressRing(strokeWidth: 2)),
                              SizedBox(width: AppSpacing.sm),
                              Text('Recherche de mises à jour...', style: TextStyle(fontSize: 12)),
                            ],
                          );
                        }

                        if (updateState.availableUpdate != null) {
                          return Row(
                            children: [
                              Text(
                                'Version v${updateState.availableUpdate!.version} disponible !',
                                style: TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Button(
                                onPressed: () => updateNotifier.downloadUpdate(),
                                child: const Text('Mettre à jour'),
                              ),
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Button(
                              onPressed: () => updateNotifier.checkForUpdate(manualTrigger: true),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(FluentIcons.sync_folder, size: 14),
                                  SizedBox(width: AppSpacing.xs),
                                  Text('Rechercher des mises à jour'),
                                ],
                              ),
                            ),
                            if (updateState.errorMessage != null) ...[
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                updateState.errorMessage!,
                                style: TextStyle(fontSize: 12, color: AppColors.danger),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
