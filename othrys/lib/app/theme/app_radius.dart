import 'package:flutter/painting.dart';

/// Standardized border radius tokens for Othrys.
class AppRadius {
  AppRadius._();

  /// Badges, pills, tags, shortcut badges, selection highlights (4.0px).
  static const double sm = 4.0;

  /// Cards, dialogs, settings sections, containers, consoles (8.0px).
  static const double md = 8.0;

  /// Count indicators, avatars, fully rounded chips (999.0px).
  static const double pill = 999.0;

  // Pre-built BorderRadius objects for convenience
  /// Circular border radius 4.0px.
  static final BorderRadius borderSm = BorderRadius.circular(sm);

  /// Circular border radius 8.0px.
  static final BorderRadius borderMd = BorderRadius.circular(md);

  /// Circular border radius 999.0px.
  static final BorderRadius borderPill = BorderRadius.circular(pill);
}
