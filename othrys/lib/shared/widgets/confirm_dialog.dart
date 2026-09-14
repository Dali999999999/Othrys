import 'package:fluent_ui/fluent_ui.dart';
import '../../core/l10n/l10n.dart';
import '../../app/theme/app_colors.dart';

/// Reusable confirmation modal dialog for destructive or critical actions.
class ConfirmDialog {
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
    bool isDanger = true,
  }) async {
    final effectiveConfirmText = confirmText ?? context.l10n.commonConfirm;
    final effectiveCancelText = cancelText ?? context.l10n.commonCancel;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => ContentDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          Button(
            child: Text(effectiveCancelText),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          FilledButton(
            style: isDanger
                ? ButtonStyle(backgroundColor: WidgetStateProperty.all(AppColors.danger))
                : null,
            child: Text(
              effectiveConfirmText,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
