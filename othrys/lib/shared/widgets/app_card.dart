import 'package:fluent_ui/fluent_ui.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';

/// Standardized card container component complying with the Othrys Design System.
///
/// Supports active state border highlight (brand blue 40%), custom padding, tap callback,
/// and smooth desktop hover elevation feedback.
class AppCard extends StatefulWidget {
  /// Inner card content.
  final Widget child;

  /// Whether the card represents an active/selected state (e.g. connected server).
  final bool isActive;

  /// Optional padding override (defaults to [AppSpacing.cardPadding]).
  final EdgeInsetsGeometry? padding;

  /// Optional tap callback rendering the card interactive.
  final VoidCallback? onTap;

  /// Optional background color override.
  final Color? backgroundColor;

  const AppCard({
    super.key,
    required this.child,
    this.isActive = false,
    this.padding,
    this.onTap,
    this.backgroundColor,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final baseCardColor = widget.backgroundColor ?? AppColors.surfaceCard(context);

    // Subtle 5% brightness increase on hover for interactive cards
    final resolvedBackgroundColor = (_isHovered && widget.onTap != null)
        ? Color.alphaBlend(
            (FluentTheme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black)
                .withValues(alpha: 0.04),
            baseCardColor,
          )
        : baseCardColor;

    final borderColor = widget.isActive
        ? AppColors.activeBorder(AppColors.brandBlue)
        : (_isHovered && widget.onTap != null)
            ? AppColors.surfaceBorder(context).withValues(alpha: 0.8)
            : AppColors.surfaceBorder(context);

    final cardContainer = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      padding: widget.padding ?? AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: resolvedBackgroundColor,
        borderRadius: AppRadius.borderMd,
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: widget.child,
    );

    if (widget.onTap != null) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          behavior: HitTestBehavior.opaque,
          child: cardContainer,
        ),
      );
    }

    return cardContainer;
  }
}
