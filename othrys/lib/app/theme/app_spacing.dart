import 'package:flutter/painting.dart';

/// 4-point spacing grid and standardized padding presets for Othrys.
class AppSpacing {
  AppSpacing._();

  /// 2.0px spacing token.
  static const double xxs = 2.0;

  /// 4.0px spacing token.
  static const double xs = 4.0;

  /// 8.0px spacing token.
  static const double sm = 8.0;

  /// 12.0px spacing token.
  static const double md = 12.0;

  /// 16.0px spacing token.
  static const double lg = 16.0;

  /// 20.0px spacing token.
  static const double xl = 20.0;

  /// 24.0px spacing token.
  static const double xxl = 24.0;

  /// 32.0px spacing token.
  static const double xxxl = 32.0;

  // Page padding presets
  /// Standard page content padding (24px horizontal, 8px vertical).
  static const EdgeInsets pageContent =
      EdgeInsets.symmetric(horizontal: xxl, vertical: sm);

  // Card padding
  /// Standard container and card inner padding (16px).
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);

  // Badge padding
  /// Standard status badge and pill padding (6px horizontal, 2px vertical).
  static const EdgeInsets badgePadding =
      EdgeInsets.symmetric(horizontal: 6, vertical: 2);

  // Console padding
  /// Terminal emulator and console log box inner padding (12px).
  static const EdgeInsets consolePadding = EdgeInsets.all(md);
}
