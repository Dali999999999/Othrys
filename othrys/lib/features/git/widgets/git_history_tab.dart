import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_icons.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/l10n/l10n.dart';
import '../git_controller.dart';

/// Tab displaying the visual commit history timeline of the selected Git repository.
class GitHistoryTab extends StatelessWidget {
  final List<GitCommit> commits;

  const GitHistoryTab({
    super.key,
    required this.commits,
  });

  void _copyHash(BuildContext context, String hash) {
    Clipboard.setData(ClipboardData(text: hash));
    displayInfoBar(
      context,
      builder: (ctx, close) => InfoBar(
        title: Text(context.l10n.commonCopy),
        content: Text(context.l10n.gitCommitCopied(hash)),
        severity: InfoBarSeverity.success,
        onClose: close,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (commits.isEmpty) {
      return Center(
        child: Text(
          context.l10n.gitNoCommits,
          style: AppTypo.caption(context),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.gitHistoryCount(commits.length),
          style: AppTypo.titleMedium(context),
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: ListView.separated(
            itemCount: commits.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
            itemBuilder: (context, index) {
              final commit = commits[index];

              return Card(
                backgroundColor: AppColors.surfaceElevated(context),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(FluentIcons.branch_commit, size: AppIconSize.sm, color: AppColors.accentCyan),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            commit.message,
                            style: AppTypo.body(context).copyWith(fontWeight: FontWeight.w600),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            children: [
                              Text(commit.author, style: AppTypo.caption(context)),
                              const SizedBox(width: AppSpacing.sm),
                              Text('•', style: AppTypo.micro(context)),
                              const SizedBox(width: AppSpacing.sm),
                              Text(commit.date, style: AppTypo.caption(context)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Button(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(AppColors.surfaceBase(context)),
                      ),
                      onPressed: () => _copyHash(context, commit.hash),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            commit.hash,
                            style: AppTypo.code(context).copyWith(fontSize: 11, color: AppColors.accentCyan),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          const Icon(FluentIcons.copy, size: AppIconSize.xs),
                        ],
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
