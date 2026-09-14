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

/// Modal dialog allowing the user to clone a new Git repository onto the VPS.
class GitCloneDialog extends ConsumerStatefulWidget {
  final String sessionId;
  final String serverId;
  final ServerEntity? server;
  final String? initialDestination;

  const GitCloneDialog({
    super.key,
    required this.sessionId,
    required this.serverId,
    this.server,
    this.initialDestination,
  });

  @override
  ConsumerState<GitCloneDialog> createState() => _GitCloneDialogState();
}

class _GitCloneDialogState extends ConsumerState<GitCloneDialog> {
  final _urlController = TextEditingController();
  final _destController = TextEditingController();
  final _branchController = TextEditingController();

  bool _shallow = false;
  bool _submodules = false;
  bool _isCloning = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialDestination != null && widget.initialDestination!.isNotEmpty) {
      _destController.text = widget.initialDestination!;
    } else {
      _destController.text = '/var/www/';
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _destController.dispose();
    _branchController.dispose();
    super.dispose();
  }

  void _onUrlChanged(String val) {
    if (_destController.text.endsWith('/') || _destController.text.isEmpty) {
      final clean = val.trim().replaceAll('.git', '');
      final repoName = clean.split(RegExp(r'[/:]')).lastOrNull;
      if (repoName != null && repoName.isNotEmpty) {
        final prefix = _destController.text.endsWith('/') ? _destController.text : '/var/www/';
        _destController.text = '$prefix$repoName';
      }
    }
    setState(() {});
  }

  Future<void> _submit() async {
    final url = _urlController.text.trim();
    final dest = _destController.text.trim();

    if (url.isEmpty || dest.isEmpty) {
      setState(() => _errorMessage = context.l10n.commonFieldRequired);
      return;
    }

    setState(() {
      _isCloning = true;
      _errorMessage = null;
    });

    final res = await ref.read(gitControllerProvider.notifier).cloneRepository(
          widget.sessionId,
          widget.serverId,
          url: url,
          destPath: dest,
          branch: _branchController.text.trim().isEmpty ? null : _branchController.text.trim(),
          shallow: _shallow,
          submodules: _submodules,
          server: widget.server,
        );

    if (!mounted) return;

    if (res is Success) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _isCloning = false;
        _errorMessage = (res as Failure).message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSsh = _urlController.text.trim().startsWith('git@') || _urlController.text.trim().startsWith('ssh://');

    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: AppDialogSize.wideWidth),
      title: Row(
        children: [
          const Icon(FluentIcons.branch_fork, color: AppColors.accentCyan, size: AppIconSize.lg),
          const SizedBox(width: AppSpacing.sm),
          Text(context.l10n.gitCloneTitle, style: AppTypo.titleMedium(context)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
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

            Text(context.l10n.gitCloneUrl, style: AppTypo.caption(context)),
            const SizedBox(height: AppSpacing.xs),
            TextBox(
              controller: _urlController,
              placeholder: context.l10n.gitCloneUrlPlaceholder,
              onChanged: _onUrlChanged,
            ),
            const SizedBox(height: AppSpacing.md),

            if (isSsh) ...[
              InfoBar(
                title: Text(context.l10n.gitDeployKeyTitle),
                content: Text(context.l10n.gitCloneSshNotice),
                severity: InfoBarSeverity.info,
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            Text(context.l10n.gitCloneDest, style: AppTypo.caption(context)),
            const SizedBox(height: AppSpacing.xs),
            TextBox(
              controller: _destController,
              placeholder: context.l10n.gitCloneDestPlaceholder,
            ),
            const SizedBox(height: AppSpacing.xs),

            Wrap(
              spacing: AppSpacing.xs,
              children: [
                Button(
                  onPressed: () => setState(() => _destController.text = '/var/www/'),
                  child: Text('/var/www/', style: AppTypo.micro(context)),
                ),
                Button(
                  onPressed: () => setState(() => _destController.text = '~/projects/'),
                  child: Text('~/projects/', style: AppTypo.micro(context)),
                ),
                Button(
                  onPressed: () => setState(() => _destController.text = '/opt/'),
                  child: Text('/opt/', style: AppTypo.micro(context)),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            Text(context.l10n.gitCloneBranch, style: AppTypo.caption(context)),
            const SizedBox(height: AppSpacing.xs),
            TextBox(
              controller: _branchController,
              placeholder: context.l10n.gitCloneBranchPlaceholder,
            ),
            const SizedBox(height: AppSpacing.md),

            Checkbox(
              checked: _shallow,
              onChanged: (v) => setState(() => _shallow = v ?? false),
              content: Text(context.l10n.gitCloneShallow, style: AppTypo.body(context)),
            ),
            const SizedBox(height: AppSpacing.xs),
            Checkbox(
              checked: _submodules,
              onChanged: (v) => setState(() => _submodules = v ?? false),
              content: Text(context.l10n.gitCloneSubmodules, style: AppTypo.body(context)),
            ),
          ],
        ),
      ),
      actions: [
        Button(
          onPressed: _isCloning ? null : () => Navigator.of(context).pop(false),
          child: Text(context.l10n.commonCancel),
        ),
        FilledButton(
          onPressed: _isCloning ? null : _submit,
          child: _isCloning
              ? const SizedBox(width: 16, height: 16, child: ProgressRing(strokeWidth: 2))
              : Text(
                  context.l10n.gitClone,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
        ),
      ],
    );
  }
}
