import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:othrys/app/theme/app_colors.dart';
import 'package:othrys/app/theme/app_typography.dart';
import 'package:othrys/app/theme/app_spacing.dart';
import 'package:othrys/app/theme/app_radius.dart';
import 'package:othrys/app/theme/app_icons.dart';
import 'package:othrys/app/theme/app_dialog_sizes.dart';

void main() {
  group('Design System Tokens', () {
    test('AppSpacing tokens have expected 4-point values', () {
      expect(AppSpacing.xxs, 2.0);
      expect(AppSpacing.xs, 4.0);
      expect(AppSpacing.sm, 8.0);
      expect(AppSpacing.md, 12.0);
      expect(AppSpacing.lg, 16.0);
      expect(AppSpacing.xl, 20.0);
      expect(AppSpacing.xxl, 24.0);
      expect(AppSpacing.xxxl, 32.0);
    });

    test('AppRadius tokens have expected scale', () {
      expect(AppRadius.sm, 4.0);
      expect(AppRadius.md, 8.0);
      expect(AppRadius.pill, 999.0);
    });

    test('AppIconSize tokens have expected scale', () {
      expect(AppIconSize.xs, 10.0);
      expect(AppIconSize.sm, 12.0);
      expect(AppIconSize.md, 14.0);
      expect(AppIconSize.lg, 20.0);
      expect(AppIconSize.xl, 32.0);
      expect(AppIconSize.hero, 48.0);
    });

    test('AppDialogSize tokens have expected values', () {
      expect(AppDialogSize.compactWidth, 460.0);
      expect(AppDialogSize.standardWidth, 520.0);
      expect(AppDialogSize.wideWidth, 740.0);
      expect(AppDialogSize.wideHeight, 480.0);
    });

    test('Brand colors and gradient match Design System v2.0 extraction', () {
      expect(AppColors.brandCyan, const Color(0xFF00D4FF));
      expect(AppColors.brandBlue, const Color(0xFF2979FF));
      expect(AppColors.brandViolet, const Color(0xFF7C4DFF));
      expect(AppColors.brandNavy, const Color(0xFF151038));
      expect(AppColors.primaryAccent.normal, AppColors.brandBlue);
      expect(AppColors.brandGradient.colors, const [
        AppColors.brandCyan,
        AppColors.brandBlue,
        AppColors.brandViolet,
      ]);
    });

    testWidgets('AppColors and AppTypo resolve correctly for dark and light themes', (tester) async {
      // Dark Theme test
      await tester.pumpWidget(
        FluentTheme(
          data: FluentThemeData(brightness: Brightness.dark),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                expect(AppColors.surfaceBase(context), const Color(0xFF0B0E18));
                expect(AppColors.surfaceCard(context), const Color(0xFF111628));
                expect(AppColors.surfaceElevated(context), const Color(0xFF1A2035));
                expect(AppColors.surfaceBorder(context), const Color(0xFF2A3148));
                expect(AppColors.textPrimary(context), const Color(0xFFF0F4FC));
                expect(AppColors.textSecondary(context), const Color(0xFFC5CDDF));
                expect(AppColors.textMuted(context), const Color(0xFF8490A8));
                expect(AppColors.textFaint(context), const Color(0xFF5C6880));

                final display = AppTypo.displayLarge(context);
                expect(display.fontSize, 24);
                expect(display.fontWeight, FontWeight.w700);
                expect(display.letterSpacing, -0.5);

                final code = AppTypo.code(context);
                expect(code.fontFamily, 'JetBrainsMono');
                expect(code.fontSize, 12);

                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      // Light Theme test
      await tester.pumpWidget(
        FluentTheme(
          data: FluentThemeData(brightness: Brightness.light),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                expect(AppColors.surfaceBase(context), const Color(0xFFF5F7FB));
                expect(AppColors.surfaceCard(context), const Color(0xFFFFFFFF));
                expect(AppColors.surfaceElevated(context), const Color(0xFFE8ECF4));
                expect(AppColors.surfaceBorder(context), const Color(0xFFCDD5E0));
                expect(AppColors.textPrimary(context), const Color(0xFF1A1E2E));
                expect(AppColors.textSecondary(context), const Color(0xFF242838));
                expect(AppColors.textMuted(context), const Color(0xFF556178));
                expect(AppColors.textFaint(context), const Color(0xFF6B7A92));
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
    });
  });
}
