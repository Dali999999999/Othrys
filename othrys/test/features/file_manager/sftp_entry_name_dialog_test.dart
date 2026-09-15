import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:othrys/core/l10n/l10n.dart';
import 'package:othrys/features/file_manager/widgets/sftp_entry_name_dialog.dart';

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

  testWidgets('SftpEntryNameDialog renders title, current path, and input field', (tester) async {
    await tester.pumpWidget(prepareApp(
      tester,
      const SftpEntryNameDialog(
        title: 'Create New Folder',
        currentPath: '/var/www/html',
        isDirectory: true,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Create New Folder'), findsOneWidget);
    expect(find.text('/var/www/html'), findsOneWidget);
    expect(find.byType(TextBox), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);

    // Button disabled when empty
    final submitButton = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(submitButton.onPressed, isNull);
  });

  testWidgets('SftpEntryNameDialog enables submit when valid name entered', (tester) async {
    await tester.pumpWidget(prepareApp(
      tester,
      const SftpEntryNameDialog(
        title: 'Create New Folder',
        currentPath: '/home/user',
        isDirectory: true,
        existingNames: ['existing_folder'],
      ),
    ));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextBox), 'my_new_dir');
    await tester.pumpAndSettle();

    final submitButton = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(submitButton.onPressed, isNotNull);
  });

  testWidgets('SftpEntryNameDialog rejects invalid characters and duplicates', (tester) async {
    await tester.pumpWidget(prepareApp(
      tester,
      const SftpEntryNameDialog(
        title: 'Create New File',
        currentPath: '/home/user',
        isDirectory: false,
        existingNames: ['config.yaml'],
      ),
    ));
    await tester.pumpAndSettle();

    // Test duplicate name
    await tester.enterText(find.byType(TextBox), 'config.yaml');
    await tester.pumpAndSettle();
    expect(find.text('An item with this name already exists'), findsOneWidget);

    var submitButton = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(submitButton.onPressed, isNull);

    // Test slash character
    await tester.enterText(find.byType(TextBox), 'sub/file.txt');
    await tester.pumpAndSettle();
    expect(find.textContaining('invalid characters'), findsOneWidget);

    submitButton = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(submitButton.onPressed, isNull);
  });
}
