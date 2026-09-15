import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:othrys/core/l10n/l10n.dart';
import 'package:othrys/features/terminal/widgets/terminal_context_menu.dart';
import 'package:othrys/features/terminal/widgets/terminal_tab_view.dart';
import 'package:xterm/xterm.dart' as xterm;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createTestWidget(Widget child) {
    return FluentApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('fr'),
      home: ScaffoldPage(content: child),
    );
  }

  testWidgets('TerminalTabView renders with terminal view and takes focus', (tester) async {
    final terminal = xterm.Terminal();
    final controller = xterm.TerminalController();
    final focusNode = FocusNode();
    final flyoutController = FlyoutController();

    await tester.pumpWidget(createTestWidget(
      TerminalTabView(
        terminal: terminal,
        controller: controller,
        focusNode: focusNode,
        flyoutController: flyoutController,
        onClear: () {},
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(TerminalTabView), findsOneWidget);
    expect(find.byType(xterm.TerminalView), findsOneWidget);

    focusNode.dispose();
    controller.dispose();
    flyoutController.dispose();
  });

  testWidgets('TerminalTabView Ctrl+A selects all lines in buffer', (tester) async {
    final terminal = xterm.Terminal();
    final controller = xterm.TerminalController();
    final focusNode = FocusNode();
    final flyoutController = FlyoutController();

    terminal.write('line 1\r\nline 2\r\n');

    await tester.pumpWidget(createTestWidget(
      TerminalTabView(
        terminal: terminal,
        controller: controller,
        focusNode: focusNode,
        flyoutController: flyoutController,
        onClear: () {},
      ),
    ));
    await tester.pumpAndSettle();

    focusNode.requestFocus();
    await tester.pump();

    // Trigger Ctrl+A
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();

    expect(controller.selection, isNotNull);

    focusNode.dispose();
    controller.dispose();
    flyoutController.dispose();
  });

  testWidgets('TerminalContextMenu shows copy, paste, select all and clear', (tester) async {
    final terminal = xterm.Terminal();
    final controller = xterm.TerminalController();
    final flyoutController = FlyoutController();
    var cleared = false;

    await tester.pumpWidget(createTestWidget(
      Builder(builder: (context) {
        return FlyoutTarget(
          controller: flyoutController,
          child: Button(
            child: const Text('Show Menu'),
            onPressed: () {
              TerminalContextMenu.show(
                context: context,
                flyoutController: flyoutController,
                position: const Offset(50, 50),
                terminal: terminal,
                controller: controller,
                onClear: () => cleared = true,
              );
            },
          ),
        );
      }),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Show Menu'));
    await tester.pumpAndSettle();

    expect(find.text('Copier'), findsOneWidget);
    expect(find.text('Coller'), findsOneWidget);
    expect(find.text('Tout sélectionner'), findsOneWidget);
    expect(find.text("Effacer l'écran"), findsOneWidget);

    await tester.tap(find.text("Effacer l'écran"));
    await tester.pumpAndSettle();
    expect(cleared, isTrue);

    controller.dispose();
    flyoutController.dispose();
  });
}
