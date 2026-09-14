import 'package:fluent_ui/fluent_ui.dart';
import '../../../app/theme/app_icons.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/l10n/l10n.dart';

/// Interactive section triggering an ephemeral test connection and displaying results.
class ServerTestConnectionCard extends StatelessWidget {
  final bool isTesting;
  final bool isFormValid;
  final VoidCallback onTest;
  final String? testResult;
  final bool testSuccess;

  const ServerTestConnectionCard({
    super.key,
    required this.isTesting,
    required this.isFormValid,
    required this.onTest,
    required this.testResult,
    required this.testSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Button(
              onPressed: isTesting || !isFormValid ? null : onTest,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isTesting) ...[
                    const SizedBox(
                      width: AppIconSize.md,
                      height: AppIconSize.md,
                      child: ProgressRing(),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(context.l10n.serversTesting),
                  ] else ...[
                    const Icon(FluentIcons.plug_connected, size: AppIconSize.md),
                    const SizedBox(width: AppSpacing.sm),
                    Text(context.l10n.serversTestConnection),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (testResult != null) ...[
          const SizedBox(height: AppSpacing.sm),
          InfoBar(
            title: Text(testSuccess ? context.l10n.commonSuccess : context.l10n.commonError),
            content: Text(testResult!),
            severity: testSuccess ? InfoBarSeverity.success : InfoBarSeverity.error,
            isLong: true,
          ),
        ],
      ],
    );
  }
}

