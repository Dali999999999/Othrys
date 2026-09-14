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

/// Tab presenting host metadata, system updates, hostname editing, and reboot action.
class SystemMaintenanceTab extends ConsumerStatefulWidget {
  final String sessionId;
  final ServerEntity? server;
  final bool canManage;

  const SystemMaintenanceTab({
    super.key,
    required this.sessionId,
    this.server,
    required this.canManage,
  });

  @override
  ConsumerState<SystemMaintenanceTab> createState() => _SystemMaintenanceTabState();
}

class _SystemMaintenanceTabState extends ConsumerState<SystemMaintenanceTab> {
  bool _isUpgrading = false;
  String? _upgradeOutput;

  void _changeHostname(String currentHost) async {
    final controller = TextEditingController(text: currentHost);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => ContentDialog(
        title: Text(context.l10n.adminMaintenanceChangeHostname),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoLabel(
              label: context.l10n.adminMaintenanceHostname,
              child: TextBox(controller: controller, autofocus: true),
            ),
          ],
        ),
        actions: [
          Button(child: Text(context.l10n.commonCancel), onPressed: () => Navigator.of(ctx).pop(false)),
          FilledButton(child: Text(context.l10n.commonSave), onPressed: () => Navigator.of(ctx).pop(true)),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final newHost = controller.text.trim();
      if (newHost.isNotEmpty) {
        final res = await ref.read(serverAdminControllerProvider.notifier).setHostname(
              widget.sessionId,
              newHost,
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
  }

  void _applyUpgrades() async {
    final info = ref.read(serverAdminControllerProvider).updateInfo;
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: context.l10n.adminMaintenanceUpgradeConfirmTitle,
      content: context.l10n.adminMaintenanceUpgradeConfirm(info.upgradableCount),
      confirmText: context.l10n.adminMaintenanceApplyUpdates,
      isDanger: true,
    );
    if (!confirmed) return;

    setState(() {
      _isUpgrading = true;
      _upgradeOutput = null;
    });

    final res = await ref.read(serverAdminControllerProvider.notifier).applySystemUpdates(
          widget.sessionId,
          server: widget.server,
        );

    if (!mounted) return;
    setState(() {
      _isUpgrading = false;
      _upgradeOutput = res.dataOrNull;
    });

    displayInfoBar(
      context,
      builder: (ctx, close) => InfoBar(
        title: Text(res.isSuccess ? context.l10n.commonSuccess : context.l10n.commonError),
        severity: res.isSuccess ? InfoBarSeverity.success : InfoBarSeverity.error,
        onClose: close,
      ),
    );
  }

  void _rebootServer() async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: context.l10n.adminMaintenanceReboot,
      content: context.l10n.adminMaintenanceRebootConfirm,
      confirmText: context.l10n.adminMaintenanceReboot,
      isDanger: true,
    );

    if (confirmed && mounted) {
      final res = await ref.read(serverAdminControllerProvider.notifier).rebootServer(
            widget.sessionId,
            server: widget.server,
          );
      if (mounted && res.isSuccess) {
        displayInfoBar(
          context,
          builder: (ctx, close) => InfoBar(
            title: Text(context.l10n.commonSuccess),
            content: const Text('Reboot command dispatched to remote host.'),
            severity: InfoBarSeverity.info,
            onClose: close,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = ref.watch(serverAdminControllerProvider).updateInfo;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Host Metadata Card
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard(context),
              borderRadius: AppRadius.borderSm,
              border: Border.all(color: AppColors.surfaceBorder(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(FluentIcons.server, size: AppIconSize.md, color: AppColors.accentCyan),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      info.hostname.isEmpty ? 'Server Info' : info.hostname,
                      style: AppTypo.titleMedium(context).copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    if (widget.canManage)
                      Button(
                        onPressed: () => _changeHostname(info.hostname),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(FluentIcons.edit, size: AppIconSize.xs),
                            const SizedBox(width: AppSpacing.xs),
                            Text(context.l10n.adminMaintenanceChangeHostname),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _buildMetaPill(context, 'OS', info.osRelease.isEmpty ? 'Linux' : info.osRelease),
                    _buildMetaPill(context, 'Kernel', info.kernelVersion),
                    _buildMetaPill(context, 'Uptime', info.uptime),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // OS Updates Card
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard(context),
              borderRadius: AppRadius.borderSm,
              border: Border.all(color: AppColors.surfaceBorder(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      info.upgradableCount > 0 ? FluentIcons.update_restore : FluentIcons.check_mark,
                      size: AppIconSize.md,
                      color: info.upgradableCount > 0 ? AppColors.warning : AppColors.success,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      context.l10n.adminMaintenanceUpdates,
                      style: AppTypo.titleMedium(context).copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    AppBadge(
                      label: info.upgradableCount > 0 ? '${info.upgradableCount} pending' : 'Up to date',
                      variant: info.upgradableCount > 0 ? AppBadgeVariant.warning : AppBadgeVariant.success,
                    ),
                    const Spacer(),
                    if (widget.canManage && info.upgradableCount > 0)
                      FilledButton(
                        onPressed: _isUpgrading ? null : _applyUpgrades,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isUpgrading)
                              const SizedBox(width: 14, height: 14, child: ProgressRing(strokeWidth: 2))
                            else
                              const Icon(FluentIcons.sync_folder, size: AppIconSize.xs, color: Colors.white),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              context.l10n.adminMaintenanceApplyUpdates,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  info.upgradableCount > 0
                      ? context.l10n.adminMaintenanceUpdatesAvailable(info.upgradableCount)
                      : context.l10n.adminMaintenanceUpdatesNone,
                  style: AppTypo.bodySmall(context).copyWith(color: AppColors.textMuted(context)),
                ),
                if (_upgradeOutput != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    height: 140,
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.consoleBackground,
                      borderRadius: AppRadius.borderSm,
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        _upgradeOutput!,
                        style: AppTypo.caption(context).copyWith(
                          color: AppColors.consoleText,
                          fontFamily: AppTypo.fontMono,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Power & Reboot Operations
          if (widget.canManage)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard(context),
                borderRadius: AppRadius.borderSm,
                border: Border.all(color: AppColors.surfaceBorder(context)),
              ),
              child: Row(
                children: [
                  const Icon(FluentIcons.power_button, size: AppIconSize.md, color: AppColors.danger),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.adminMaintenanceReboot,
                          style: AppTypo.titleMedium(context).copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.l10n.adminMaintenanceRebootDesc,
                          style: AppTypo.caption(context).copyWith(color: AppColors.textMuted(context)),
                        ),
                      ],
                    ),
                  ),
                  FilledButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(AppColors.danger),
                    ),
                    onPressed: _rebootServer,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(FluentIcons.power_button, size: AppIconSize.xs, color: Colors.white),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          context.l10n.adminMaintenanceReboot,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMetaPill(BuildContext context, String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: AppRadius.borderSm,
        border: Border.all(color: AppColors.surfaceBorder(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypo.micro(context).copyWith(color: AppColors.textMuted(context))),
          const SizedBox(height: 2),
          Text(value, style: AppTypo.bodySmall(context).copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
