import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/formatters.dart';
import '../../core/l10n/l10n.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_icons.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../shared/widgets/app_badge.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_empty_state.dart';
import '../../shared/widgets/app_status_dot.dart';
import '../../shared/widgets/confirm_dialog.dart';
import 'server_controller.dart';
import 'server_dialog.dart';

/// Presentation-only view displaying the server inventory and quick connect actions.
class ServersView extends ConsumerStatefulWidget {
  final Function(int targetNavIndex)? onNavigateToTab;

  const ServersView({super.key, this.onNavigateToTab});

  @override
  ConsumerState<ServersView> createState() => _ServersViewState();
}

class _ServersViewState extends ConsumerState<ServersView> {
  String _searchQuery = '';

  void _openAddDialog() async {
    final state = ref.read(serverControllerProvider);
    final newServer = await showDialog<ServerEntity>(
      context: context,
      builder: (ctx) => ServerDialog(existingServers: state.servers),
    );

    if (newServer != null) {
      await ref.read(serverControllerProvider.notifier).saveServer(newServer);
    }
  }

  void _openEditDialog(ServerEntity server) async {
    final state = ref.read(serverControllerProvider);
    final updatedServer = await showDialog<ServerEntity>(
      context: context,
      builder: (ctx) => ServerDialog(
        initialServer: server,
        existingServers: state.servers,
      ),
    );

    if (updatedServer != null) {
      await ref.read(serverControllerProvider.notifier).saveServer(updatedServer);
    }
  }

  void _confirmDelete(ServerEntity server) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: context.l10n.serversDeleteConfirmTitle,
      content: context.l10n.serversDeleteConfirmMessage(server.name),
      confirmText: context.l10n.commonDelete,
      isDanger: true,
    );

    if (confirmed) {
      await ref.read(serverControllerProvider.notifier).deleteServer(server.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final serverState = ref.watch(serverControllerProvider);
    final filteredServers = serverState.servers.where((s) {
      final q = _searchQuery.toLowerCase();
      return s.name.toLowerCase().contains(q) ||
          s.host.toLowerCase().contains(q) ||
          (s.group?.toLowerCase().contains(q) ?? false);
    }).toList();

    return ScaffoldPage(
      header: PageHeader(
        title: Text(context.l10n.serversTitle),
        commandBar: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 160,
              child: TextBox(
                placeholder: context.l10n.serversFilterPlaceholder,
                prefix: Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.sm),
                  child: Icon(FluentIcons.search, size: AppIconSize.sm, color: AppColors.textMuted(context)),
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),
            if (serverState.isLoading && serverState.servers.isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(right: AppSpacing.sm),
                child: SizedBox(
                  width: 14,
                  height: 14,
                  child: ProgressRing(strokeWidth: 2),
                ),
              ),
            FilledButton(
              onPressed: _openAddDialog,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(FluentIcons.add, size: AppIconSize.sm),
                  const SizedBox(width: 6),
                  Text(context.l10n.serversAdd),
                ],
              ),
            ),
          ],
        ),
      ),
      content: serverState.isLoading && serverState.servers.isEmpty
          ? const Center(child: ProgressRing())
          : filteredServers.isEmpty
              ? _buildEmptyState()
              : _buildServerGrid(filteredServers, serverState.activeSession?.server.id),
    );
  }

  Widget _buildEmptyState() {
    return AppEmptyState(
      icon: FluentIcons.server,
      title: context.l10n.serversEmptyTitle,
      subtitle: context.l10n.serversEmptySubtitle,
      actionLabel: context.l10n.serversAddFirst,
      onAction: _openAddDialog,
    );
  }

  Widget _buildServerGrid(List<ServerEntity> servers, String? activeServerId) {
    return Padding(
      padding: AppSpacing.pageContent,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 380,
          mainAxisExtent: 220,
          crossAxisSpacing: AppSpacing.lg,
          mainAxisSpacing: AppSpacing.lg,
        ),
        itemCount: servers.length,
        itemBuilder: (context, index) {
          final server = servers[index];
          final isConnected = activeServerId == server.id;

          return AppCard(
            isActive: isConnected,
            padding: AppSpacing.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: isConnected
                            ? AppColors.badgeBackground(AppColors.brandBlue)
                            : AppColors.surfaceElevated(context),
                        borderRadius: AppRadius.borderSm,
                      ),
                      child: Icon(
                        FluentIcons.server,
                        size: AppIconSize.lg,
                        color: isConnected ? AppColors.brandBlue : AppColors.textMuted(context),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            server.name,
                            style: AppTypo.body(context).copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${server.username}@${server.host}:${server.port}',
                            style: AppTypo.codeMuted(context),
                          ),
                        ],
                      ),
                    ),
                    AppStatusDot(
                      variant: isConnected ? StatusDotVariant.success : StatusDotVariant.inactive,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (server.group != null && server.group!.isNotEmpty)
                      AppBadge(
                        label: server.group!,
                        variant: AppBadgeVariant.info,
                      )
                    else
                      const SizedBox.shrink(),
                    Text(
                      server.lastConnected != null
                          ? context.l10n.serversSeen(Formatters.formatDateTime(server.lastConnected!))
                          : context.l10n.serversNeverConnected,
                      style: AppTypo.nano(context).copyWith(
                        color: AppColors.textFaint(context),
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  children: [
                    if (!isConnected)
                      FilledButton(
                        onPressed: () async {
                          final result = await ref
                              .read(serverControllerProvider.notifier)
                              .connectToServer(server);
                          if (result.isSuccess && widget.onNavigateToTab != null) {
                            widget.onNavigateToTab!(1);
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(FluentIcons.plug_connected, size: AppIconSize.sm),
                            const SizedBox(width: 6),
                            Text(context.l10n.commonConnect),
                          ],
                        ),
                      )
                    else
                      Button(
                        style: ButtonStyle(
                          foregroundColor: WidgetStateProperty.all(AppColors.danger),
                        ),
                        onPressed: () => ref.read(serverControllerProvider.notifier).disconnectCurrent(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(FluentIcons.plug_disconnected, size: AppIconSize.sm),
                            const SizedBox(width: 6),
                            Text(context.l10n.commonDisconnect),
                          ],
                        ),
                      ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(FluentIcons.edit, size: AppIconSize.md),
                      onPressed: () => _openEditDialog(server),
                    ),
                    IconButton(
                      icon: const Icon(FluentIcons.delete, size: AppIconSize.md, color: AppColors.danger),
                      onPressed: () => _confirmDelete(server),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
