import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:xterm/xterm.dart' as xterm;
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_icons.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../core/l10n/l10n.dart';

/// Context menu helper displaying native Fluent UI actions for terminal tabs.
class TerminalContextMenu {
  const TerminalContextMenu._();

  /// Displays the right-click context menu flyout at [position].
  static void show({
    required BuildContext context,
    required FlyoutController flyoutController,
    required Offset position,
    required xterm.Terminal terminal,
    required xterm.TerminalController controller,
    required VoidCallback onClear,
  }) {
    final hasSelection = controller.selection != null;

    flyoutController.showFlyout(
      position: position,
      builder: (flyoutCtx) {
        return MenuFlyout(
          items: [
            MenuFlyoutItem(
              leading: const Icon(FluentIcons.copy, size: AppIconSize.md),
              text: Text(context.l10n.terminalCopy),
              trailing: Text(
                'Ctrl+C',
                style: AppTypo.micro(context).copyWith(
                  color: AppColors.textMuted(context),
                ),
              ),
              onPressed: hasSelection
                  ? () async {
                      Navigator.of(flyoutCtx).pop();
                      final selection = controller.selection;
                      if (selection != null) {
                        final text = terminal.buffer.getText(selection);
                        if (text.isNotEmpty) {
                          await Clipboard.setData(ClipboardData(text: text));
                          controller.clearSelection();
                        }
                      }
                    }
                  : null,
            ),
            MenuFlyoutItem(
              leading: const Icon(FluentIcons.paste, size: AppIconSize.md),
              text: Text(context.l10n.terminalPaste),
              trailing: Text(
                'Ctrl+V',
                style: AppTypo.micro(context).copyWith(
                  color: AppColors.textMuted(context),
                ),
              ),
              onPressed: () async {
                Navigator.of(flyoutCtx).pop();
                final data = await Clipboard.getData(Clipboard.kTextPlain);
                final text = data?.text;
                if (text != null && text.isNotEmpty) {
                  terminal.paste(text);
                  controller.clearSelection();
                }
              },
            ),
            MenuFlyoutItem(
              leading: const Icon(FluentIcons.select_all, size: AppIconSize.md),
              text: Text(context.l10n.terminalSelectAll),
              trailing: Text(
                'Ctrl+A',
                style: AppTypo.micro(context).copyWith(
                  color: AppColors.textMuted(context),
                ),
              ),
              onPressed: () {
                Navigator.of(flyoutCtx).pop();
                final maxLine = (terminal.buffer.height - 1).clamp(0, terminal.buffer.lines.length - 1);
                controller.setSelection(
                  terminal.buffer.createAnchor(0, 0),
                  terminal.buffer.createAnchor(terminal.viewWidth, maxLine),
                  mode: xterm.SelectionMode.line,
                );
              },
            ),
            const MenuFlyoutSeparator(),
            MenuFlyoutItem(
              leading: const Icon(FluentIcons.clear, size: AppIconSize.md),
              text: Text(context.l10n.terminalClearBuffer),
              onPressed: () {
                Navigator.of(flyoutCtx).pop();
                onClear();
              },
            ),
          ],
        );
      },
    );
  }
}
