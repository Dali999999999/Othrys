import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_icons.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/models/server_entity.dart';
import '../../../core/utils/result.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../git_controller.dart';

/// Tab for managing SSH deploy keys (GitHub/GitLab) and global Git committer identity.
class GitDeployKeyTab extends ConsumerStatefulWidget {
  final String sessionId;
  final ServerEntity? server;
  final GitDeployKey deployKey;
  final GitConfig gitConfig;

  const GitDeployKeyTab({
    super.key,
    required this.sessionId,
    this.server,
    required this.deployKey,
    required this.gitConfig,
  });

  @override
  ConsumerState<GitDeployKeyTab> createState() => _GitDeployKeyTabState();
}

class _GitDeployKeyTabState extends ConsumerState<GitDeployKeyTab> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  bool _isGenerating = false;
  bool _isSavingConfig = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.gitConfig.userName ?? '');
    _emailController = TextEditingController(text: widget.gitConfig.userEmail ?? '');
  }

  @override
  void didUpdateWidget(covariant GitDeployKeyTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gitConfig != widget.gitConfig) {
      if (_nameController.text.isEmpty && widget.gitConfig.userName != null) {
        _nameController.text = widget.gitConfig.userName!;
      }
      if (_emailController.text.isEmpty && widget.gitConfig.userEmail != null) {
        _emailController.text = widget.gitConfig.userEmail!;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _copyKey() {
    if (widget.deployKey.publicKey != null) {
      Clipboard.setData(ClipboardData(text: widget.deployKey.publicKey!));
      displayInfoBar(
        context,
        builder: (ctx, close) => InfoBar(
          title: Text(context.l10n.gitDeployKeyCopied),
          severity: InfoBarSeverity.success,
          onClose: close,
        ),
      );
    }
  }

  Future<void> _generateKey() async {
    if (widget.deployKey.exists) {
      final confirmed = await ConfirmDialog.show(
        context: context,
        title: context.l10n.gitDeployKeyOverwriteTitle,
        content: context.l10n.gitDeployKeyOverwriteConfirm,
        confirmText: context.l10n.gitDeployKeyGenerate,
        isDanger: true,
      );
      if (!confirmed) return;
    }

    setState(() => _isGenerating = true);
    final res = await ref.read(gitControllerProvider.notifier).generateDeployKey(widget.sessionId, server: widget.server);
    if (!mounted) return;
    setState(() => _isGenerating = false);

    if (res is Failure) {
      displayInfoBar(
        context,
        builder: (ctx, close) => InfoBar(
          title: Text(context.l10n.commonError),
          content: Text((res as Failure).message),
          severity: InfoBarSeverity.error,
          onClose: close,
        ),
      );
    }
  }

  Future<void> _saveConfig() async {
    setState(() => _isSavingConfig = true);
    final res = await ref.read(gitControllerProvider.notifier).saveGitConfig(
          widget.sessionId,
          _nameController.text.trim(),
          _emailController.text.trim(),
        );
    if (!mounted) return;
    setState(() => _isSavingConfig = false);

    if (res is Success) {
      displayInfoBar(
        context,
        builder: (ctx, close) => InfoBar(
          title: Text(context.l10n.gitConfigSavedTitle),
          content: Text(context.l10n.gitConfigSavedDesc),
          severity: InfoBarSeverity.success,
          onClose: close,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // Deploy Key Section
        Card(
          backgroundColor: AppColors.surfaceElevated(context),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(FluentIcons.shield, color: AppColors.accentCyan, size: AppIconSize.lg),
                  const SizedBox(width: AppSpacing.sm),
                  Text(context.l10n.gitDeployKeyTitle, style: AppTypo.titleMedium(context)),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(context.l10n.gitDeployKeyDesc, style: AppTypo.caption(context)),
              const SizedBox(height: AppSpacing.md),

              if (widget.deployKey.exists && widget.deployKey.publicKey != null) ...[
                TextBox(
                  controller: TextEditingController(text: widget.deployKey.publicKey),
                  readOnly: true,
                  maxLines: 3,
                  style: AppTypo.code(context).copyWith(fontSize: 11),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    FilledButton(
                      onPressed: _copyKey,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(FluentIcons.copy, size: AppIconSize.sm, color: Colors.white),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            context.l10n.gitDeployKeyCopy,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Button(
                      onPressed: _isGenerating ? null : _generateKey,
                      child: _isGenerating
                          ? const SizedBox(width: 14, height: 14, child: ProgressRing(strokeWidth: 2))
                          : Text(context.l10n.gitDeployKeyGenerate),
                    ),
                  ],
                ),
              ] else ...[
                InfoBar(
                  title: Text(context.l10n.gitDeployKeyNone),
                  severity: InfoBarSeverity.warning,
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton(
                  onPressed: _isGenerating ? null : _generateKey,
                  child: _isGenerating
                      ? const SizedBox(width: 16, height: 16, child: ProgressRing(strokeWidth: 2))
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(FluentIcons.lock, size: AppIconSize.sm, color: Colors.white),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              context.l10n.gitDeployKeyGenerate,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Git Identity Section
        Card(
          backgroundColor: AppColors.surfaceElevated(context),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(FluentIcons.contact, color: AppColors.accentPurple, size: AppIconSize.lg),
                  const SizedBox(width: AppSpacing.sm),
                  Text(context.l10n.gitConfigTitle, style: AppTypo.titleMedium(context)),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              Text(context.l10n.gitConfigName, style: AppTypo.caption(context)),
              const SizedBox(height: AppSpacing.xs),
              TextBox(
                controller: _nameController,
                placeholder: 'e.g. Deploy Bot',
              ),
              const SizedBox(height: AppSpacing.md),

              Text(context.l10n.gitConfigEmail, style: AppTypo.caption(context)),
              const SizedBox(height: AppSpacing.xs),
              TextBox(
                controller: _emailController,
                placeholder: 'e.g. bot@example.com',
              ),
              const SizedBox(height: AppSpacing.md),

              FilledButton(
                onPressed: _isSavingConfig ? null : _saveConfig,
                child: _isSavingConfig
                    ? const SizedBox(width: 14, height: 14, child: ProgressRing(strokeWidth: 2))
                    : Text(
                        context.l10n.gitConfigSave,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
