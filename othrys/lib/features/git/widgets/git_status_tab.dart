import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_icons.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/models/server_entity.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../git_controller.dart';
import 'git_commit_dialog.dart';

/// Tab displaying the working tree status, modified/untracked files, and commit/stash actions.
class GitStatusTab extends ConsumerWidget {
  final String sessionId;
  final ServerEntity? server;
  final GitRepositoryInfo repo;

  const GitStatusTab({
    super.key,
    required this.sessionId,
    this.server,
    required this.repo,
  });

  Color _getStatusColor(GitChangeType type) {
    return switch (type) {
      GitChangeType.modified => AppColors.accentCyan,
      GitChangeType.untracked || GitChangeType.added => AppColors.success,
      GitChangeType.deleted => AppColors.danger,
      GitChangeType.renamed || GitChangeType.copied => AppColors.accentPurple,
    };
  }

  Future<void> _discardChanges(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: context.l10n.gitDiscardChanges,
      content: context.l10n.gitDiscardConfirm,
      confirmText: context.l10n.gitDiscardChanges,
      isDanger: true,
    );

    if (confirmed) {
      await ref.read(gitControllerProvider.notifier).discardChanges(sessionId, repo.path, server: server);
    }
  }

  Future<void> _stashChanges(WidgetRef ref) async {
    await ref.read(gitControllerProvider.notifier).stashChanges(sessionId, repo.path);
  }

  Future<void> _popStash(WidgetRef ref) async {
    await ref.read(gitControllerProvider.notifier).popStash(sessionId, repo.path);
  }

  Future<void> _openCommitDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) => GitCommitDialog(
        sessionId: sessionId,
        repoPath: repo.path,
        server: server,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (repo.isClean) {
      return Card(
        backgroundColor: AppColors.surfaceElevated(context),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(FluentIcons.check_mark, color: AppColors.success, size: AppIconSize.xl),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(context.l10n.gitStatusClean, style: AppTypo.titleMedium(context)),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${context.l10n.gitBranchCurrent}: ${repo.currentBranch}',
                style: AppTypo.caption(context),
              ),
              const SizedBox(height: AppSpacing.md),
              Button(
                onPressed: () => _popStash(ref),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(FluentIcons.archive, size: AppIconSize.sm),
                    const SizedBox(width: AppSpacing.xs),
                    Text(context.l10n.gitStashPop, style: AppTypo.caption(context)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Action Bar for dirty tree
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.spaceBetween,
          children: [
            Text(
              context.l10n.gitStatusDirty(repo.changedFiles.length),
              style: AppTypo.titleMedium(context),
            ),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                Button(
                  onPressed: () => _discardChanges(context, ref),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(FluentIcons.delete, size: AppIconSize.sm, color: AppColors.danger),
                      const SizedBox(width: AppSpacing.xs),
                      Text(context.l10n.gitDiscardChanges, style: AppTypo.caption(context)),
                    ],
                  ),
                ),
                Button(
                  onPressed: () => _stashChanges(ref),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(FluentIcons.archive, size: AppIconSize.sm),
                      const SizedBox(width: AppSpacing.xs),
                      Text(context.l10n.gitStash, style: AppTypo.caption(context)),
                    ],
                  ),
                ),
                FilledButton(
                  onPressed: () => _openCommitDialog(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(FluentIcons.branch_commit, size: AppIconSize.sm, color: Colors.white),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        context.l10n.gitCommit,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Changed Files List
        Expanded(
          child: ListView.separated(
            itemCount: repo.changedFiles.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
            itemBuilder: (context, index) {
              final file = repo.changedFiles[index];
              final color = _getStatusColor(file.type);

              return Card(
                backgroundColor: AppColors.surfaceElevated(context),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: color.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        file.statusCode,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        file.path,
                        style: AppTypo.code(context).copyWith(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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
