import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:xterm/xterm.dart' as xterm;
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import 'terminal_context_menu.dart';
import 'terminal_theme_data.dart';

/// Interactive PTY tab view connected to an underlying remote SSH terminal session.
class TerminalTabView extends StatelessWidget {
  final xterm.Terminal terminal;
  final xterm.TerminalController controller;
  final FocusNode focusNode;
  final FlyoutController flyoutController;
  final VoidCallback onClear;

  const TerminalTabView({
    super.key,
    required this.terminal,
    required this.controller,
    required this.focusNode,
    required this.flyoutController,
    required this.onClear,
  });

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final isCtrl = HardwareKeyboard.instance.isControlPressed;
    final isShift = HardwareKeyboard.instance.isShiftPressed;

    // 1. Copy: Ctrl+C (when selection is active) or Ctrl+Shift+C (standard terminal copy)
    if (event.logicalKey == LogicalKeyboardKey.keyC) {
      if ((isCtrl && !isShift && controller.selection != null) || (isCtrl && isShift)) {
        final selection = controller.selection;
        if (selection != null) {
          final text = terminal.buffer.getText(selection);
          if (text.isNotEmpty) {
            Clipboard.setData(ClipboardData(text: text));
            controller.clearSelection();
          }
        }
        return KeyEventResult.handled;
      }
    }

    // 2. Paste: Ctrl+V or Ctrl+Shift+V
    if (event.logicalKey == LogicalKeyboardKey.keyV && isCtrl) {
      Clipboard.getData(Clipboard.kTextPlain).then((data) {
        final text = data?.text;
        if (text != null && text.isNotEmpty) {
          terminal.paste(text);
          controller.clearSelection();
        }
      });
      return KeyEventResult.handled;
    }

    // 3. Select All: Ctrl+A (without shift)
    if (event.logicalKey == LogicalKeyboardKey.keyA && isCtrl && !isShift) {
      final maxLine = (terminal.buffer.height - 1).clamp(0, terminal.buffer.lines.length - 1);
      controller.setSelection(
        terminal.buffer.createAnchor(0, 0),
        terminal.buffer.createAnchor(terminal.viewWidth, maxLine),
        mode: xterm.SelectionMode.line,
      );
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return FlyoutTarget(
      controller: flyoutController,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => focusNode.requestFocus(),
        child: Container(
          color: AppColors.consoleBackground,
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: xterm.TerminalView(
            terminal,
            controller: controller,
            focusNode: focusNode,
            autofocus: true,
            hardwareKeyboardOnly: true,
            theme: AppTerminalThemeData.darkTheme,
            backgroundOpacity: 1.0,
            autoResize: true,
            mouseCursor: SystemMouseCursors.text,
            onKeyEvent: _handleKeyEvent,
            onTapUp: (details, offset) => focusNode.requestFocus(),
            onSecondaryTapUp: (details, _) {
              TerminalContextMenu.show(
                context: context,
                flyoutController: flyoutController,
                position: details.globalPosition,
                terminal: terminal,
                controller: controller,
                onClear: onClear,
              );
            },
          ),
        ),
      ),
    );
  }
}
