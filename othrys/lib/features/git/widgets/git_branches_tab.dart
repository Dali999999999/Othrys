import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_icons.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/models/server_entity.dart';
import '../git_controller.dart';

/// Tab displaying local and remote branches with checkout and creation options.
class GitBranchesTab extends ConsumerWidget {
  final String sessionId;
  final ServerEntity? server;
  final GitRepositoryInfo repo;

  const GitBranchesTab({
    super.key,
    required this.sessionId,
    this.server,
    required this.repo,
  });

  Future<void> _openNewBranchDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => ContentDialog(
        title: Text(context.l10n.gitBranchNewTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.gitBranchNew, style: AppTypo.caption(ctx)),
            const SizedBox(height: AppSpacing.xs),
            TextBox(
              controller: controller,
              placeholder: context.l10n.gitBranchNamePlaceholder,
            ),
          ],
        ),
        actions: [
          Button(
            child: Text(context.l10n.commonCancel),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          FilledButton(
            child: Text(
              context.l10n.commonConfirm,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (created == true && controller.text.trim().isNotEmpty) {
      await ref.read(gitControllerProvider.notifier).createBranch(
            sessionId,
            repo.path,
            controller.text.trim(),
            server: server,
          );
    }
  }

  Future<void> _checkoutBranch(WidgetRef ref, String branch) async {
    await ref.read(gitControllerProvider.notifier).checkoutBranch(
          sessionId,
          repo.path,
          branch,
          server: server,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Action Bar
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.spaceBetween,
          children: [
            Text(context.l10n.gitTabBranches, style: AppTypo.titleMedium(context)),
            FilledButton(
              onPressed: () => _openNewBranchDialog(context, ref),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(FluentIcons.add, size: AppIconSize.sm, color: Colors.white),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    context.l10n.gitBranchNew,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        Expanded(
          child: ListView(
            children: [
              // Local branches
              Text(context.l10n.gitLocalBranchesCount(repo.localBranches.length), style: AppTypo.body(context)),
              const SizedBox(height: AppSpacing.sm),
              ...repo.localBranches.map((branch) {
                final isCurrent = branch == repo.currentBranch;

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Card(
                    backgroundColor: isCurrent
                        ? AppColors.accentCyan.withValues(alpha: 0.1)
                        : AppColors.surfaceElevated(context),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    child: Row(
                      children: [
                        Icon(
                          isCurrent ? FluentIcons.check_mark : FluentIcons.branch_fork,
                          size: AppIconSize.sm,
                          color: isCurrent ? AppColors.accentCyan : AppColors.textMuted(context),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            branch,
                            style: AppTypo.body(context).copyWith(
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isCurrent)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accentCyan.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              context.l10n.gitBranchCurrent,
                              style: const TextStyle(color: AppColors.accentCyan, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          )
                        else
                          Button(
                            onPressed: () => _checkoutBranch(ref, branch),
                            child: Text(context.l10n.gitBranchSwitch, style: AppTypo.micro(context)),
                          ),
                      ],
                    ),
                  ),
                );
              }),

              if (repo.remoteBranches.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(context.l10n.gitRemoteBranchesCount(repo.remoteBranches.length), style: AppTypo.body(context)),
                const SizedBox(height: AppSpacing.sm),
                ...repo.remoteBranches.map((rBranch) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Card(
                      backgroundColor: AppColors.surfaceElevated(context),
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      child: Row(
                        children: [
                          Icon(FluentIcons.cloud, size: AppIconSize.sm, color: AppColors.textMuted(context)),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              rBranch,
                              style: AppTypo.code(context).copyWith(fontSize: 12),
                            ),
                          ),
                          Button(
                            onPressed: () => _checkoutBranch(ref, rBranch),
                            child: Text(context.l10n.gitBranchSwitch, style: AppTypo.micro(context)),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
