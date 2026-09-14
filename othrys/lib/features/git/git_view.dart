import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_icons.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/l10n/l10n.dart';
import '../../core/utils/result.dart';
import '../servers/server_controller.dart';
import '../../shared/widgets/confirm_dialog.dart';
import 'git_controller.dart';
import 'widgets/git_branches_tab.dart';
import 'widgets/git_clone_dialog.dart';
import 'widgets/git_deploy_key_tab.dart';
import 'widgets/git_history_tab.dart';
import 'widgets/git_status_tab.dart';

/// Main Git management dashboard view for VPS servers.
class GitView extends ConsumerStatefulWidget {
  final Function(int tabIndex)? onNavigateToTab;

  const GitView({super.key, this.onNavigateToTab});

  @override
  ConsumerState<GitView> createState() => _GitViewState();
}

class _GitViewState extends ConsumerState<GitView> {
  int _selectedSubTab = 0;
  String? _lastSessionId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initData());
  }

  void _initData() {
    final session = ref.read(serverControllerProvider).activeSession;
    if (session != null) {
      _lastSessionId = session.sessionId;
      ref.read(gitControllerProvider.notifier).loadTrackedRepositories(session.sessionId, session.server.id);
    }
  }

  Future<void> _installGit(String sessionId, ServerEntity server) async {
    final res = await ref.read(gitControllerProvider.notifier).installGit(sessionId, server: server);
    if (!mounted) return;
    if (res is Success) {
      displayInfoBar(
        context,
        builder: (ctx, close) => InfoBar(
          title: Text(context.l10n.gitInstalledSuccessTitle),
          content: Text(context.l10n.gitInstalledSuccessDesc),
          severity: InfoBarSeverity.success,
        ),
      );
    }
  }

  Future<void> _scanServer(String sessionId, String serverId) async {
    final found = await ref.read(gitControllerProvider.notifier).scanServer(sessionId, serverId);
    if (!mounted) return;
    displayInfoBar(
      context,
      builder: (ctx, close) => InfoBar(
        title: Text(context.l10n.gitScanFound(found)),
        severity: InfoBarSeverity.info,
        onClose: close,
      ),
    );
  }

  Future<void> _openCloneDialog(String sessionId, String serverId, ServerEntity server) async {
    await showDialog(
      context: context,
      builder: (_) => GitCloneDialog(
        sessionId: sessionId,
        serverId: serverId,
        server: server,
      ),
    );
  }

  Future<void> _addRepoPathDialog(String sessionId, String serverId) async {
    final controller = TextEditingController();
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => ContentDialog(
        title: Text(context.l10n.gitAddRepoPathTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.gitAddRepoPath, style: AppTypo.caption(ctx)),
            const SizedBox(height: AppSpacing.xs),
            TextBox(
              controller: controller,
              placeholder: context.l10n.gitAddRepoPathPlaceholder,
            ),
          ],
        ),
        actions: [
          Button(
            child: Text(context.l10n.commonCancel),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          FilledButton(
            child: Text(context.l10n.commonConfirm),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (res == true && controller.text.trim().isNotEmpty) {
      final addRes = await ref.read(gitControllerProvider.notifier).addTrackedRepository(
            sessionId,
            serverId,
            controller.text.trim(),
          );
      if (mounted && addRes is Failure) {
        displayInfoBar(
          context,
          builder: (ctx, close) => InfoBar(
            title: Text(context.l10n.commonError),
            content: Text(addRes.message),
            severity: InfoBarSeverity.error,
            onClose: close,
          ),
        );
      }
    }
  }

  Future<void> _untrackRepo(String serverId, GitRepositoryInfo repo) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: context.l10n.gitRemoveTracked,
      content: context.l10n.gitRemoveTrackedConfirm(repo.name),
      confirmText: context.l10n.gitRemoveTracked,
      isDanger: true,
    );

    if (confirmed) {
      await ref.read(gitControllerProvider.notifier).removeTrackedRepository(serverId, repo.path);
    }
  }

  Future<void> _pull(String sessionId, String repoPath, ServerEntity server) async {
    final res = await ref.read(gitControllerProvider.notifier).pull(sessionId, repoPath, server: server);
    if (!mounted) return;
    if (res is Success) {
      displayInfoBar(
        context,
        builder: (ctx, close) => InfoBar(
          title: Text(context.l10n.gitPullSuccess),
          severity: InfoBarSeverity.success,
          onClose: close,
        ),
      );
    }
  }

  Future<void> _fetch(String sessionId, String repoPath, ServerEntity server) async {
    final res = await ref.read(gitControllerProvider.notifier).fetch(sessionId, repoPath, server: server);
    if (!mounted) return;
    if (res is Success) {
      displayInfoBar(
        context,
        builder: (ctx, close) => InfoBar(
          title: Text(context.l10n.gitFetchSuccess),
          severity: InfoBarSeverity.success,
          onClose: close,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final serverState = ref.watch(serverControllerProvider);
    final activeSession = serverState.activeSession;
    final gitState = ref.watch(gitControllerProvider);

    if (activeSession == null) {
      return ScaffoldPage(
        header: PageHeader(title: Text(context.l10n.gitTitle)),
        content: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(FluentIcons.plug_disconnected, size: AppIconSize.hero, color: AppColors.danger),
              const SizedBox(height: AppSpacing.md),
              Text(context.l10n.guardNoConnectionTitle, style: AppTypo.titleMedium(context)),
              const SizedBox(height: AppSpacing.xs),
              Text(context.l10n.guardNoConnectionSubtitle, style: AppTypo.caption(context)),
            ],
          ),
        ),
      );
    }

    if (activeSession.sessionId != _lastSessionId) {
      _lastSessionId = activeSession.sessionId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(gitControllerProvider.notifier).loadTrackedRepositories(activeSession.sessionId, activeSession.server.id);
      });
    }

    final hasPrivileges = activeSession.privileges?.canManageSystem ?? false;

    return ScaffoldPage(
      header: PageHeader(
        title: Text(context.l10n.gitTitle, style: AppTypo.titleLarge(context)),
        commandBar: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (gitState.isLoading)
              const Padding(
                padding: EdgeInsets.only(right: AppSpacing.sm),
                child: SizedBox(
                  width: 14,
                  height: 14,
                  child: ProgressRing(strokeWidth: 2),
                ),
              ),
            Tooltip(
              message: context.l10n.gitScanServer,
              child: IconButton(
                icon: const Icon(FluentIcons.search, size: AppIconSize.md),
                onPressed: () => _scanServer(activeSession.sessionId, activeSession.server.id),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Tooltip(
              message: context.l10n.gitAddRepoPath,
              child: IconButton(
                icon: const Icon(FluentIcons.folder_open, size: AppIconSize.md),
                onPressed: () => _addRepoPathDialog(activeSession.sessionId, activeSession.server.id),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            if (gitState.selectedRepoPath != null) ...[
              Tooltip(
                message: context.l10n.gitFetch,
                child: IconButton(
                  icon: const Icon(FluentIcons.refresh, size: AppIconSize.md),
                  onPressed: () => ref.read(gitControllerProvider.notifier).refreshRepository(
                        activeSession.sessionId,
                        gitState.selectedRepoPath!,
                      ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            FilledButton(
              onPressed: () => _openCloneDialog(activeSession.sessionId, activeSession.server.id, activeSession.server),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(FluentIcons.add, size: AppIconSize.sm, color: Colors.white),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    context.l10n.gitClone,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          children: [
            // Git Not Installed Banner
            if (!gitState.isGitInstalled) ...[
              InfoBar(
                title: Text(context.l10n.gitNotInstalledTitle),
                content: Text(context.l10n.gitNotInstalledDesc),
                severity: InfoBarSeverity.warning,
                action: hasPrivileges
                    ? FilledButton(
                        onPressed: () => _installGit(activeSession.sessionId, activeSession.server),
                        child: Text(
                          context.l10n.gitInstallBtn,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Active Repository Overview
            if (gitState.selectedRepo != null) ...[
              _buildRepoOverview(
                context,
                activeSession.sessionId,
                activeSession.server,
                gitState.selectedRepo!,
                gitState.trackedRepoPaths,
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Sub-tabs navigation
            if (gitState.selectedRepo != null) ...[
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  _buildSubTabButton(0, context.l10n.gitTabStatus, FluentIcons.file_code),
                  _buildSubTabButton(1, context.l10n.gitTabBranches, FluentIcons.branch_fork),
                  _buildSubTabButton(2, context.l10n.gitTabHistory, FluentIcons.history),
                  _buildSubTabButton(3, context.l10n.gitTabDeployKey, FluentIcons.lock),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: switch (_selectedSubTab) {
                  0 => GitStatusTab(
                      sessionId: activeSession.sessionId,
                      server: activeSession.server,
                      repo: gitState.selectedRepo!,
                    ),
                  1 => GitBranchesTab(
                      sessionId: activeSession.sessionId,
                      server: activeSession.server,
                      repo: gitState.selectedRepo!,
                    ),
                  2 => GitHistoryTab(commits: gitState.history),
                  3 => GitDeployKeyTab(
                      sessionId: activeSession.sessionId,
                      server: activeSession.server,
                      deployKey: gitState.deployKey,
                      gitConfig: gitState.gitConfig,
                    ),
                  _ => const SizedBox.shrink(),
                },
              ),
            ] else if (gitState.trackedRepoPaths.isEmpty) ...[
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(FluentIcons.branch_fork, size: AppIconSize.hero, color: AppColors.accentCyan.withValues(alpha: 0.5)),
                      const SizedBox(height: AppSpacing.md),
                      Text(context.l10n.gitNoReposTitle, style: AppTypo.titleMedium(context)),
                      const SizedBox(height: AppSpacing.xs),
                      Text(context.l10n.gitNoReposDesc, style: AppTypo.caption(context)),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FilledButton(
                            onPressed: () => _openCloneDialog(activeSession.sessionId, activeSession.server.id, activeSession.server),
                            child: Text(
                              context.l10n.gitClone,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Button(
                            onPressed: () => _scanServer(activeSession.sessionId, activeSession.server.id),
                            child: Text(context.l10n.gitScanServer),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              const Expanded(
                child: Center(child: ProgressRing()),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubTabButton(int index, String title, IconData icon) {
    final isSelected = _selectedSubTab == index;
    return Button(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(
          isSelected ? AppColors.accentCyan.withValues(alpha: 0.2) : AppColors.surfaceElevated(context),
        ),
      ),
      onPressed: () => setState(() => _selectedSubTab = index),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppIconSize.sm, color: isSelected ? AppColors.accentCyan : AppColors.textMuted(context)),
          const SizedBox(width: AppSpacing.xs),
          Text(
            title,
            style: AppTypo.caption(context).copyWith(
              color: isSelected ? AppColors.accentCyan : AppColors.textPrimary(context),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepoOverview(
    BuildContext context,
    String sessionId,
    ServerEntity server,
    GitRepositoryInfo repo,
    List<String> trackedRepoPaths,
  ) {
    return Card(
      backgroundColor: AppColors.surfaceElevated(context),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Repo Icon + Name/Switcher + Path + Untrack
          Row(
            children: [
              const Icon(FluentIcons.branch_fork, color: AppColors.accentCyan, size: AppIconSize.lg),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (trackedRepoPaths.length > 1)
                      ComboBox<String>(
                        value: repo.path,
                        items: trackedRepoPaths.map((path) {
                          final name = path.split('/').where((s) => s.isNotEmpty).lastOrNull ?? path;
                          return ComboBoxItem<String>(
                            value: path,
                            child: Text(name, style: AppTypo.body(context).copyWith(fontWeight: FontWeight.bold)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            ref.read(gitControllerProvider.notifier).selectRepository(sessionId, val);
                          }
                        },
                      )
                    else
                      Text(repo.name, style: AppTypo.titleMedium(context)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            repo.path,
                            style: AppTypo.code(context).copyWith(fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        IconButton(
                          icon: const Icon(FluentIcons.copy, size: AppIconSize.xs),
                          onPressed: () => Clipboard.setData(ClipboardData(text: repo.path)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Tooltip(
                message: context.l10n.gitRemoveTracked,
                child: IconButton(
                  icon: const Icon(FluentIcons.delete, size: AppIconSize.sm, color: AppColors.danger),
                  onPressed: () => _untrackRepo(server.id, repo),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Row 2: Status & Quick Actions in a Wrap (immune to overflow)
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Branch pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceBase(context),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.surfaceBorder(context)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(FluentIcons.branch_fork, size: AppIconSize.xs, color: AppColors.accentCyan),
                    const SizedBox(width: AppSpacing.xs),
                    Text(repo.currentBranch, style: AppTypo.caption(context).copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              // Sync status pill
              if (repo.behindCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.warning),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(FluentIcons.cloud_download, size: AppIconSize.sm, color: AppColors.warning),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        context.l10n.gitStatusBehind(repo.behindCount),
                        style: const TextStyle(color: AppColors.warning, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              else if (repo.aheadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentCyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.accentCyan),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(FluentIcons.cloud_upload, size: AppIconSize.sm, color: AppColors.accentCyan),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        context.l10n.gitStatusAhead(repo.aheadCount),
                        style: const TextStyle(color: AppColors.accentCyan, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(FluentIcons.check_mark, size: AppIconSize.sm, color: AppColors.success),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        context.l10n.gitStatusUpToDate,
                        style: const TextStyle(color: AppColors.success, fontSize: 11),
                      ),
                    ],
                  ),
                ),

              // Pull button
              FilledButton(
                onPressed: () => _pull(sessionId, repo.path, server),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(FluentIcons.down, size: AppIconSize.sm, color: Colors.white),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      context.l10n.gitPull,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

              // Fetch button
              Button(
                onPressed: () => _fetch(sessionId, repo.path, server),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(FluentIcons.refresh, size: AppIconSize.sm),
                    const SizedBox(width: AppSpacing.xs),
                    Text(context.l10n.gitFetch),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
