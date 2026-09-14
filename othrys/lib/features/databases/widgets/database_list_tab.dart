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

/// Tab displaying the list of databases for the selected engine.
class DatabaseListTab extends ConsumerStatefulWidget {
  final String sessionId;
  final ServerEntity? server;
  final bool canManage;

  const DatabaseListTab({
    super.key,
    required this.sessionId,
    this.server,
    required this.canManage,
  });

  @override
  ConsumerState<DatabaseListTab> createState() => _DatabaseListTabState();
}

class _DatabaseListTabState extends ConsumerState<DatabaseListTab> {
  String _searchQuery = '';

  void _confirmDrop(DatabaseItem db) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: context.l10n.dbTitle,
      content: context.l10n.dbDeleteConfirm(db.name),
      confirmText: context.l10n.commonDelete,
      isDanger: true,
    );

    if (confirmed && mounted) {
      final res = await ref.read(databasesControllerProvider.notifier).dropDatabase(
            widget.sessionId,
            db.name,
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
    final filtered = state.databases.where((d) {
      return d.name.toLowerCase().contains(_searchQuery.toLowerCase());
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
                '${filtered.length} / ${state.databases.length}',
                style: AppTypo.caption(context).copyWith(color: AppColors.textMuted(context)),
              ),
            ],
          ),
        ),

        // List
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
                    final db = filtered[idx];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard(context),
                        borderRadius: AppRadius.borderSm,
                        border: Border.all(color: AppColors.surfaceBorder(context)),
                      ),
                      child: Row(
                        children: [
                          const Icon(FluentIcons.database, size: AppIconSize.md, color: AppColors.accentCyan),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  db.name,
                                  style: AppTypo.titleMedium(context).copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Wrap(
                                  spacing: AppSpacing.xs,
                                  runSpacing: AppSpacing.xxs,
                                  children: [
                                    AppBadge(
                                      label: db.charset,
                                      variant: AppBadgeVariant.neutral,
                                    ),
                                    if (db.collation.isNotEmpty)
                                      AppBadge(
                                        label: db.collation,
                                        variant: AppBadgeVariant.neutral,
                                      ),
                                    if (db.sizeBytes != null)
                                      AppBadge(
                                        label: db.sizeFormatted,
                                        variant: AppBadgeVariant.info,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (widget.canManage) ...[
                            Tooltip(
                              message: context.l10n.commonDelete,
                              child: IconButton(
                                icon: const Icon(FluentIcons.delete, size: AppIconSize.sm, color: AppColors.danger),
                                onPressed: () => _confirmDrop(db),
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
