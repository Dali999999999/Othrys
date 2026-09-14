import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vpsmanager/app/theme/app_colors.dart';
import 'package:vpsmanager/shared/widgets/app_badge.dart';
import 'package:vpsmanager/shared/widgets/app_card.dart';
import 'package:vpsmanager/shared/widgets/app_console_box.dart';
import 'package:vpsmanager/shared/widgets/app_empty_state.dart';
import 'package:vpsmanager/shared/widgets/app_metric_card.dart';
import 'package:vpsmanager/shared/widgets/app_section_card.dart';
import 'package:vpsmanager/shared/widgets/app_shortcut_badge.dart';
import 'package:vpsmanager/shared/widgets/app_status_dot.dart';
import 'package:vpsmanager/shared/widgets/app_brand_mark.dart';

void main() {
  group('Design System Atomic & Molecular Components', () {
    testWidgets('AppStatusDot renders without error for static and pulsing modes', (tester) async {
      await tester.pumpWidget(
        FluentApp(
          home: Column(
            children: const [
              AppStatusDot(variant: StatusDotVariant.success),
              AppStatusDot(variant: StatusDotVariant.warning, pulsing: true),
              AppStatusDot(variant: StatusDotVariant.danger),
              AppStatusDot(variant: StatusDotVariant.inactive),
              AppStatusDot(variant: StatusDotVariant.info),
              AppStatusDot(variant: StatusDotVariant.connecting, pulsing: true),
            ],
          ),
        ),
      );

      expect(find.byType(AppStatusDot), findsNWidgets(6));
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('AppBadge and AppShortcutBadge render expected labels', (tester) async {
      await tester.pumpWidget(
        FluentApp(
          home: Column(
            children: const [
              AppBadge(label: 'RUNNING', variant: AppBadgeVariant.success),
              AppBadge(label: 'STOPPED', variant: AppBadgeVariant.neutral, icon: FluentIcons.power_button),
              AppBadge(label: 'BRAND', variant: AppBadgeVariant.accent),
              AppShortcutBadge(shortcut: 'Ctrl+K'),
            ],
          ),
        ),
      );

      expect(find.text('RUNNING'), findsOneWidget);
      expect(find.text('STOPPED'), findsOneWidget);
      expect(find.text('BRAND'), findsOneWidget);
      expect(find.text('Ctrl+K'), findsOneWidget);
      expect(find.byIcon(FluentIcons.power_button), findsOneWidget);
    });

    testWidgets('AppCard handles active state and onTap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        FluentApp(
          home: ScaffoldPage(
            content: AppCard(
              isActive: true,
              onTap: () => tapped = true,
              child: const Text('Server Card'),
            ),
          ),
        ),
      );

      expect(find.text('Server Card'), findsOneWidget);
      await tester.tap(find.text('Server Card'));
      expect(tapped, isTrue);
    });

    testWidgets('AppConsoleBox renders monospace text', (tester) async {
      await tester.pumpWidget(
        const FluentApp(
          home: ScaffoldPage(
            content: AppConsoleBox(
              content: 'docker ps -a',
              height: 200,
            ),
          ),
        ),
      );

      expect(find.text('docker ps -a'), findsOneWidget);
    });

    testWidgets('AppMetricCard displays formatted percent and value', (tester) async {
      await tester.pumpWidget(
        FluentApp(
          home: ScaffoldPage(
            content: AppMetricCard(
              label: 'CPU Usage',
              value: '64%',
              subtitle: '4 Cores',
              percent: 64.0,
              color: AppColors.accentCyan,
            ),
          ),
        ),
      );

      expect(find.text('CPU Usage'), findsOneWidget);
      expect(find.text('64%'), findsOneWidget);
      expect(find.text('4 Cores'), findsOneWidget);
      expect(find.byType(ProgressBar), findsOneWidget);
    });

    testWidgets('AppEmptyState renders title and fires action callback', (tester) async {
      bool actionFired = false;
      await tester.pumpWidget(
        FluentApp(
          home: ScaffoldPage(
            content: AppEmptyState(
              icon: FluentIcons.server,
              title: 'No Servers Found',
              subtitle: 'Add a server to start',
              actionLabel: 'Add Server',
              onAction: () => actionFired = true,
            ),
          ),
        ),
      );

      expect(find.text('No Servers Found'), findsOneWidget);
      expect(find.text('Add a server to start'), findsOneWidget);
      expect(find.text('Add Server'), findsOneWidget);

      await tester.tap(find.text('Add Server'));
      await tester.pumpAndSettle();
      expect(actionFired, isTrue);
    });

    testWidgets('AppSectionCard wraps child with section title', (tester) async {
      await tester.pumpWidget(
        const FluentApp(
          home: ScaffoldPage(
            content: AppSectionCard(
              title: 'Preferences',
              child: Text('Options List'),
            ),
          ),
        ),
      );

      expect(find.text('Preferences'), findsOneWidget);
      expect(find.text('Options List'), findsOneWidget);
    });

    testWidgets('AppBrandMark renders image asset with appropriate dimensions', (tester) async {
      await tester.pumpWidget(
        FluentApp(
          home: ScaffoldPage(
            content: Column(
              children: const [
                AppBrandMark.titlebar(),
                AppBrandMark.hero(),
                AppBrandMark.about(),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(AppBrandMark), findsNWidgets(3));
      final images = tester.widgetList<Image>(find.byType(Image)).toList();
      expect(images.length, 3);
      expect(images[0].width, 18.0);
      expect(images[1].width, 64.0);
      expect(images[2].width, 48.0);
    });
  });
}
