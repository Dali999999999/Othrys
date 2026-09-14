import 'package:fluent_ui/fluent_ui.dart';

/// Standardized brand mark widget rendering the Othrys 3D intertwined hexagon logo.
///
/// Complies with Design System v2.0 specifications.
/// Provides standardized constructors for key brand placements:
/// - [AppBrandMark.titlebar] (18x18px) for the window titlebar.
/// - [AppBrandMark.hero] (64x64px) for onboarding and splash.
/// - [AppBrandMark.about] (48x48px) for settings and dialogs.
class AppBrandMark extends StatelessWidget {
  /// Dimension of the square logo asset in logical pixels.
  final double size;

  const AppBrandMark({super.key, this.size = 18});

  /// Window titlebar variant (18x18px).
  const AppBrandMark.titlebar({super.key}) : size = 18;

  /// Onboarding hero variant (64x64px).
  const AppBrandMark.hero({super.key}) : size = 64;

  /// About section / dialog variant (48x48px).
  const AppBrandMark.about({super.key}) : size = 48;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      width: size,
      height: size,
      filterQuality: FilterQuality.high,
    );
  }
}
