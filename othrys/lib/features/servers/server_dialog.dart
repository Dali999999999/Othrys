import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:uuid/uuid.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dialog_sizes.dart';
import '../../app/theme/app_icons.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/l10n/l10n.dart';
import '../../core/models/server_entity.dart';
import '../../core/network/ssh_session_manager.dart';
import '../../core/utils/logger.dart';
import 'widgets/server_auth_fields.dart';
import 'widgets/server_test_connection_card.dart';

/// Modal dialog for adding or editing a VPS server profile with validation and connection testing.
class ServerDialog extends StatefulWidget {
  final ServerEntity? initialServer;
  final List<ServerEntity> existingServers;

  const ServerDialog({
    super.key,
    this.initialServer,
    this.existingServers = const [],
  });

  @override
  State<ServerDialog> createState() => _ServerDialogState();
}

class _ServerDialogState extends State<ServerDialog> {
  late TextEditingController _nameController;
  late TextEditingController _hostController;
  late TextEditingController _portController;
  late TextEditingController _userController;
  late TextEditingController _passwordController;
  late TextEditingController _privateKeyController;
  late TextEditingController _passphraseController;
  late TextEditingController _groupController;

  SSHAuthType _authType = SSHAuthType.password;
  String? _selectedBastionId;
  bool _obscurePassword = true;

  bool _isTestingConnection = false;
  String? _testResult;
  bool _testSuccess = false;

  @override
  void initState() {
    super.initState();
    final server = widget.initialServer;

    _nameController = TextEditingController(text: server?.name ?? '');
    _hostController = TextEditingController(text: server?.host ?? '');
    _portController = TextEditingController(text: (server?.port ?? 22).toString());
    _userController = TextEditingController(text: server?.username ?? 'root');
    _passwordController = TextEditingController(text: server?.password ?? '');
    _privateKeyController = TextEditingController(text: server?.privateKey ?? '');
    _passphraseController = TextEditingController(text: server?.passphrase ?? '');
    _groupController = TextEditingController(text: server?.group ?? '');

    _authType = server?.authType ?? SSHAuthType.password;
    _selectedBastionId = server?.bastionId;

    _nameController.addListener(_onFieldChanged);
    _hostController.addListener(_onFieldChanged);
    _portController.addListener(_onFieldChanged);
    _userController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nameController.removeListener(_onFieldChanged);
    _hostController.removeListener(_onFieldChanged);
    _portController.removeListener(_onFieldChanged);
    _userController.removeListener(_onFieldChanged);

    _nameController.dispose();
    _hostController.dispose();
    _portController.dispose();
    _userController.dispose();
    _passwordController.dispose();
    _privateKeyController.dispose();
    _passphraseController.dispose();
    _groupController.dispose();
    super.dispose();
  }

