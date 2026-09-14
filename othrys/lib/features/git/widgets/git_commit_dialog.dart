import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dialog_sizes.dart';
import '../../../app/theme/app_icons.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/models/server_entity.dart';
import '../../../core/utils/result.dart';
import '../git_controller.dart';

/// Modal dialog for committing all modified/untracked files and optionally pushing them.
class GitCommitDialog extends ConsumerStatefulWidget {
  final String sessionId;
  final String repoPath;
  final ServerEntity? server;

  const GitCommitDialog({
    super.key,
    required this.sessionId,
    required this.repoPath,
    this.server,
  });

  @override
  ConsumerState<GitCommitDialog> createState() => _GitCommitDialogState();
}

class _GitCommitDialogState extends ConsumerState<GitCommitDialog> {
  final _messageController = TextEditingController();
  bool _push = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final msg = _messageController.text.trim();
    if (msg.isEmpty) {
      setState(() => _errorMessage = context.l10n.commonFieldRequired);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final res = await ref.read(gitControllerProvider.notifier).commitAndPush(
          widget.sessionId,
          widget.repoPath,
          msg,
          _push,
          server: widget.server,
        );

    if (!mounted) return;

    if (res is Success) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _isSubmitting = false;
        _errorMessage = (res as Failure).message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: AppDialogSize.standardWidth),
      title: Row(
        children: [
          const Icon(FluentIcons.branch_commit, color: AppColors.accentCyan, size: AppIconSize.lg),
          const SizedBox(width: AppSpacing.sm),
          Text(context.l10n.gitCommitTitle, style: AppTypo.titleMedium(context)),
        ],
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_errorMessage != null) ...[
            InfoBar(
              title: Text(context.l10n.commonError),
              content: Text(_errorMessage!),
              severity: InfoBarSeverity.error,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          Text(context.l10n.gitCommitMessage, style: AppTypo.caption(context)),
          const SizedBox(height: AppSpacing.xs),
          TextBox(
            controller: _messageController,
            maxLines: 4,
            placeholder: context.l10n.gitCommitMessagePlaceholder,
          ),
          const SizedBox(height: AppSpacing.md),
          Checkbox(
            checked: _push,
            onChanged: (v) => setState(() => _push = v ?? true),
            content: Text(context.l10n.gitPushAlso, style: AppTypo.body(context)),
          ),
        ],
      ),
      actions: [
        Button(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
          child: Text(context.l10n.commonCancel),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(width: 16, height: 16, child: ProgressRing(strokeWidth: 2))
              : Text(
                  context.l10n.gitCommit,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
        ),
      ],
    );
  }
}
