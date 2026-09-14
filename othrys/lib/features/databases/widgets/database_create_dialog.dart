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

/// Dialog allowing administrators to create a new database on the active engine.
class DatabaseCreateDialog extends ConsumerStatefulWidget {
  final String sessionId;
  final ServerEntity? server;
  final DatabaseEngineType engine;

  const DatabaseCreateDialog({
    super.key,
    required this.sessionId,
    this.server,
    required this.engine,
  });

  @override
  ConsumerState<DatabaseCreateDialog> createState() => _DatabaseCreateDialogState();
}

class _DatabaseCreateDialogState extends ConsumerState<DatabaseCreateDialog> {
  final _nameController = TextEditingController();
  late String _charset;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _charset = widget.engine == DatabaseEngineType.mysql ? 'utf8mb4' : 'UTF8';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = context.l10n.commonFieldRequired);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final result = await ref.read(databasesControllerProvider.notifier).createDatabase(
          widget.sessionId,
          name,
          charset: _charset,
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
    final charsets = widget.engine == DatabaseEngineType.mysql
        ? ['utf8mb4', 'utf8', 'latin1', 'binary']
        : ['UTF8', 'LATIN1', 'SQL_ASCII'];

    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: AppDialogSize.compactWidth),
      title: Row(
        children: [
          const Icon(FluentIcons.database, size: AppIconSize.md, color: AppColors.accentCyan),
          const SizedBox(width: AppSpacing.sm),
          Text(context.l10n.dbCreateTitle, style: AppTypo.titleLarge(context)),
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
            label: '${context.l10n.dbName} *',
            child: TextBox(
              controller: _nameController,
              autofocus: true,
              placeholder: 'my_app_production',
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _submit(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          InfoLabel(
            label: context.l10n.dbCollation,
            child: ComboBox<String>(
              value: _charset,
              items: charsets.map((c) => ComboBoxItem(value: c, child: Text(c))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _charset = val);
              },
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
              : Text(context.l10n.dbCreate),
        ),
      ],
    );
  }
}
