import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_dialog_sizes.dart';
import '../../../app/theme/app_icons.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/models/server_entity.dart';
import '../../../core/utils/result.dart';
import '../services_controller.dart';

/// Modal dialog allowing administrators to define, preview, and deploy a systemd unit file.
class ServiceCreateDialog extends ConsumerStatefulWidget {
  final String sessionId;
  final ServerEntity? server;

  const ServiceCreateDialog({
    super.key,
    required this.sessionId,
    this.server,
  });

  @override
  ConsumerState<ServiceCreateDialog> createState() => _ServiceCreateDialogState();
}

class _ServiceCreateDialogState extends ConsumerState<ServiceCreateDialog> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _execStartController = TextEditingController();
  final _workDirController = TextEditingController();
  final _userController = TextEditingController(text: 'root');
  final _envController = TextEditingController();

  String _restartPolicy = 'always';
  bool _enableAtBoot = true;
  bool _startNow = true;
  bool _isSubmitting = false;
  bool _showPreview = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _execStartController.dispose();
    _workDirController.dispose();
    _userController.dispose();
    _envController.dispose();
    super.dispose();
  }

  ServiceDefinition _buildDefinition() {
    final envMap = <String, String>{};
    for (final line in _envController.text.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || !trimmed.contains('=')) continue;
      final idx = trimmed.indexOf('=');
      final key = trimmed.substring(0, idx).trim();
      final val = trimmed.substring(idx + 1).trim();
      if (key.isNotEmpty) {
        envMap[key] = val;
      }
    }

    return ServiceDefinition(
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      execStart: _execStartController.text.trim(),
      workingDirectory: _workDirController.text.trim(),
      user: _userController.text.trim(),
      restartPolicy: _restartPolicy,
      environment: envMap,
      enableAtBoot: _enableAtBoot,
      startNow: _startNow,
    );
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final execStart = _execStartController.text.trim();

    if (name.isEmpty || execStart.isEmpty) {
      setState(() => _errorMessage = context.l10n.commonFieldRequired);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final definition = _buildDefinition();
    final result = await ref.read(servicesControllerProvider.notifier).createService(
          widget.sessionId,
          definition,
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
    return ContentDialog(
      constraints: const BoxConstraints(maxWidth: AppDialogSize.standardWidth, maxHeight: 680),
      title: Row(
        children: [
          const Icon(FluentIcons.developer_tools, size: AppIconSize.md, color: AppColors.accentCyan),
          const SizedBox(width: AppSpacing.sm),
          Text(context.l10n.servicesCreateTitle, style: AppTypo.titleLarge(context)),
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

            // Service Name
            InfoLabel(
              label: '${context.l10n.servicesNameLabel} *',
              child: TextBox(
                controller: _nameController,
                placeholder: context.l10n.servicesNamePlaceholder,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Description
            InfoLabel(
              label: context.l10n.servicesDescLabel,
              child: TextBox(
                controller: _descController,
                placeholder: context.l10n.servicesDescPlaceholder,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // ExecStart
            InfoLabel(
              label: '${context.l10n.servicesExecStartLabel} *',
              child: TextBox(
                controller: _execStartController,
                placeholder: context.l10n.servicesExecStartPlaceholder,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Working Directory & User
            Row(
              children: [
                Expanded(
                  child: InfoLabel(
                    label: context.l10n.servicesWorkDirLabel,
                    child: TextBox(
                      controller: _workDirController,
                      placeholder: context.l10n.servicesWorkDirPlaceholder,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: InfoLabel(
                    label: context.l10n.servicesUserLabel,
                    child: TextBox(
                      controller: _userController,
                      placeholder: 'root',
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Restart Policy
            InfoLabel(
              label: context.l10n.servicesRestartPolicy,
              child: ComboBox<String>(
                value: _restartPolicy,
                items: const [
                  ComboBoxItem(value: 'always', child: Text('always')),
                  ComboBoxItem(value: 'on-failure', child: Text('on-failure')),
                  ComboBoxItem(value: 'unless-stopped', child: Text('unless-stopped')),
                  ComboBoxItem(value: 'no', child: Text('no')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _restartPolicy = val);
                },
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Environment Variables
            InfoLabel(
              label: context.l10n.servicesEnvLabel,
              child: TextBox(
                controller: _envController,
                placeholder: 'PORT=3000\nNODE_ENV=production',
                maxLines: 3,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Options: Enable at boot & Start now
            Row(
              children: [
                Checkbox(
                  checked: _enableAtBoot,
                  content: Text(context.l10n.servicesEnableBoot),
                  onChanged: (v) => setState(() => _enableAtBoot = v ?? true),
                ),
                const SizedBox(width: AppSpacing.lg),
                Checkbox(
                  checked: _startNow,
                  content: Text(context.l10n.servicesStartNow),
                  onChanged: (v) => setState(() => _startNow = v ?? true),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Toggle Unit File Preview
            HyperlinkButton(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_showPreview ? FluentIcons.chevron_up : FluentIcons.chevron_down, size: AppIconSize.xs),
                  const SizedBox(width: AppSpacing.xs),
                  Text(context.l10n.servicesPreview),
                ],
              ),
              onPressed: () => setState(() => _showPreview = !_showPreview),
            ),

            if (_showPreview) ...[
              const SizedBox(height: AppSpacing.xs),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.consoleBackground,
                  borderRadius: AppRadius.borderSm,
                  border: Border.all(color: AppColors.surfaceBorder(context)),
                ),
                child: SelectableText(
                  _buildDefinition().generateUnitContent(),
                  style: AppTypo.caption(context).copyWith(
                    fontFamily: AppTypo.fontMono,
                    color: AppColors.consoleText,
                  ),
                ),
              ),
            ],
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
              : Text(context.l10n.servicesCreate),
        ),
      ],
    );
  }
}
