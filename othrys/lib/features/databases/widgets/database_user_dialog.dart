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
import '../database_controller.dart';

/// Dialog allowing administrators to create a new database user account.
class DatabaseUserDialog extends ConsumerStatefulWidget {
  final String sessionId;
  final ServerEntity? server;
  final DatabaseEngineType engine;
  final List<String> availableDatabases;

  const DatabaseUserDialog({
    super.key,
    required this.sessionId,
    this.server,
    required this.engine,
    required this.availableDatabases,
  });

  @override
  ConsumerState<DatabaseUserDialog> createState() => _DatabaseUserDialogState();
}

class _DatabaseUserDialogState extends ConsumerState<DatabaseUserDialog> {
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  final _hostController = TextEditingController(text: '%');
  String? _selectedDb;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _userController.dispose();
    _passwordController.dispose();
    _hostController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final user = _userController.text.trim();
    final password = _passwordController.text;

    if (user.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = context.l10n.commonFieldRequired);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final result = await ref.read(databasesControllerProvider.notifier).createUser(
          widget.sessionId,
          user,
          password,
          host: _hostController.text.trim(),
          grantDatabase: _selectedDb,
          server: widget.server,
        );

    if (!mounted) return;

    if (result is Success) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _isSubmitting = false;
        _errorMessage = (result as Failure).message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMysql = widget.engine == DatabaseEngineType.mysql;

    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: AppDialogSize.compactWidth),
      title: Row(
        children: [
          const Icon(FluentIcons.permissions, size: AppIconSize.md, color: AppColors.accentCyan),
          const SizedBox(width: AppSpacing.sm),
          Text(context.l10n.dbUserCreateTitle, style: AppTypo.titleLarge(context)),
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
          InfoLabel(
            label: '${context.l10n.dbUsername} *',
            child: TextBox(
              controller: _userController,
              autofocus: true,
              placeholder: 'app_user',
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          InfoLabel(
            label: '${context.l10n.dbPassword} *',
            child: PasswordBox(
              controller: _passwordController,
              revealMode: PasswordRevealMode.peek,
              onChanged: (_) => setState(() {}),
            ),
          ),
          if (isMysql) ...[
            const SizedBox(height: AppSpacing.sm),
            InfoLabel(
              label: context.l10n.dbHost,
              child: TextBox(
                controller: _hostController,
                placeholder: '% (any host) or localhost',
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
          if (widget.availableDatabases.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            InfoLabel(
              label: '${context.l10n.dbPrivileges} (Grant all on database)',
              child: ComboBox<String?>(
                value: _selectedDb,
                items: [
                  const ComboBoxItem(value: null, child: Text('None / Specific later')),
                  ...widget.availableDatabases.map((db) => ComboBoxItem(value: db, child: Text(db))),
                ],
                onChanged: (val) => setState(() => _selectedDb = val),
              ),
            ),
          ],
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
              : Text(context.l10n.dbUserCreate),
        ),
      ],
    );
  }
}
