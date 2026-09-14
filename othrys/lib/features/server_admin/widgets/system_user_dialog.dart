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

/// Modal dialog for provisioning a new Linux user account.
class SystemUserDialog extends ConsumerStatefulWidget {
  final String sessionId;
  final ServerEntity? server;

  const SystemUserDialog({
    super.key,
    required this.sessionId,
    this.server,
  });

  @override
  ConsumerState<SystemUserDialog> createState() => _SystemUserDialogState();
}

class _SystemUserDialogState extends ConsumerState<SystemUserDialog> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  String _shell = '/bin/bash';
  bool _grantSudo = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = context.l10n.commonFieldRequired);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final res = await ref.read(serverAdminControllerProvider.notifier).createSystemUser(
          widget.sessionId,
          username,
          password,
          grantSudo: _grantSudo,
          shell: _shell,
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
      constraints: const BoxConstraints(maxWidth: AppDialogSize.compactWidth),
      title: Row(
        children: [
          const Icon(FluentIcons.add_friend, size: AppIconSize.md, color: AppColors.accentCyan),
          const SizedBox(width: AppSpacing.sm),
          Text(context.l10n.adminUsersAddTitle, style: AppTypo.titleLarge(context)),
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

            // Username
            InfoLabel(
              label: '${context.l10n.adminUsersUsername} *',
              child: TextBox(
                controller: _usernameController,
                autofocus: true,
                placeholder: context.l10n.adminUsersUsernamePlaceholder,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Password
            InfoLabel(
              label: '${context.l10n.adminUsersPassword} *',
              child: PasswordBox(
                controller: _passwordController,
                placeholder: context.l10n.adminUsersPasswordPlaceholder,
                revealMode: PasswordRevealMode.peek,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Shell
            InfoLabel(
              label: context.l10n.adminUsersShell,
              child: ComboBox<String>(
                value: _shell,
                isExpanded: true,
                items: const [
                  ComboBoxItem(value: '/bin/bash', child: Text('/bin/bash')),
                  ComboBoxItem(value: '/bin/zsh', child: Text('/bin/zsh')),
                  ComboBoxItem(value: '/bin/sh', child: Text('/bin/sh')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _shell = val);
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Grant Sudo
            Checkbox(
              checked: _grantSudo,
              onChanged: (val) => setState(() => _grantSudo = val ?? false),
              content: Text(context.l10n.adminUsersGrantSudo),
            ),
          ],
        ),
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
