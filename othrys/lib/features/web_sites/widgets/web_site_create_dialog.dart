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
import '../web_sites_controller.dart';

/// Modal dialog for configuring a new Nginx website (reverse proxy or static website).
class WebSiteCreateDialog extends ConsumerStatefulWidget {
  final String sessionId;
  final ServerEntity? server;

  const WebSiteCreateDialog({
    super.key,
    required this.sessionId,
    this.server,
  });

  @override
  ConsumerState<WebSiteCreateDialog> createState() => _WebSiteCreateDialogState();
}

class _WebSiteCreateDialogState extends ConsumerState<WebSiteCreateDialog> {
  final _domainController = TextEditingController();
  final _targetController = TextEditingController();
  final _emailController = TextEditingController();

  WebSiteType _type = WebSiteType.reverseProxy;
  bool _enableSsl = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _domainController.dispose();
    _targetController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final domain = _domainController.text.trim();
    final target = _targetController.text.trim();

    if (domain.isEmpty || target.isEmpty) {
      setState(() => _errorMessage = context.l10n.commonFieldRequired);
      return;
    }

    if (_enableSsl && (_emailController.text.trim().isEmpty || !_emailController.text.contains('@'))) {
      setState(() => _errorMessage = context.l10n.commonFieldRequired);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final site = WebSiteEntity(
      domain: domain,
      type: _type,
      target: target,
      isEnabled: true,
      hasSsl: false,
    );

    final res = await ref.read(webSitesControllerProvider.notifier).createSite(
          widget.sessionId,
          site,
          enableSsl: _enableSsl,
          sslEmail: _enableSsl ? _emailController.text.trim() : null,
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
          const Icon(FluentIcons.globe, size: AppIconSize.md, color: AppColors.accentCyan),
          const SizedBox(width: AppSpacing.sm),
          Text(context.l10n.webSitesCreateTitle, style: AppTypo.titleLarge(context)),
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

            // Domain Name
            InfoLabel(
              label: '${context.l10n.webSitesDomain} *',
              child: TextBox(
                controller: _domainController,
                autofocus: true,
                placeholder: context.l10n.webSitesDomainPlaceholder,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Site Type Selector
            InfoLabel(
              label: context.l10n.webSitesType,
              child: ComboBox<WebSiteType>(
                value: _type,
                items: [
                  ComboBoxItem(
                    value: WebSiteType.reverseProxy,
                    child: Text(context.l10n.webSitesTypeProxy),
                  ),
                  ComboBoxItem(
                    value: WebSiteType.staticSite,
                    child: Text(context.l10n.webSitesTypeStatic),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _type = val;
                      _targetController.clear();
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Target (Port for proxy, Path for static)
            if (_type == WebSiteType.reverseProxy) ...[
              InfoLabel(
                label: '${context.l10n.webSitesTargetPort} *',
                child: TextBox(
                  controller: _targetController,
                  placeholder: context.l10n.webSitesTargetPortPlaceholder,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ] else ...[
              InfoLabel(
                label: '${context.l10n.webSitesStaticRoot} *',
                child: TextBox(
                  controller: _targetController,
                  placeholder: context.l10n.webSitesStaticRootPlaceholder,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),

            // SSL Let's Encrypt Option
            Checkbox(
              checked: _enableSsl,
              content: Text(context.l10n.webSitesEnableSsl),
              onChanged: (val) => setState(() => _enableSsl = val ?? false),
            ),
            if (_enableSsl) ...[
              const SizedBox(height: AppSpacing.sm),
              InfoLabel(
                label: '${context.l10n.webSitesEmail} *',
                child: TextBox(
                  controller: _emailController,
                  placeholder: 'admin@example.com',
                  onChanged: (_) => setState(() {}),
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
              : Text(context.l10n.commonSave),
        ),
      ],
    );
  }
}
