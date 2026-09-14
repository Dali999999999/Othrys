import 'package:flutter/widgets.dart';
import 'package:xterm/xterm.dart';
import '../../../../app/theme/app_colors.dart';

/// Custom TerminalTheme configured for high contrast, dark Fluent UI aesthetic
/// and prominent selection highlight.
///
/// Per Design System section 13.3, the terminal emulator remains an indigo dark
/// island (#0B0E18) even when the overall application operates in Light mode.
class AppTerminalThemeData {
  const AppTerminalThemeData._();

  /// Dark theme configuration for xterm terminal emulator.
  static const darkTheme = TerminalTheme(
    cursor: AppColors.accentBlue,
    selection: Color(0x660078D4),
    foreground: Color(0xFFF0F4FC),
    background: AppColors.consoleBackground,
    black: Color(0xFF484F58),
    red: Color(0xFFFF7B72),
    green: Color(0xFF3FB950),
    yellow: Color(0xFFD29922),
    blue: AppColors.accentBlue,
    magenta: Color(0xFFBC8CFF),
    cyan: Color(0xFF39C5CF),
    white: Color(0xFFB1BAC4),
    brightBlack: Color(0xFF6E7681),
    brightRed: Color(0xFFFFA198),
    brightGreen: Color(0xFF56D364),
    brightYellow: Color(0xFFE3B341),
    brightBlue: Color(0xFF79C0FF),
    brightMagenta: Color(0xFFD2A8FF),
    brightCyan: Color(0xFF56D4DD),
    brightWhite: Color(0xFFF0F6FC),
    searchHitBackground: Color(0xFF31FF26),
    searchHitBackgroundCurrent: Color(0xFFE3B341),
    searchHitForeground: Color(0xFF000000),
  );

  /// Light theme for terminal: identical to darkTheme as terminal is a persistent dark island.
  static const lightTheme = darkTheme;
}
