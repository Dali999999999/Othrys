import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_theme.dart';
import '../../core/l10n/l10n.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/connection_guard.dart';
import '../servers/server_controller.dart';
import 'docker_controller.dart';
import 'docker_logs_dialog.dart';
import 'widgets/docker_compose_tab.dart';
import 'widgets/docker_container_tile.dart';
import 'widgets/docker_not_installed_view.dart';

/// Presentation view orchestrating the discovery and management of Docker containers and Compose.
class DockerView extends ConsumerStatefulWidget {
  const DockerView({super.key});

  @override
  ConsumerState<DockerView> createState() => _DockerViewState();
}

class _DockerViewState extends ConsumerState<DockerView> {
  int _selectedTab = 0;
  late final TextEditingController _composePathController;

  @override
  void initState() {
    super.initState();
    _composePathController = TextEditingController(text: '.');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  @override
  void dispose() {
    _composePathController.dispose();
    super.dispose();
  }

  void _refresh() {
    final session = ref.read(serverControllerProvider).activeSession;
    if (session != null) {
      ref.read(dockerControllerProvider.notifier).loadContainers(session.sessionId);
    }
  }

  Future<void> _handleContainerAction(DockerContainerEntity container, String action) async {
    final session = ref.read(serverControllerProvider).activeSession;
    final server = ref.read(serverControllerProvider).selectedServer;
    if (session == null) return;

    if (action == 'stop' || action == 'rm') {
      final isRm = action == 'rm';
      final confirmed = await ConfirmDialog.show(
        context: context,
        title: isRm ? context.l10n.dockerRemove : context.l10n.dockerStop,
        content: isRm
            ? context.l10n.dockerConfirmRemove(container.names)
            : context.l10n.dockerConfirmStop(container.names),
        confirmText: isRm ? context.l10n.dockerRemove : context.l10n.dockerStop,
        isDanger: true,
      );
      if (!confirmed) return;
    }

    final notifier = ref.read(dockerControllerProvider.notifier);
    final result = await switch (action) {
      'start' => notifier.startContainer(session.sessionId, container, server: server),
      'stop' => notifier.stopContainer(session.sessionId, container, server: server),
      'restart' => notifier.restartContainer(session.sessionId, container, server: server),
      'rm' => notifier.removeContainer(session.sessionId, container, server: server),
      _ => notifier.startContainer(session.sessionId, container, server: server),
    };

    if (result.isFailure && mounted) {
      displayInfoBar(context, builder: (ctx, close) {
        return InfoBar(
          title: Text(context.l10n.commonError),
          content: Text(result.failureOrNull?.message ?? 'Unknown error'),
          severity: InfoBarSeverity.error,
          onClose: close,
        );
      });
    }
  }

  void _viewLogs(DockerContainerEntity container) {
    final session = ref.read(serverControllerProvider).activeSession;
    if (session == null) return;

    DockerLogsDialog.show(
      context: context,
      sessionId: session.sessionId,
      containerId: container.id,
      containerName: container.names,
    );
  }

  Future<void> _runComposeAction(String action) async {
    final session = ref.read(serverControllerProvider).activeSession;
    final server = ref.read(serverControllerProvider).selectedServer;
    if (session == null) return;

    final path = _composePathController.text.trim();
    if (path.isEmpty) return;

    if (action == 'down') {
      final confirmed = await ConfirmDialog.show(
        context: context,
        title: context.l10n.dockerComposeDown,
        content: context.l10n.dockerComposeDownConfirm(path),
        confirmText: context.l10n.dockerComposeDown,
        isDanger: true,
      );
      if (!confirmed) return;
    }

    await ref.read(dockerControllerProvider.notifier).runComposeAction(
          session.sessionId,
          path,
          action,
          server: server,
        );
  }

  @override
  Widget build(BuildContext context) {
    return ConnectionGuard(
      customMessage: context.l10n.dockerGuardMessage,
      child: _buildDockerPage(context),
    );
  }

  Widget _buildDockerPage(BuildContext context) {
    final activeSession = ref.watch(serverControllerProvider).activeSession!;
    final dockerState = ref.watch(dockerControllerProvider);
    final priv = activeSession.privileges;
    final canManageDocker = priv == null || priv.canManageDocker;

    return ScaffoldPage(
      header: PageHeader(
        title: Text('${activeSession.server.name} — ${context.l10n.dockerTitle}'),
        commandBar: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(FluentIcons.refresh, size: AppIconSize.md),
              onPressed: dockerState.isLoading ? null : _refresh,
            ),
          ],
        ),
      ),
      content: dockerState.isLoading && dockerState.containers.isEmpty
          ? const Center(child: ProgressRing())
          : !dockerState.isDockerInstalled
              ? DockerNotInstalledView(onRefresh: _refresh)
              : Column(
                  children: [
                    if (!canManageDocker) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xxl,
                          vertical: AppSpacing.sm,
                        ),
                        child: InfoBar(
                          title: Text(context.l10n.dockerPermissionRestricted(priv.username)),
                          severity: InfoBarSeverity.warning,
                          isLong: true,
                        ),
                      ),
                    ],
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                      color: AppColors.surfaceElevated(context),
                      child: Row(
                        children: [
                          _buildTabButton(0, context.l10n.dockerContainers, dockerState.containers.length),
                          const SizedBox(width: AppSpacing.sm),
                          _buildTabButton(1, context.l10n.dockerCompose, null),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _selectedTab == 0
                          ? _buildContainersView(context, dockerState, canManageDocker)
                          : DockerComposeTab(
                              state: dockerState,
                              composePathController: _composePathController,
                              onRunAction: _runComposeAction,
                              canManage: canManageDocker,
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildTabButton(int index, String label, int? count) {
    final isSelected = _selectedTab == index;
    return Button(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(
          isSelected ? AppColors.surfaceCard(context) : Colors.transparent,
        ),
      ),
      onPressed: () => setState(() => _selectedTab = index),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypo.body(context).copyWith(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? AppColors.textPrimary(context) : AppColors.textMuted(context),
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: AppSpacing.xs),
            Container(
              padding: AppSpacing.badgePadding,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.badgeBackground(AppColors.brandCyan)
                    : AppColors.surfaceElevated(context),
                borderRadius: AppRadius.borderPill,
              ),
              child: Text(
                '$count',
                style: AppTypo.nano(context).copyWith(
                  color: isSelected ? AppColors.brandCyan : AppColors.textMuted(context),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContainersView(BuildContext context, DockerState dockerState, bool canManageDocker) {
    if (dockerState.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(FluentIcons.warning, size: AppIconSize.xl, color: AppColors.warning),
            const SizedBox(height: AppSpacing.md),
            Text(
              dockerState.error!,
              style: AppTypo.bodySmall(context),
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton(onPressed: _refresh, child: Text(context.l10n.commonRetry)),
          ],
        ),
      );
    }

    if (dockerState.containers.isEmpty) {
      return Center(
        child: Text(
          context.l10n.dockerNoContainers,
          style: AppTypo.bodySmall(context),
        ),
      );
    }

    return ListView.builder(
      itemCount: dockerState.containers.length,
      itemBuilder: (ctx, index) {
        final c = dockerState.containers[index];
        return DockerContainerTile(
          container: c,
          canManage: canManageDocker,
          onViewLogs: () => _viewLogs(c),
          onAction: (action) => _handleContainerAction(c, action),
        );
      },
    );
  }
}
