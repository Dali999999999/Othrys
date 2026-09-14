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
import '../server_admin_controller.dart';

/// Modal dialog for injecting an authorized public SSH key into a user account.
class SshKeyAddDialog extends ConsumerStatefulWidget {
  final String sessionId;
  final String username;
  final ServerEntity? server;

  const SshKeyAddDialog({
    super.key,
    required this.sessionId,
    required this.username,
    this.server,
  });

  @override
  ConsumerState<SshKeyAddDialog> createState() => _SshKeyAddDialogState();
}

class _SshKeyAddDialogState extends ConsumerState<SshKeyAddDialog> {
  final _keyController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final key = _keyController.text.trim();
    if (key.isEmpty) {
      setState(() => _errorMessage = context.l10n.commonFieldRequired);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final res = await ref.read(serverAdminControllerProvider.notifier).addAuthorizedKey(
          widget.sessionId,
          widget.username,
          key,
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
          const Icon(FluentIcons.permissions, size: AppIconSize.md, color: AppColors.accentCyan),
          const SizedBox(width: AppSpacing.sm),
          Text(context.l10n.adminUsersAddKeyTitle, style: AppTypo.titleLarge(context)),
        ],
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'User: ${widget.username}',
            style: AppTypo.body(context).copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (_errorMessage != null) ...[
            InfoBar(
              title: Text(context.l10n.commonError),
              content: Text(_errorMessage!),
              severity: InfoBarSeverity.error,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          InfoLabel(
            label: '${context.l10n.adminUsersSshKeys} *',
            child: TextBox(
              controller: _keyController,
              autofocus: true,
              maxLines: 4,
              placeholder: context.l10n.adminUsersKeyPlaceholder,
              style: AppTypo.caption(context).copyWith(fontFamily: AppTypo.fontMono),
            ),
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
              : Text(context.l10n.commonSave),
        ),
      ],
    );
  }
}
