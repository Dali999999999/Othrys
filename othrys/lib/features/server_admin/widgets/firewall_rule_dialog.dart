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

/// Modal dialog for adding a new UFW firewall rule with quick presets.
class FirewallRuleDialog extends ConsumerStatefulWidget {
  final String sessionId;
  final ServerEntity? server;
  final String? initialPort;

  const FirewallRuleDialog({
    super.key,
    required this.sessionId,
    this.server,
    this.initialPort,
  });

  @override
  ConsumerState<FirewallRuleDialog> createState() => _FirewallRuleDialogState();
}

class _FirewallRuleDialogState extends ConsumerState<FirewallRuleDialog> {
  late final TextEditingController _portController;
  final _sourceController = TextEditingController();

  String _proto = 'tcp';
  String _action = 'allow';
  bool _isSubmitting = false;
  String? _errorMessage;

  static const List<Map<String, String>> _presets = [
    {'name': 'SSH', 'port': '22', 'proto': 'tcp'},
    {'name': 'HTTP', 'port': '80', 'proto': 'tcp'},
    {'name': 'HTTPS', 'port': '443', 'proto': 'tcp'},
    {'name': 'MySQL', 'port': '3306', 'proto': 'tcp'},
    {'name': 'PostgreSQL', 'port': '5432', 'proto': 'tcp'},
    {'name': 'Redis', 'port': '6379', 'proto': 'tcp'},
    {'name': 'DNS', 'port': '53', 'proto': 'udp'},
  ];

  @override
  void initState() {
    super.initState();
    _portController = TextEditingController(text: widget.initialPort ?? '');
  }

  @override
  void dispose() {
    _portController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  void _applyPreset(Map<String, String> preset) {
    setState(() {
      _portController.text = preset['port']!;
      _proto = preset['proto']!;
    });
  }

  Future<void> _submit() async {
    final port = _portController.text.trim();
    if (port.isEmpty) {
      setState(() => _errorMessage = context.l10n.commonFieldRequired);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final res = await ref.read(serverAdminControllerProvider.notifier).addFirewallRule(
          widget.sessionId,
          port: port,
          proto: _proto,
          action: _action,
          sourceIp: _sourceController.text.trim().isEmpty ? null : _sourceController.text.trim(),
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
          const Icon(FluentIcons.shield, size: AppIconSize.md, color: AppColors.accentCyan),
          const SizedBox(width: AppSpacing.sm),
          Text(context.l10n.adminFirewallAddRuleTitle, style: AppTypo.titleLarge(context)),
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

            // Quick Presets
            Text(context.l10n.adminFirewallPreset, style: AppTypo.caption(context).copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: _presets.map((p) {
                final isSelected = _portController.text == p['port'] && _proto == p['proto'];
                return Button(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      isSelected ? AppColors.accentCyan.withValues(alpha: 0.2) : AppColors.surfaceElevated(context),
                    ),
                  ),
                  onPressed: () => _applyPreset(p),
                  child: Text('${p['name']} (${p['port']})', style: AppTypo.micro(context)),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),

            // Port or Service
            InfoLabel(
              label: '${context.l10n.adminFirewallRulePort} *',
              child: TextBox(
                controller: _portController,
                placeholder: context.l10n.adminFirewallRulePortPlaceholder,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Protocol and Action row
            Row(
              children: [
                Expanded(
                  child: InfoLabel(
                    label: context.l10n.adminFirewallRuleProto,
                    child: ComboBox<String>(
                      value: _proto,
                      isExpanded: true,
                      items: const [
                        ComboBoxItem(value: 'tcp', child: Text('TCP')),
                        ComboBoxItem(value: 'udp', child: Text('UDP')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _proto = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: InfoLabel(
                    label: context.l10n.adminFirewallRuleAction,
                    child: ComboBox<String>(
                      value: _action,
                      isExpanded: true,
                      items: const [
                        ComboBoxItem(value: 'allow', child: Text('ALLOW (Autoriser)')),
                        ComboBoxItem(value: 'deny', child: Text('DENY (Bloquer)')),
                        ComboBoxItem(value: 'limit', child: Text('LIMIT (Anti-bruteforce)')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _action = val);
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Optional Source IP
            InfoLabel(
              label: context.l10n.adminFirewallRuleSource,
              child: TextBox(
                controller: _sourceController,
                placeholder: context.l10n.adminFirewallRuleSourcePlaceholder,
              ),
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
