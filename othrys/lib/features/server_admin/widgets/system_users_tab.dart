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
import '../server_admin_controller.dart';
import 'ssh_key_add_dialog.dart';
import 'system_user_dialog.dart';

/// Tab presenting Linux user accounts, sudo status, and SSH key management.
class SystemUsersTab extends ConsumerStatefulWidget {
  final String sessionId;
  final ServerEntity? server;
  final bool canManage;

  const SystemUsersTab({
    super.key,
    required this.sessionId,
    this.server,
    required this.canManage,
  });

  @override
  ConsumerState<SystemUsersTab> createState() => _SystemUsersTabState();
}

class _SystemUsersTabState extends ConsumerState<SystemUsersTab> {
  String _searchQuery = '';

  void _openCreateUserDialog() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => SystemUserDialog(
        sessionId: widget.sessionId,
        server: widget.server,
      ),
    );

    if (created == true && mounted) {
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

  void _openAddKeyDialog(String username) async {
    final added = await showDialog<bool>(
      context: context,
      builder: (ctx) => SshKeyAddDialog(
        sessionId: widget.sessionId,
        username: username,
        server: widget.server,
      ),
    );

    if (added == true && mounted) {
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

  void _confirmDeleteUser(String username) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: context.l10n.adminUserDeleteTitle,
      content: context.l10n.adminUserDeleteConfirm(username),
      confirmText: context.l10n.commonDelete,
      isDanger: true,
    );

    if (confirmed && mounted) {
      final res = await ref.read(serverAdminControllerProvider.notifier).deleteSystemUser(
            widget.sessionId,
            username,
            server: widget.server,
          );
      if (mounted) {
        displayInfoBar(
          context,
          builder: (ctx, close) => InfoBar(
            title: Text(res.isSuccess ? context.l10n.commonSuccess : context.l10n.commonError),
            content: res.isFailure ? Text(res.failureOrNull?.message ?? '') : null,
            severity: res.isSuccess ? InfoBarSeverity.success : InfoBarSeverity.error,
            onClose: close,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(serverAdminControllerProvider);
    final users = adminState.users;

    final filtered = users.where((u) {
      final q = _searchQuery.toLowerCase();
      return u.username.toLowerCase().contains(q) ||
          u.homeDir.toLowerCase().contains(q) ||
          u.shell.toLowerCase().contains(q);
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search Bar & Create Button
          Row(
            children: [
              SizedBox(
                width: 250,
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
              if (widget.canManage) ...[
                FilledButton(
                  onPressed: _openCreateUserDialog,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(FluentIcons.add, size: AppIconSize.xs, color: Colors.white),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        context.l10n.adminUsersAdd,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              Text(
                '${filtered.length} ${filtered.length > 1 ? "users" : "user"}',
                style: AppTypo.caption(context).copyWith(color: AppColors.textMuted(context)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Users List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      context.l10n.commonEmpty,
                      style: AppTypo.body(context).copyWith(color: AppColors.textMuted(context)),
                    ),
                  )
                : ListView.separated(
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
                            // User Avatar / Icon
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: AppColors.badgeBackground(user.isSudoer ? AppColors.warning : AppColors.accentCyan),
                                borderRadius: AppRadius.borderSm,
                              ),
                              child: Icon(
                                user.isSudoer ? FluentIcons.admin : FluentIcons.contact,
                                size: AppIconSize.md,
                                color: user.isSudoer ? AppColors.warning : AppColors.accentCyan,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),

                            // Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    spacing: AppSpacing.sm,
                                    runSpacing: AppSpacing.xxs,
                                    children: [
                                      Text(
                                        user.username,
                                        style: AppTypo.titleMedium(context).copyWith(fontWeight: FontWeight.w600),
                                      ),
                                      if (user.isSudoer)
                                        const AppBadge(
                                          label: 'SUDO',
                                          variant: AppBadgeVariant.warning,
                                        ),
                                      AppBadge(
                                        label: 'UID: ${user.uid}',
                                        variant: AppBadgeVariant.neutral,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${user.homeDir}  •  ${user.shell}',
                                    style: AppTypo.caption(context).copyWith(
                                      fontFamily: AppTypo.fontMono,
                                      color: AppColors.textMuted(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Actions
                            if (widget.canManage)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Button(
                                    onPressed: () => _openAddKeyDialog(user.username),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(FluentIcons.permissions, size: AppIconSize.xs),
                                        const SizedBox(width: AppSpacing.xs),
                                        Text(context.l10n.adminUsersAddKey),
                                      ],
                                    ),
                                  ),
                                  if (user.username != 'root' && user.uid != 0) ...[
                                    const SizedBox(width: AppSpacing.xs),
                                    IconButton(
                                      icon: const Icon(FluentIcons.delete, size: AppIconSize.xs, color: AppColors.danger),
                                      onPressed: () => _confirmDeleteUser(user.username),
                                    ),
                                  ],
                                ],
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
