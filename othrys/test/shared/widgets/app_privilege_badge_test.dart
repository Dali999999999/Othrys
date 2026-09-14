import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vpsmanager/core/l10n/l10n.dart';
import 'package:vpsmanager/core/models/user_privileges_entity.dart';
import 'package:vpsmanager/shared/widgets/app_privilege_badge.dart';

void main() {
  Widget testWrapper(Widget child) {
    return FluentApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ScaffoldPage(content: child),
    );
  }

  testWidgets('AppPrivilegeBadge renders Root badge with shield_alert', (tester) async {
    const priv = UserPrivileges(
      uid: 0,
      username: 'root',
      groups: ['root'],
      canSudoWithoutPassword: true,
    );

    await tester.pumpWidget(testWrapper(const AppPrivilegeBadge(privileges: priv)));
    await tester.pumpAndSettle();

    expect(find.byType(AppPrivilegeBadge), findsOneWidget);
    expect(find.byIcon(FluentIcons.shield_alert), findsOneWidget);
  });

  testWidgets('AppPrivilegeBadge renders Sudoer badge with admin icon', (tester) async {
    const priv = UserPrivileges(
      uid: 1000,
      username: 'ubuntu',
      groups: ['ubuntu', 'sudo'],
      canSudoWithoutPassword: true,
    );

    await tester.pumpWidget(testWrapper(const AppPrivilegeBadge(privileges: priv)));
    await tester.pumpAndSettle();

    expect(find.byType(AppPrivilegeBadge), findsOneWidget);
    expect(find.byIcon(FluentIcons.admin), findsOneWidget);
  });

  testWidgets('AppPrivilegeBadge renders Standard badge with permissions icon', (tester) async {
    const priv = UserPrivileges(
      uid: 1001,
      username: 'developer',
      groups: ['developer'],
      canSudoWithoutPassword: false,
    );

    await tester.pumpWidget(testWrapper(const AppPrivilegeBadge(privileges: priv)));
    await tester.pumpAndSettle();

    expect(find.byType(AppPrivilegeBadge), findsOneWidget);
    expect(find.byIcon(FluentIcons.permissions), findsOneWidget);
  });
}
