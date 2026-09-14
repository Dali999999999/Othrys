import 'package:fluent_ui/fluent_ui.dart';
import '../../app/theme/app_colors.dart';

/// Semantic status dot variants.
enum StatusDotVariant {
  /// Operational, running, or connected.
  success,

  /// Reconnecting, high utilization, or attention needed.
  warning,

  /// Disconnected, failed, or error.
  danger,

  /// Inactive, stopped, or disabled.
  inactive,

  /// Live data stream, informational indicator (Brand Cyan).
  info,

  /// Connecting in progress (Brand Blue, typically pulsing).
  connecting,
}

/// Standardized 8x8 status indicator dot.
///
/// Supports an optional smooth breathing/pulsing animation loop for live/connecting states.
class AppStatusDot extends StatefulWidget {
  /// Semantic variant determining the indicator's color.
  final StatusDotVariant variant;

  /// Whether the status dot should pulse continuously (1500ms easeInOut loop).
  final bool pulsing;

  const AppStatusDot({
    super.key,
    required this.variant,
    this.pulsing = false,
  });

  @override
  State<AppStatusDot> createState() => _AppStatusDotState();
}

class _AppStatusDotState extends State<AppStatusDot>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    if (widget.pulsing) {
      _initPulsing();
    }
  }

  @override
  void didUpdateWidget(AppStatusDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulsing != oldWidget.pulsing) {
      if (widget.pulsing) {
        _initPulsing();
      } else {
        _disposePulsing();
      }
    }
  }

  void _initPulsing() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _disposePulsing() {
    _controller?.dispose();
    _controller = null;
    _animation = null;
  }

  @override
  void dispose() {
    _disposePulsing();
    super.dispose();
  }

  Color _resolveColor(BuildContext context) {
    return switch (widget.variant) {
      StatusDotVariant.success => AppColors.success,
      StatusDotVariant.warning => AppColors.warning,
      StatusDotVariant.danger => AppColors.danger,
      StatusDotVariant.inactive => AppColors.textFaint(context),
      StatusDotVariant.info => AppColors.brandCyan,
      StatusDotVariant.connecting => AppColors.brandBlue,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _resolveColor(context);

    final dot = Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );

    if (widget.pulsing && _animation != null) {
      return FadeTransition(
        opacity: _animation!,
        child: dot,
      );
    }

    return dot;
  }
}
