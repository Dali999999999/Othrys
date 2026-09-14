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

/// Modal dialog for requesting a Let's Encrypt SSL certificate via Certbot.
class SslProvisionDialog extends ConsumerStatefulWidget {
  final String sessionId;
  final String domain;
  final ServerEntity? server;

  const SslProvisionDialog({
    super.key,
    required this.sessionId,
    required this.domain,
    this.server,
  });

  @override
  ConsumerState<SslProvisionDialog> createState() => _SslProvisionDialogState();
}

class _SslProvisionDialogState extends ConsumerState<SslProvisionDialog> {
  final _emailController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = context.l10n.commonFieldRequired);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final res = await ref.read(webSitesControllerProvider.notifier).provisionSsl(
          widget.sessionId,
          widget.domain,
          email,
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
          const Icon(FluentIcons.lock, size: AppIconSize.md, color: AppColors.accentCyan),
          const SizedBox(width: AppSpacing.sm),
          Text(context.l10n.webSitesProvisionSsl, style: AppTypo.titleLarge(context)),
        ],
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Domain: ${widget.domain}',
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
            label: '${context.l10n.webSitesEmail} *',
            child: TextBox(
              controller: _emailController,
              autofocus: true,
              placeholder: 'admin@${widget.domain}',
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _submit(),
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
              : Text(context.l10n.webSitesProvisionSsl),
        ),
      ],
    );
  }
}
