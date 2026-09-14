import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vpsmanager/core/l10n/l10n.dart';
import 'package:vpsmanager/core/models/server_entity.dart';
import 'package:vpsmanager/features/servers/server_dialog.dart';

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

  testWidgets('ServerDialog renders required fields and indicators', (tester) async {
    await tester.pumpWidget(prepareApp(tester, const ServerDialog()));
    await tester.pumpAndSettle();

    expect(find.textContaining('Name *'), findsOneWidget);
    expect(find.textContaining('Host / IP Address *'), findsOneWidget);
    expect(find.textContaining('SSH Port *'), findsOneWidget);
    expect(find.textContaining('Username *'), findsOneWidget);
    expect(find.text('Test Connection'), findsOneWidget);
  });

  testWidgets('ServerDialog disables submit button when form is invalid', (tester) async {
    await tester.pumpWidget(prepareApp(tester, const ServerDialog()));
    await tester.pumpAndSettle();

    final filledButtons = find.byType(FilledButton);
    expect(filledButtons, findsOneWidget);

    final buttonWidget = tester.widget<FilledButton>(filledButtons);
    expect(buttonWidget.onPressed, isNull);
  });

  testWidgets('ServerDialog enables submit button when valid values are entered', (tester) async {
    await tester.pumpWidget(prepareApp(tester, const ServerDialog()));
    await tester.pumpAndSettle();

    final textboxes = find.byType(TextBox);
    // 0: Name, 1: Host, 2: Port, 3: Username
    await tester.enterText(textboxes.at(0), 'Production Server');
    await tester.enterText(textboxes.at(1), '192.168.1.100');
    await tester.enterText(textboxes.at(3), 'admin');
    await tester.pumpAndSettle();

    final filledButtons = find.byType(FilledButton);
    final buttonWidget = tester.widget<FilledButton>(filledButtons);
    expect(buttonWidget.onPressed, isNotNull);
  });

  testWidgets('ServerDialog populates existing server data in edit mode', (tester) async {
    final existing = ServerEntity(
      id: 'srv-1',
      name: 'Existing VPS',
      host: '10.0.0.1',
      port: 2222,
      username: 'ubuntu',
      authType: SSHAuthType.password,
      password: 'secret',
    );

    await tester.pumpWidget(prepareApp(tester, ServerDialog(initialServer: existing)));
    await tester.pumpAndSettle();

    expect(find.text('Existing VPS'), findsOneWidget);
    expect(find.text('10.0.0.1'), findsOneWidget);
    expect(find.text('2222'), findsOneWidget);
    expect(find.text('ubuntu'), findsOneWidget);

    final filledButtons = find.byType(FilledButton);
    final buttonWidget = tester.widget<FilledButton>(filledButtons);
    expect(buttonWidget.onPressed, isNotNull);
  });
}
