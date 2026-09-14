import 'package:fluent_ui/fluent_ui.dart';
import 'package:uuid/uuid.dart';
import '../../core/l10n/l10n.dart';
import '../../core/models/tunnel_entity.dart';
import '../../app/theme/app_dialog_sizes.dart';
import '../../app/theme/app_spacing.dart';

/// Modal dialog for configuring SSH port forwarding tunnels.
class TunnelDialog extends StatefulWidget {
  final TunnelEntity? initialTunnel;
  final String serverId;

  const TunnelDialog({
    super.key,
    this.initialTunnel,
    required this.serverId,
  });

  static Future<TunnelEntity?> show({
    required BuildContext context,
    required String serverId,
    TunnelEntity? initialTunnel,
  }) {
    return showDialog<TunnelEntity>(
      context: context,
      builder: (ctx) => TunnelDialog(
        serverId: serverId,
        initialTunnel: initialTunnel,
      ),
    );
  }

  @override
  State<TunnelDialog> createState() => _TunnelDialogState();
}

class _TunnelDialogState extends State<TunnelDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _localPortController;
  late final TextEditingController _remoteHostController;
  late final TextEditingController _remotePortController;

  TunnelType _tunnelType = TunnelType.local;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    final t = widget.initialTunnel;
    _nameController = TextEditingController(text: t?.name ?? 'Service Tunnel');
    _localPortController = TextEditingController(text: (t?.localPort ?? 8080).toString());
    _remoteHostController = TextEditingController(text: t?.remoteHost ?? '127.0.0.1');
    _remotePortController = TextEditingController(text: (t?.remotePort ?? 80).toString());
    _tunnelType = t?.type ?? TunnelType.local;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _localPortController.dispose();
    _remoteHostController.dispose();
    _remotePortController.dispose();
    super.dispose();
  }

  bool _validate() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _validationError = 'Tunnel name cannot be empty.');
      return false;
    }

    final localPort = int.tryParse(_localPortController.text.trim());
    if (localPort == null || localPort < 1 || localPort > 65535) {
      setState(() => _validationError = 'Local port must be between 1 and 65535.');
      return false;
    }

    final remotePort = int.tryParse(_remotePortController.text.trim());
    if (remotePort == null || remotePort < 1 || remotePort > 65535) {
      setState(() => _validationError = 'Remote port must be between 1 and 65535.');
      return false;
    }

    final remoteHost = _remoteHostController.text.trim();
    if (remoteHost.isEmpty) {
      setState(() => _validationError = 'Destination host address cannot be empty.');
      return false;
    }

    setState(() => _validationError = null);
    return true;
  }

  void _submit() {
    if (!_validate()) return;

    final tunnel = TunnelEntity(
      id: widget.initialTunnel?.id ?? const Uuid().v4(),
      serverId: widget.serverId,
      name: _nameController.text.trim(),
      type: _tunnelType,
      localPort: int.parse(_localPortController.text.trim()),
      remoteHost: _remoteHostController.text.trim(),
      remotePort: int.parse(_remotePortController.text.trim()),
    );

    Navigator.of(context).pop(tunnel);
  }

  String _getTypeLabel(TunnelType type) {
    switch (type) {
      case TunnelType.local:
        return context.l10n.tunnelsTypeLocal;
      case TunnelType.remote:
        return context.l10n.tunnelsTypeRemote;
      case TunnelType.dynamic:
        return context.l10n.tunnelsTypeDynamic;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text(context.l10n.tunnelsDialogTitle),
      content: SizedBox(
        width: AppDialogSize.compactWidth,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_validationError != null) ...[
                InfoBar(
                  title: Text(context.l10n.commonError),
                  content: Text(_validationError!),
                  severity: InfoBarSeverity.error,
                  isLong: true,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              InfoLabel(
                label: context.l10n.tunnelsNameLabel,
                child: TextBox(
                  controller: _nameController,
                  autofocus: true,
                  onChanged: (_) => _validate(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              InfoLabel(
                label: context.l10n.commonStatus,
                child: ComboBox<TunnelType>(
                  value: _tunnelType,
                  isExpanded: true,
                  items: TunnelType.values.map((type) {
                    return ComboBoxItem(
                      value: type,
                      child: Text(_getTypeLabel(type)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _tunnelType = val);
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: InfoLabel(
                      label: context.l10n.tunnelsLocalPortLabel,
                      child: TextBox(
                        controller: _localPortController,
                        placeholder: '8080',
                        onChanged: (_) => _validate(),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: InfoLabel(
                      label: context.l10n.tunnelsRemotePortLabel,
                      child: TextBox(
                        controller: _remotePortController,
                        placeholder: '80',
                        onChanged: (_) => _validate(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              InfoLabel(
                label: context.l10n.tunnelsRemoteHostLabel,
                child: TextBox(
                  controller: _remoteHostController,
                  placeholder: '127.0.0.1',
                  onChanged: (_) => _validate(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Button(
          child: Text(context.l10n.commonCancel),
          onPressed: () => Navigator.of(context).pop(null),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(context.l10n.commonSave),
        ),
      ],
    );
  }
}
