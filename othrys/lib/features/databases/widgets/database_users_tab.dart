import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_icons.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/models/server_entity.dart';
import '../../../shared/widgets/app_badge.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../database_controller.dart';

/// Tab displaying database users and privilege information.
class DatabaseUsersTab extends ConsumerStatefulWidget {
  final String sessionId;
  final ServerEntity? server;
  final bool canManage;

  const DatabaseUsersTab({
    super.key,
    required this.sessionId,
    this.server,
    required this.canManage,
  });

  @override
  ConsumerState<DatabaseUsersTab> createState() => _DatabaseUsersTabState();
}

class _DatabaseUsersTabState extends ConsumerState<DatabaseUsersTab> {
  String _searchQuery = '';

  void _confirmDropUser(DatabaseUser user) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: context.l10n.dbTabUsers,
      content: context.l10n.dbUserDeleteConfirm(user.username),
      confirmText: context.l10n.commonDelete,
      isDanger: true,
    );

    if (confirmed == true && mounted) {
      final res = await ref.read(databasesControllerProvider.notifier).dropUser(
            widget.sessionId,
            user,
            server: widget.server,
          );
      if (mounted && res.isSuccess) {
        displayInfoBar(
          context,
          builder: (ctx, close) => InfoBar(
            title: Text(context.l10n.commonSuccess),
            severity: InfoBarSeverity.success,
            onClose: close,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(databasesControllerProvider);
    final isMysql = state.selectedEngine == DatabaseEngineType.mysql;
    final filtered = state.users.where((u) {
      return u.username.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        // Filter toolbar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          child: Row(
            children: [
              SizedBox(
                width: 260,
                child: TextBox(
                  placeholder: context.l10n.commonSearch,
                  prefix: Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.sm),
                    child: Icon(FluentIcons.search, size: AppIconSize.sm, color: AppColors.textMuted(context)),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
              const Spacer(),
              Text(
                '${filtered.length} / ${state.users.length}',
                style: AppTypo.caption(context).copyWith(color: AppColors.textMuted(context)),
              ),
            ],
          ),
        ),

        // User list
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    context.l10n.commonEmpty,
                    style: AppTypo.body(context).copyWith(color: AppColors.textMuted(context)),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.xs),
                  itemBuilder: (ctx, idx) {
                    final user = filtered[idx];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard(context),
                        borderRadius: AppRadius.borderSm,
                        border: Border.all(color: AppColors.surfaceBorder(context)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            user.isSuperuser ? FluentIcons.admin : FluentIcons.contact,
                            size: AppIconSize.md,
                            color: user.isSuperuser ? AppColors.warning : AppColors.accentCyan,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.username,
                                  style: AppTypo.titleMedium(context).copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Wrap(
                                  spacing: AppSpacing.xs,
                                  runSpacing: AppSpacing.xxs,
                                  children: [
                                    if (isMysql)
                                      AppBadge(
                                        label: '@${user.host}',
                                        variant: AppBadgeVariant.neutral,
                                      ),
                                    if (user.isSuperuser)
                                      const AppBadge(
                                        label: 'SUPERUSER',
                                        variant: AppBadgeVariant.warning,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (widget.canManage && !user.isSuperuser) ...[
                            Tooltip(
                              message: context.l10n.commonDelete,
                              child: IconButton(
                                icon: const Icon(FluentIcons.delete, size: AppIconSize.sm, color: AppColors.danger),
                                onPressed: () => _confirmDropUser(user),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
