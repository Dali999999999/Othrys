import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vpsmanager/core/l10n/l10n.dart';
import 'package:vpsmanager/features/file_manager/widgets/sftp_embedded_terminal.dart';

Widget createTestApp(Widget child) {
  return ProviderScope(
    child: FluentApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ScaffoldPage(
        content: child,
      ),
    ),
  );
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  Widget prepareApp(WidgetTester tester, Widget child) {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    return createTestApp(child);
  }

  group('SftpEmbeddedTerminal', () {
    testWidgets('renders terminal header, buttons, and handles close callback', (tester) async {
      bool closeCalled = false;

      await tester.pumpWidget(prepareApp(
        tester,
        SftpEmbeddedTerminal(
          currentPath: '/var/www/html',
          onClose: () => closeCalled = true,
        ),
      ));
      await tester.pumpAndSettle();

      // Check header title contains path
      expect(find.textContaining('/var/www/html'), findsOneWidget);

      // Check action buttons in header
      expect(find.byIcon(FluentIcons.sync_folder), findsOneWidget);
      expect(find.byIcon(FluentIcons.clear), findsOneWidget);
      expect(find.byIcon(FluentIcons.cancel), findsOneWidget);

      // When no active SSH connection exists, displays error message
      expect(find.text('No active SSH connection'), findsOneWidget);

      // Tap close button
      await tester.tap(find.widgetWithIcon(IconButton, FluentIcons.cancel));
      await tester.pumpAndSettle();
      expect(closeCalled, isTrue);
    });

    testWidgets('expand/collapse button toggles terminal height', (tester) async {
      await tester.pumpWidget(prepareApp(
        tester,
        SftpEmbeddedTerminal(
          currentPath: '/home/ubuntu',
          onClose: () {},
        ),
      ));
      await tester.pumpAndSettle();

      // Toggle expand
      await tester.tap(find.widgetWithIcon(IconButton, FluentIcons.fit_page));
      await tester.pumpAndSettle();

      // Icon changes to collapse_content
      expect(find.byIcon(FluentIcons.collapse_content), findsOneWidget);

      // Toggle back to collapse
      await tester.tap(find.widgetWithIcon(IconButton, FluentIcons.collapse_content));
      await tester.pumpAndSettle();

      expect(find.byIcon(FluentIcons.fit_page), findsOneWidget);
    });
  });
}
