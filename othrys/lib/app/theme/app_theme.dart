import 'package:fluent_ui/fluent_ui.dart';
import 'app_colors.dart';

export 'app_colors.dart';
export 'app_typography.dart';
export 'app_spacing.dart';
export 'app_radius.dart';
export 'app_icons.dart';
export 'app_dialog_sizes.dart';

/// Fluent UI theme engine configuration for Othrys.
///
/// Follows the Dark-first philosophy with 100% Light mode parity.
class AppTheme {
  AppTheme._();

  /// Primary application accent color.
  static final AccentColor primaryAccent = AppColors.primaryAccent;

  /// Backward-compatible alias for primary accent cyan.
  static const Color accentCyan = AppColors.accentCyan;

  /// Backward-compatible alias for success green.
  static const Color successGreen = AppColors.success;

  /// Backward-compatible alias for warning orange.
  static const Color warningOrange = AppColors.warning;

  /// Backward-compatible alias for error red.
  static const Color errorRed = AppColors.danger;

  /// Dark theme factory.
  static FluentThemeData dark() => darkTheme();

  /// Light theme factory.
  static FluentThemeData light() => lightTheme();

  /// Factory creating the standardized dark FluentThemeData.
  static FluentThemeData darkTheme() {
    return FluentThemeData(
      brightness: Brightness.dark,
      accentColor: primaryAccent,
      scaffoldBackgroundColor: const Color(0xFF0B0E18),
      cardColor: const Color(0xFF111628),
      menuColor: const Color(0xFF1A2035),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      typography: const Typography.raw(
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Color(0xFFF0F4FC),
          letterSpacing: -0.5,
        ),
        title: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFFF0F4FC),
        ),
        subtitle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFFC5CDDF),
        ),
        bodyLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFFC5CDDF),
        ),
        body: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: Color(0xFF8490A8),
        ),
        caption: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: Color(0xFF5C6880),
        ),
      ),
    );
  }

  /// Factory creating the standardized light FluentThemeData.
  static FluentThemeData lightTheme() {
    return FluentThemeData(
      brightness: Brightness.light,
      accentColor: primaryAccent,
      scaffoldBackgroundColor: const Color(0xFFF5F7FB),
      cardColor: const Color(0xFFFFFFFF),
      menuColor: const Color(0xFFE8ECF4),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      typography: const Typography.raw(
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A1E2E),
          letterSpacing: -0.5,
        ),
        title: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1E2E),
        ),
        subtitle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF242838),
        ),
        bodyLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF242838),
        ),
        body: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: Color(0xFF556178),
        ),
        caption: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: Color(0xFF6B7A92),
        ),
      ),
    );
  }
}
