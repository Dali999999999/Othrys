import 'package:fluent_ui/fluent_ui.dart';
import 'app_colors.dart';

/// Centralized typographic scale and monospace definitions for Othrys.
///
/// Follows the 2px incremental typographic scale and JetBrains Mono developer font.
class AppTypo {
  AppTypo._();

  /// Primary developer monospace font family.
  static const String fontMono = 'JetBrainsMono';

  /// Native fallback monospace font family.
  static const String fontMonoFallback = 'Consolas';

  /// Hero / big metric display numbers (24px, Bold, letterSpacing: -0.5).
  static TextStyle displayLarge(BuildContext context) => TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary(context),
        letterSpacing: -0.5,
      );

  /// Main page header titles (20px, Semi-bold).
  static TextStyle titleLarge(BuildContext context) => TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary(context),
      );

  /// Sub-section headers and empty state titles (16px, Semi-bold).
  static TextStyle titleMedium(BuildContext context) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary(context),
      );

  /// Standard body text, server names, action labels (14px, Medium).
  static TextStyle body(BuildContext context) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary(context),
      );

  /// Descriptions, log messages, subtitles (13px, Regular).
  static TextStyle bodySmall(BuildContext context) => TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted(context),
      );

  /// Host:port, technical metadata, endpoints (12px, Regular).
  static TextStyle caption(BuildContext context) => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textFaint(context),
      );

  /// Badges, tags, compact action buttons, timestamps (11px, Medium).
  static TextStyle micro(BuildContext context) => TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted(context),
      );

  /// Keyboard shortcuts, badge counters, mini indicators (10px, Bold).
  static TextStyle nano(BuildContext context) => TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: AppColors.textFaint(context),
      );

  // Monospace variants
  /// Monospace code text in terminal and console boxes.
  static TextStyle code(BuildContext context) => TextStyle(
        fontFamily: fontMono,
        fontFamilyFallback: const [fontMonoFallback, 'monospace'],
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.consoleText,
      );

  /// Secondary muted monospace text (e.g. host:port, hash, commit).
  static TextStyle codeMuted(BuildContext context) => TextStyle(
        fontFamily: fontMono,
        fontFamilyFallback: const [fontMonoFallback, 'monospace'],
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted(context),
      );

  /// Accent cyan monospace text (e.g. port forwarding, active endpoints).
  static TextStyle codeAccent(BuildContext context) => TextStyle(
        fontFamily: fontMono,
        fontFamilyFallback: const [fontMonoFallback, 'monospace'],
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.brandCyan,
      );
}
