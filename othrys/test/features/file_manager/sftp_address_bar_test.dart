import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vpsmanager/core/l10n/l10n.dart';
import 'package:vpsmanager/features/file_manager/widgets/sftp_address_bar.dart';

Widget createTestApp(Widget child) {
  return FluentApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: ScaffoldPage(
      content: child,
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

  group('SftpAddressBar', () {
    testWidgets('renders breadcrumbs and navigation buttons correctly', (tester) async {
      final controller = TextEditingController(text: '/var/log/nginx');
      addTearDown(controller.dispose);

      bool backCalled = false;
      bool forwardCalled = false;
      bool upCalled = false;
      bool refreshCalled = false;
      String? navigatedPath;
      bool terminalToggled = false;

      await tester.pumpWidget(prepareApp(
        tester,
        SftpAddressBar(
          currentPath: '/var/log/nginx',
          isManualEditing: false,
          controller: controller,
          canNavigateBack: true,
          canNavigateForward: false,
          canNavigateUp: true,
          isTerminalOpen: false,
          onNavigateBack: () => backCalled = true,
          onNavigateForward: () => forwardCalled = true,
          onNavigateUp: () => upCalled = true,
          onRefresh: () => refreshCalled = true,
          onNavigate: (path) => navigatedPath = path,
          onToggleManualEdit: (_) {},
          onToggleTerminal: () => terminalToggled = true,
          onPathCopied: () {},
        ),
      ));
      await tester.pumpAndSettle();

      // Check breadcrumbs: var, log, nginx
      expect(find.text('var'), findsOneWidget);
      expect(find.text('log'), findsOneWidget);
      expect(find.text('nginx'), findsOneWidget);

      // Back button is enabled, forward is disabled
      final backButton = tester.widget<IconButton>(find.widgetWithIcon(IconButton, FluentIcons.back));
      expect(backButton.onPressed, isNotNull);
      await tester.tap(find.widgetWithIcon(IconButton, FluentIcons.back));
      expect(backCalled, isTrue);

      final forwardButton = tester.widget<IconButton>(find.widgetWithIcon(IconButton, FluentIcons.forward));
      expect(forwardButton.onPressed, isNull);
      expect(forwardCalled, isFalse);

      // Up button
      await tester.tap(find.widgetWithIcon(IconButton, FluentIcons.up));
      await tester.pumpAndSettle();
      expect(upCalled, isTrue);

      // Refresh button
      await tester.tap(find.widgetWithIcon(IconButton, FluentIcons.refresh));
      await tester.pumpAndSettle();
      expect(refreshCalled, isTrue);

      // Breadcrumb navigation click on 'var'
      await tester.tap(find.text('var'));
      await tester.pumpAndSettle();
      expect(navigatedPath, '/var');

      // Terminal toggle button
      expect(find.byIcon(FluentIcons.command_prompt), findsOneWidget);
      await tester.tap(find.widgetWithIcon(Button, FluentIcons.command_prompt));
      await tester.pumpAndSettle();
      expect(terminalToggled, isTrue);
    });

    testWidgets('supports switching to manual edit mode and submitting path', (tester) async {
      final controller = TextEditingController(text: '/home/user');
      addTearDown(controller.dispose);

      bool toggleManualEditCalled = false;
      String? submittedPath;

      await tester.pumpWidget(prepareApp(
        tester,
        SftpAddressBar(
          currentPath: '/home/user',
          isManualEditing: false,
          controller: controller,
          canNavigateBack: false,
          canNavigateForward: false,
          canNavigateUp: true,
          isTerminalOpen: false,
          onNavigateBack: () {},
          onNavigateForward: () {},
          onNavigateUp: () {},
          onRefresh: () {},
          onNavigate: (path) => submittedPath = path,
          onToggleManualEdit: (val) => toggleManualEditCalled = val,
          onToggleTerminal: () {},
          onPathCopied: () {},
        ),
      ));
      await tester.pumpAndSettle();

      // Click the edit button
      await tester.tap(find.widgetWithIcon(IconButton, FluentIcons.edit));
      await tester.pumpAndSettle();
      expect(toggleManualEditCalled, isTrue);

      // Rebuild in manual editing mode
      await tester.pumpWidget(prepareApp(
        tester,
        SftpAddressBar(
          currentPath: '/home/user',
          isManualEditing: true,
          controller: controller,
          canNavigateBack: false,
          canNavigateForward: false,
          canNavigateUp: true,
          isTerminalOpen: false,
          onNavigateBack: () {},
          onNavigateForward: () {},
          onNavigateUp: () {},
          onRefresh: () {},
          onNavigate: (path) => submittedPath = path,
          onToggleManualEdit: (val) => toggleManualEditCalled = val,
          onToggleTerminal: () {},
          onPathCopied: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(TextBox), findsOneWidget);
      expect(find.byIcon(FluentIcons.check_mark), findsOneWidget);
      expect(find.byIcon(FluentIcons.cancel), findsOneWidget);

      controller.text = '/etc/nginx/sites-available';
      await tester.tap(find.widgetWithIcon(IconButton, FluentIcons.check_mark));
      await tester.pumpAndSettle();
      expect(submittedPath, '/etc/nginx/sites-available');
    });

    testWidgets('copy path button copies current directory to clipboard', (tester) async {
      String? copiedData;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (MethodCall methodCall) async {
        if (methodCall.method == 'Clipboard.setData') {
          copiedData = (methodCall.arguments as Map)['text'] as String?;
        }
        return null;
      });
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null);
      });

      final controller = TextEditingController(text: '/var/www');
      addTearDown(controller.dispose);

      bool copyNotificationCalled = false;

      await tester.pumpWidget(prepareApp(
        tester,
        SftpAddressBar(
          currentPath: '/var/www',
          isManualEditing: false,
          controller: controller,
          canNavigateBack: false,
          canNavigateForward: false,
          canNavigateUp: false,
          isTerminalOpen: false,
          onNavigateBack: () {},
          onNavigateForward: () {},
          onNavigateUp: () {},
          onRefresh: () {},
          onNavigate: (_) {},
          onToggleManualEdit: (_) {},
          onToggleTerminal: () {},
          onPathCopied: () => copyNotificationCalled = true,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithIcon(IconButton, FluentIcons.copy));
      await tester.pumpAndSettle();

      expect(copyNotificationCalled, isTrue);
      expect(copiedData, '/var/www');
    });

    testWidgets('copy and edit buttons are aligned to the right edge of address box', (tester) async {
      final controller = TextEditingController(text: '/');
      addTearDown(controller.dispose);

      bool editToggled = false;

      await tester.pumpWidget(prepareApp(
        tester,
        SftpAddressBar(
          currentPath: '/',
          isManualEditing: false,
          controller: controller,
          canNavigateBack: false,
          canNavigateForward: false,
          canNavigateUp: false,
          isTerminalOpen: false,
          onNavigateBack: () {},
          onNavigateForward: () {},
          onNavigateUp: () {},
          onRefresh: () {},
          onNavigate: (_) {},
          onToggleManualEdit: (val) => editToggled = val,
          onToggleTerminal: () {},
          onPathCopied: () {},
        ),
      ));
      await tester.pumpAndSettle();

      final copyRect = tester.getRect(find.widgetWithIcon(IconButton, FluentIcons.copy));
      final editRect = tester.getRect(find.widgetWithIcon(IconButton, FluentIcons.edit));
      final terminalRect = tester.getRect(find.widgetWithIcon(Button, FluentIcons.command_prompt));

      // Verify buttons are positioned at the right edge, just before terminal button
      expect(editRect.right, lessThan(terminalRect.left));
      expect(terminalRect.left - editRect.right, lessThan(20.0));
      expect(copyRect.right, editRect.left);

      // Verify tapping empty space between breadcrumbs and buttons opens manual editing
      await tester.tapAt(const Offset(500, 410));
      await tester.pumpAndSettle();
      expect(editToggled, isTrue);
    });
  });
}
