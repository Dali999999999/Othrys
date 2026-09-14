import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_icons.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/l10n/l10n.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/app_badge.dart';
import '../../shared/widgets/app_status_dot.dart';
import 'activity_controller.dart';

/// Presentation view for the live and persisted security audit stream.
class ActivityFeedView extends ConsumerWidget {
  const ActivityFeedView({super.key});

  StatusDotVariant _getStatusDotVariant(ActivityLevel level) {
    return switch (level) {
      ActivityLevel.success => StatusDotVariant.success,
      ActivityLevel.warning => StatusDotVariant.warning,
      ActivityLevel.error => StatusDotVariant.danger,
      ActivityLevel.info => StatusDotVariant.info,
    };
  }

  AppBadgeVariant _getBadgeVariant(ActivityLevel level) {
    return switch (level) {
      ActivityLevel.success => AppBadgeVariant.success,
      ActivityLevel.warning => AppBadgeVariant.warning,
      ActivityLevel.error => AppBadgeVariant.danger,
      ActivityLevel.info => AppBadgeVariant.info,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityState = ref.watch(activityControllerProvider);
    final filtered = activityState.filteredLogs;

    return ScaffoldPage(
      header: PageHeader(
        title: Text(context.l10n.activityTitle),
        commandBar: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ComboBox<String>(
              value: activityState.selectedCategory,
              items: [
                ComboBoxItem(value: 'ALL', child: Text(context.l10n.activityFilterAll)),
                ComboBoxItem(value: 'SSH', child: Text(context.l10n.activityFilterSsh)),
                ComboBoxItem(value: 'DOCKER', child: Text(context.l10n.activityFilterDocker)),
                ComboBoxItem(value: 'FILES', child: Text(context.l10n.activityFilterFiles)),
                ComboBoxItem(value: 'SERVICES', child: Text(context.l10n.activityFilterServices)),
                ComboBoxItem(value: 'TUNNELS', child: Text(context.l10n.activityFilterTunnels)),
                ComboBoxItem(value: 'SYSTEM', child: Text(context.l10n.activityFilterSystem)),
              ],
              onChanged: (val) {
                if (val != null) {
                  ref.read(activityControllerProvider.notifier).setCategory(val);
                }
              },
            ),
            if (activityState.isLoading && activityState.logs.isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(right: AppSpacing.sm),
                child: SizedBox(
                  width: 14,
                  height: 14,
                  child: ProgressRing(strokeWidth: 2),
                ),
              ),
            IconButton(
              icon: const Icon(FluentIcons.refresh, size: AppIconSize.md),
              onPressed: () => ref.read(activityControllerProvider.notifier).loadLogs(),
            ),
          ],
        ),
      ),
      content: activityState.isLoading && activityState.logs.isEmpty
          ? const Center(child: ProgressRing())
          : filtered.isEmpty
              ? Center(
                  child: Text(
                    context.l10n.activityNoLogs,
                    style: AppTypo.bodySmall(context),
                  ),
                )
              : ListView.separated(
                  padding: AppSpacing.pageContent,
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (context, index) {
                    final log = filtered[index];

                    return ListTile.selectable(
                      leading: AppStatusDot(
                        variant: _getStatusDotVariant(log.level),
                      ),
                      title: Row(
                        children: [
                          AppBadge(
                            label: log.category.name.toUpperCase(),
                            variant: _getBadgeVariant(log.level),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              log.message,
                              style: AppTypo.bodySmall(context).copyWith(
                                color: AppColors.textPrimary(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: Text(
                        Formatters.formatDateTime(log.timestamp),
                        style: AppTypo.micro(context).copyWith(
                          color: AppColors.textFaint(context),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