  bool _isValidHost(String host) {
    final trimmed = host.trim();
    if (trimmed.isEmpty) return false;
    final ipv4 = RegExp(r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$');
    if (ipv4.hasMatch(trimmed)) return true;
    if (trimmed.contains(':') && !trimmed.contains(' ')) return true;
    final hostname = RegExp(r'^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)*[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?$');
    return hostname.hasMatch(trimmed);
  }

  bool _isValidPort(String port) {
    final p = int.tryParse(port.trim());
    return p != null && p >= 1 && p <= 65535;
  }

  bool get _isFormValid {
    final nameValid = _nameController.text.trim().isNotEmpty;
    final hostValid = _isValidHost(_hostController.text);
    final portValid = _isValidPort(_portController.text);
    final userValid = _userController.text.trim().isNotEmpty;
    return nameValid && hostValid && portValid && userValid;
  }

  Future<void> _pickKeyFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Select SSH Private Key',
        type: FileType.any,
      );
      if (result != null && result.files.isNotEmpty && result.files.first.path != null) {
        final file = File(result.files.first.path!);
        final content = await file.readAsString();
        if (!mounted) return;
        setState(() {
          _privateKeyController.text = content.trim();
        });
      }
    } catch (e, st) {
      AppLogger.instance.error('ServerDialog', 'Failed to read private key file: $e', e, st);
      if (mounted) {
        displayInfoBar(context, builder: (ctx, close) {
          return InfoBar(
            title: Text(context.l10n.commonError),
            content: Text(e.toString()),
            severity: InfoBarSeverity.error,
            onClose: close,
          );
        });
      }
    }
  }

  Future<void> _testConnection() async {
    if (!_isFormValid) return;
    setState(() {
      _isTestingConnection = true;
      _testResult = null;
      _testSuccess = false;
    });

    final tempServer = ServerEntity(
      id: widget.initialServer?.id ?? 'test-${const Uuid().v4()}',
      name: _nameController.text.trim(),
      host: _hostController.text.trim(),
      port: int.tryParse(_portController.text.trim()) ?? 22,
      username: _userController.text.trim(),
      authType: _authType,
      password: _authType == SSHAuthType.password ? _passwordController.text : null,
      privateKey: _authType == SSHAuthType.privateKey ? _privateKeyController.text : null,
      passphrase: _authType == SSHAuthType.privateKey && _passphraseController.text.isNotEmpty
          ? _passphraseController.text
          : null,
      bastionId: _selectedBastionId,
    );

    try {
      final info = await SSHSessionManager.instance.testConnection(tempServer);
      if (!mounted) return;
      setState(() {
        _testSuccess = true;
        _testResult = '${context.l10n.serversTestSuccess} ($info)';
      });
    } catch (e, st) {
      AppLogger.instance.error('ServerDialog', 'Test connection failed: $e', e, st);
      if (!mounted) return;
      setState(() {
        _testSuccess = false;
        _testResult = context.l10n.serversTestFailed(e.toString());
      });
    } finally {
      if (mounted) {
        setState(() => _isTestingConnection = false);
      }
    }
  }

  void _submit() {
    if (!_isFormValid) return;

    final server = ServerEntity(
      id: widget.initialServer?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      host: _hostController.text.trim(),
      port: int.tryParse(_portController.text.trim()) ?? 22,
      username: _userController.text.trim(),
      authType: _authType,
      password: _authType == SSHAuthType.password ? _passwordController.text : null,
      privateKey: _authType == SSHAuthType.privateKey ? _privateKeyController.text : null,
      passphrase: _authType == SSHAuthType.privateKey && _passphraseController.text.isNotEmpty
          ? _passphraseController.text
          : null,
      group: _groupController.text.trim().isNotEmpty ? _groupController.text.trim() : null,
      bastionId: _selectedBastionId,
      pinnedServices: widget.initialServer?.pinnedServices ?? const [],
      lastConnected: widget.initialServer?.lastConnected,
      osName: widget.initialServer?.osName,
    );

    Navigator.of(context).pop(server);
  }

  @override
  Widget build(BuildContext context) {
    final bastions = widget.existingServers.where((s) => s.id != widget.initialServer?.id).toList();
    final hostHasError = _hostController.text.isNotEmpty && !_isValidHost(_hostController.text);
    final portHasError = _portController.text.isNotEmpty && !_isValidPort(_portController.text);

    return ContentDialog(
      title: Text(widget.initialServer == null ? context.l10n.serversAddTitle : context.l10n.serversEditTitle),
      content: SizedBox(
        width: AppDialogSize.standardWidth,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Basic Information
              InfoLabel(
                label: '${context.l10n.serversFieldName} *',
                child: TextBox(
                  controller: _nameController,
                  placeholder: context.l10n.serversFieldNamePlaceholder,
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: AppSpacing.sm),
                    child: Icon(FluentIcons.server, size: AppIconSize.md, color: AppColors.brandBlue),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InfoLabel(
                          label: '${context.l10n.serversFieldHost} *',
                          child: TextBox(
                            controller: _hostController,
                            placeholder: context.l10n.serversFieldHostPlaceholder,
                          ),
                        ),
                        if (hostHasError) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Enter a valid IP or hostname',
                            style: AppTypo.micro(context).copyWith(color: AppColors.danger),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InfoLabel(
                          label: '${context.l10n.serversFieldPort} *',
                          child: TextBox(
                            controller: _portController,
                            placeholder: '22',
                          ),
                        ),
                        if (portHasError) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            '1-65535',
                            style: AppTypo.micro(context).copyWith(color: AppColors.danger),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              Row(
                children: [
                  Expanded(
                    child: InfoLabel(
                      label: '${context.l10n.serversFieldUsername} *',
                      child: TextBox(
                        controller: _userController,
                        placeholder: 'root',
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: InfoLabel(
                      label: context.l10n.serversFieldGroup,
                      child: TextBox(
                        controller: _groupController,
                        placeholder: context.l10n.serversFieldGroupPlaceholder,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              ServerAuthFields(
                authType: _authType,
                onAuthTypeChanged: (val) => setState(() => _authType = val),
                passwordController: _passwordController,
                obscurePassword: _obscurePassword,
                onToggleObscurePassword: () => setState(() => _obscurePassword = !_obscurePassword),
                privateKeyController: _privateKeyController,
                passphraseController: _passphraseController,
                onPickKeyFile: _pickKeyFile,
              ),

              const SizedBox(height: AppSpacing.lg),

              // Bastion Jump Host (Optional)
              if (bastions.isNotEmpty) ...[
                InfoLabel(
                  label: context.l10n.serversFieldBastion,
                  child: ComboBox<String?>(
                    value: _selectedBastionId,
                    isExpanded: true,
                    items: [
                      ComboBoxItem(value: null, child: Text(context.l10n.serversBastionDirect)),
                      ...bastions.map((b) => ComboBoxItem(value: b.id, child: Text('${b.name} (${b.host})'))),
                    ],
                    onChanged: (val) => setState(() => _selectedBastionId = val),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              ServerTestConnectionCard(
                isTesting: _isTestingConnection,
                isFormValid: _isFormValid,
                onTest: _testConnection,
                testResult: _testResult,
                testSuccess: _testSuccess,
              ),
            ],
          ),
        ),
      ),
      actions: [
        Button(
          child: Text(context.l10n.commonCancel),
          onPressed: () => Navigator.of(context).pop(),
        ),
        FilledButton(
          onPressed: _isFormValid ? _submit : null,
          child: Text(widget.initialServer == null ? context.l10n.serversAddSubmit : context.l10n.serversEditSubmit),
        ),
      ],
    );
  }
}
