import 'dart:async';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';

/// Industrial-grade Startup Splash Screen for Otrhys playing the official motion design animation.
///
/// Plays `assets/images/animation_x2.webp` at 2.0x playback speed (4.0s total duration).
/// Uses Flutter's native hardware-accelerated animated image engine (zero C++/NuGet dependencies).
/// Automatically transitions to the application upon completion with user skip support.
class SplashScreen extends StatefulWidget {
  /// Callback invoked when the splash animation finishes or is dismissed.
  final VoidCallback? onAnimationComplete;

  /// Duration of the splash animation (defaults to 4000ms for 2x video playback).
  final Duration duration;

  /// Whether user can skip the animation via Space/Enter/Escape or click.
  final bool allowSkip;

  const SplashScreen({
    super.key,
    this.onAnimationComplete,
    this.duration = const Duration(milliseconds: 4000),
    this.allowSkip = true,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  bool _hasCompleted = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.duration, _completeSplash);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/images/animation_x2.webp'), context);
  }

  void _completeSplash() {
    if (_hasCompleted) return;
    _hasCompleted = true;
    _timer?.cancel();
    widget.onAnimationComplete?.call();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (widget.allowSkip &&
            event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.space ||
                event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.escape)) {
          _completeSplash();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.allowSkip ? _completeSplash : null,
        behavior: HitTestBehavior.opaque,
        child: Container(
          color: Colors.white, // Matches the video canvas background
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.asset(
              'assets/images/animation_x2.webp',
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ),
    );
  }
}
