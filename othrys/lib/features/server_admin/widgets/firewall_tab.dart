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
import 'firewall_rule_dialog.dart';

/// Tab presenting UFW firewall status, policies, and numbered rules.
class FirewallTab extends ConsumerStatefulWidget {
  final String sessionId;
  final ServerEntity? server;
  final bool canManage;

  const FirewallTab({
    super.key,
    required this.sessionId,
    this.server,
    required this.canManage,
  });

  @override
  ConsumerState<FirewallTab> createState() => _FirewallTabState();
}

class _FirewallTabState extends ConsumerState<FirewallTab> {
  String _searchQuery = '';
  bool _isToggling = false;

  void _openAddRuleDialog() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => FirewallRuleDialog(
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

  void _confirmToggle(bool enable) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: enable ? context.l10n.adminFirewallEnable : context.l10n.adminFirewallDisable,
      content: enable
          ? context.l10n.adminFirewallConfirmEnable
          : context.l10n.adminFirewallConfirmDisable,
      confirmText: enable ? context.l10n.adminFirewallEnable : context.l10n.adminFirewallDisable,
      isDanger: !enable,
    );
    if (!confirmed) return;

    setState(() => _isToggling = true);
    final res = await ref.read(serverAdminControllerProvider.notifier).toggleFirewall(
          widget.sessionId,
          enable,
          server: widget.server,
        );

    if (mounted) {
      setState(() => _isToggling = false);
      if (res.isSuccess) {
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

  void _confirmDeleteRule(FirewallRule rule) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: context.l10n.adminTabFirewall,
      content: context.l10n.adminFirewallDeleteConfirm(rule.number, rule.target),
      confirmText: context.l10n.commonDelete,
      isDanger: true,
    );

    if (confirmed) {
      final res = await ref.read(serverAdminControllerProvider.notifier).deleteFirewallRule(
            widget.sessionId,
            rule.number,
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
    final adminState = ref.watch(serverAdminControllerProvider);
    final fw = adminState.firewall;

    if (!fw.isInstalled) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: InfoBar(
          title: const Text('UFW Firewall is not installed on this server.'),
          content: const Text('Install UFW using "sudo apt install -y ufw" to configure firewall rules.'),
          severity: InfoBarSeverity.warning,
          isLong: true,
        ),
      );
    }

    final filteredRules = fw.rules.where((r) {
      final q = _searchQuery.toLowerCase();
      return r.target.toLowerCase().contains(q) || r.source.toLowerCase().contains(q);
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status Card
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard(context),
              borderRadius: AppRadius.borderSm,
              border: Border.all(color: AppColors.surfaceBorder(context)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.badgeBackground(fw.isEnabled ? AppColors.success : AppColors.danger),
                    borderRadius: AppRadius.borderSm,
                  ),
                  child: Icon(
                    fw.isEnabled ? FluentIcons.shield : FluentIcons.shield_alert,
                    size: AppIconSize.md,
                    color: fw.isEnabled ? AppColors.success : AppColors.danger,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fw.isEnabled ? context.l10n.adminFirewallActive : context.l10n.adminFirewallInactive,
                        style: AppTypo.titleMedium(context).copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Default: ${fw.defaultIncoming} (incoming), ${fw.defaultOutgoing} (outgoing)',
                        style: AppTypo.caption(context).copyWith(color: AppColors.textMuted(context)),
                      ),
                    ],
                  ),
                ),
                if (widget.canManage) ...[
                  if (_isToggling)
                    const Padding(
                      padding: EdgeInsets.only(right: AppSpacing.sm),
                      child: SizedBox(
                        width: 14,
                        height: 14,
                        child: ProgressRing(strokeWidth: 2),
                      ),
                    ),
                  ToggleSwitch(
                    checked: fw.isEnabled,
                    onChanged: _isToggling ? null : (val) => _confirmToggle(val),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  FilledButton(
                    onPressed: _openAddRuleDialog,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(FluentIcons.add, size: AppIconSize.xs),
                        const SizedBox(width: AppSpacing.xs),
                        Text(context.l10n.adminFirewallAddRule),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Search Bar
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
              Text(
                '${filteredRules.length} ${filteredRules.length > 1 ? "rules" : "rule"}',
                style: AppTypo.caption(context).copyWith(color: AppColors.textMuted(context)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Rules List
          Expanded(
            child: filteredRules.isEmpty
                ? Center(
                    child: Text(
                      context.l10n.commonEmpty,
                      style: AppTypo.body(context).copyWith(color: AppColors.textMuted(context)),
                    ),
                  )
                : ListView.separated(
                    itemCount: filteredRules.length,
                    separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.xs),
                    itemBuilder: (ctx, idx) {
                      final rule = filteredRules[idx];
                      final isAllow = rule.action == FirewallAction.allow;
                      final isLimit = rule.action == FirewallAction.limit;

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard(context),
                          borderRadius: AppRadius.borderSm,
                          border: Border.all(color: AppColors.surfaceBorder(context)),
                        ),
                        child: Row(
                          children: [
                            // Rule Number
                            Container(
                              width: 32,
                              alignment: Alignment.center,
                              child: Text(
                                '#${rule.number}',
                                style: AppTypo.caption(context).copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textMuted(context),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),

                            // Target Port/Service
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    rule.target,
                                    style: AppTypo.body(context).copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontFamily: AppTypo.fontMono,
                                    ),
                                  ),
                                  if (rule.isV6)
                                    Text('IPv6', style: AppTypo.micro(context).copyWith(color: AppColors.textMuted(context))),
                                ],
                              ),
                            ),

                            // Action Badge
                            AppBadge(
                              label: rule.action.label,
                              variant: isAllow
                                  ? AppBadgeVariant.success
                                  : (isLimit ? AppBadgeVariant.warning : AppBadgeVariant.danger),
                            ),
                            const SizedBox(width: AppSpacing.sm),

                            // Direction Badge
                            AppBadge(
                              label: rule.direction.label,
                              variant: AppBadgeVariant.neutral,
                            ),
                            const SizedBox(width: AppSpacing.md),

                            // Source
                            Expanded(
                              flex: 2,
                              child: Text(
                                rule.source,
                                style: AppTypo.caption(context).copyWith(
                                  fontFamily: AppTypo.fontMono,
                                  color: AppColors.textSecondary(context),
                                ),
                              ),
                            ),

                            // Delete Action
                            if (widget.canManage)
                              Tooltip(
                                message: context.l10n.commonDelete,
                                child: IconButton(
                                  icon: const Icon(FluentIcons.delete, size: AppIconSize.sm, color: AppColors.danger),
                                  onPressed: () => _confirmDeleteRule(rule),
                                ),
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
