import 'package:fluent_ui/fluent_ui.dart';
import '../../core/l10n/l10n.dart';

/// Standard reusable inline error banner with an optional retry action.
class ErrorBanner extends StatelessWidget {
  final String? title;
  final String message;
  final VoidCallback? onRetry;

  const ErrorBanner({
    super.key,
    this.title,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return InfoBar(
      title: Text(title ?? context.l10n.commonError),
      content: Text(message),
      severity: InfoBarSeverity.error,
      action: onRetry != null
          ? Button(
              onPressed: onRetry,
              child: Text(context.l10n.commonRetry),
            )
          : null,
    );
  }
}
