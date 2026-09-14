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
import '../server_admin_controller.dart';
import 'firewall_rule_dialog.dart';

/// Tab presenting active listening network sockets (TCP/UDP) and their processes.
class ListeningPortsTab extends ConsumerStatefulWidget {
  final String sessionId;
  final ServerEntity? server;
  final bool canManage;

  const ListeningPortsTab({
    super.key,
    required this.sessionId,
    this.server,
    required this.canManage,
  });

  @override
  ConsumerState<ListeningPortsTab> createState() => _ListeningPortsTabState();
}

class _ListeningPortsTabState extends ConsumerState<ListeningPortsTab> {
  String _searchQuery = '';

  void _openFirewallForPort(int port) async {
    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => FirewallRuleDialog(
        sessionId: widget.sessionId,
        server: widget.server,
        initialPort: port.toString(),
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

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(serverAdminControllerProvider);
    final ports = adminState.listeningPorts;

    final filtered = ports.where((p) {
      final q = _searchQuery.toLowerCase();
      final portMatch = p.port.toString().contains(q);
      final procMatch = (p.processName ?? '').toLowerCase().contains(q);
      final addrMatch = p.localAddress.toLowerCase().contains(q);
      return portMatch || procMatch || addrMatch;
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                '${filtered.length} ${filtered.length > 1 ? "ports" : "port"}',
                style: AppTypo.caption(context).copyWith(color: AppColors.textMuted(context)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Ports List
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
                      final item = filtered[idx];

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard(context),
                          borderRadius: AppRadius.borderSm,
                          border: Border.all(color: AppColors.surfaceBorder(context)),
                        ),
                        child: Row(
                          children: [
                            // Protocol
                            AppBadge(
                              label: item.protocol.toUpperCase(),
                              variant: item.protocol == 'tcp' ? AppBadgeVariant.info : AppBadgeVariant.warning,
                            ),
                            const SizedBox(width: AppSpacing.md),

                            // Port & Local Address
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ':${item.port}',
                                    style: AppTypo.titleMedium(context).copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: AppTypo.fontMono,
                                      color: AppColors.accentCyan,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.localAddress,
                                    style: AppTypo.caption(context).copyWith(
                                      fontFamily: AppTypo.fontMono,
                                      color: AppColors.textMuted(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Scope Badge (Public vs Local)
                            AppBadge(
                              label: item.isLoopbackOnly
                                  ? context.l10n.adminPortsLocal
                                  : context.l10n.adminPortsPublic,
                              variant: item.isLoopbackOnly ? AppBadgeVariant.neutral : AppBadgeVariant.warning,
                            ),
                            const SizedBox(width: AppSpacing.md),

                            // Process Name & PID
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.processName ?? 'unknown process',
                                    style: AppTypo.bodySmall(context).copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  if (item.pid != null)
                                    Text(
                                      'PID: ${item.pid}',
                                      style: AppTypo.micro(context).copyWith(color: AppColors.textMuted(context)),
                                    ),
                                ],
                              ),
                            ),

                            // Allow in Firewall action
                            if (widget.canManage)
                              Tooltip(
                                message: context.l10n.adminPortsAllowInFirewall,
                                child: Button(
                                  onPressed: () => _openFirewallForPort(item.port),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(FluentIcons.shield, size: AppIconSize.xs),
                                      const SizedBox(width: AppSpacing.xs),
                                      Text(context.l10n.adminPortsAllowInFirewall),
                                    ],
                                  ),
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
