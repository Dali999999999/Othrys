import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_icons.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/l10n/l10n.dart';
import '../../shared/widgets/app_badge.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_empty_state.dart';
import '../../shared/widgets/app_status_dot.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/connection_guard.dart';
import '../servers/server_controller.dart';
import 'tunnel_controller.dart';
import 'tunnel_dialog.dart';

/// Presentation view for managing SSH tunnels and port forwarding rules.
class TunnelsView extends ConsumerStatefulWidget {
  const TunnelsView({super.key});

  @override
  ConsumerState<TunnelsView> createState() => _TunnelsViewState();
}

class _TunnelsViewState extends ConsumerState<TunnelsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  void _refresh() {
    final server = ref.read(serverControllerProvider).selectedServer;
    if (server != null) {
      ref.read(tunnelControllerProvider.notifier).loadTunnels(serverId: server.id);
    }
  }

  Future<void> _openAddTunnelDialog() async {
    final server = ref.read(serverControllerProvider).selectedServer;
    if (server == null) return;

    final newTunnel = await TunnelDialog.show(
      context: context,
      serverId: server.id,
    );

    if (newTunnel != null) {
      await ref.read(tunnelControllerProvider.notifier).createTunnel(newTunnel);
    }
  }

  Future<void> _toggleTunnel(TunnelEntity tunnel) async {
    final session = ref.read(serverControllerProvider).activeSession;
    if (session == null) return;

    final result = await ref.read(tunnelControllerProvider.notifier).toggleTunnel(session.sessionId, tunnel);

    if (result.isFailure && mounted) {
      displayInfoBar(context, builder: (ctx, close) {
        return InfoBar(
          title: Text(context.l10n.commonError),
          content: Text(result.failureOrNull?.message ?? 'Failed to toggle tunnel'),
          severity: InfoBarSeverity.error,
          onClose: close,
        );
      });
    }
  }

  Future<void> _deleteTunnel(TunnelEntity tunnel) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: context.l10n.tunnelsDeleteConfirmTitle,
      content: context.l10n.tunnelsDeleteConfirmMessage(tunnel.name),
      confirmText: context.l10n.commonDelete,
      isDanger: true,
    );

    if (confirmed) {
      final server = ref.read(serverControllerProvider).selectedServer;
      await ref.read(tunnelControllerProvider.notifier).deleteTunnel(
        tunnel.id,
        serverId: server?.id,
        tunnel: tunnel,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConnectionGuard(
      customMessage: context.l10n.tunnelsGuardMessage,
      child: _buildTunnelsPage(context),
    );
  }

  Widget _buildTunnelsPage(BuildContext context) {
    final tunnelState = ref.watch(tunnelControllerProvider);
    final tunnels = tunnelState.tunnels;

    return ScaffoldPage(
      header: PageHeader(
        title: Text(context.l10n.tunnelsTitle),
        commandBar: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (tunnelState.isLoading && tunnels.isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(right: AppSpacing.sm),
                child: SizedBox(
                  width: 14,
                  height: 14,
                  child: ProgressRing(strokeWidth: 2),
                ),
              ),
            FilledButton(
              onPressed: _openAddTunnelDialog,
              child: Row(
                children: [
                  const Icon(FluentIcons.add, size: AppIconSize.sm),
                  const SizedBox(width: 6),
                  Text(context.l10n.tunnelsNew),
                ],
              ),
            ),
          ],
        ),
      ),
      content: Column(
        children: [
          if (tunnelState.error != null)
            Padding(
              padding: AppSpacing.pageContent,
              child: InfoBar(
                title: Text(context.l10n.commonError),
                content: Text(tunnelState.error!),
                severity: InfoBarSeverity.error,
              ),
            ),
          Expanded(
            child: tunnelState.isLoading && tunnels.isEmpty
                ? const Center(child: ProgressRing())
                : tunnels.isEmpty
                    ? AppEmptyState(
                        icon: FluentIcons.branch_fork2,
                        title: context.l10n.tunnelsEmptyTitle,
                        subtitle: context.l10n.tunnelsEmptySubtitle,
                        actionLabel: context.l10n.tunnelsNew,
                        onAction: _openAddTunnelDialog,
                      )
                    : ListView.separated(
                        padding: AppSpacing.pageContent,
                        itemCount: tunnels.length,
                        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final t = tunnels[index];
                          final isActive = tunnelState.activeStatuses[t.id] ?? false;

                          return AppCard(
                            isActive: isActive,
                            padding: AppSpacing.cardPadding,
                            child: Row(
                              children: [
                                AppStatusDot(
                                  variant: isActive ? StatusDotVariant.success : StatusDotVariant.inactive,
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            t.name,
                                            style: AppTypo.body(context).copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary(context),
                                            ),
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          AppBadge(
                                            label: t.type.name.toUpperCase(),
                                            variant: AppBadgeVariant.info,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        'localhost:${t.localPort} ➔ ${t.remoteHost}:${t.remotePort}',
                                        style: AppTypo.codeAccent(context),
                                      ),
                                    ],
                                  ),
                                ),
                                ToggleSwitch(
                                  checked: isActive,
                                  onChanged: (_) => _toggleTunnel(t),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                IconButton(
                                  icon: const Icon(FluentIcons.delete, size: AppIconSize.md, color: AppColors.danger),
                                  onPressed: () => _deleteTunnel(t),
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
