import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'splash_particles.dart';

/// Industrial-grade CustomPainter for the Otrhys motion design splash screen.
/// Implements Acts 1 to 6 visual rendering in compliance with MOTION-DESIGN-SPLASH-OTRHYS.md.
/// Orchestrates the progressive energy wavefronts that forge the logo from zero.
class SplashPainter extends CustomPainter {
  /// Master progress of the splash sequence (0.0 to 1.0 over ~3200ms).
  final double animationProgress;

  /// Particle engine reference.
  final SplashParticleSystem particleSystem;

  /// Current interpolated center position of the logo mark.
  final Offset logoCenter;

  /// Current display size of the logo mark (120px -> 36px in Act 5).
  final double logoSize;

  /// Bounce scale factor during Act 4 (1.08 -> 1.0).
  final double bounceScale;

  /// Overall master opacity during Act 6 fade-out (1.0 -> 0.0).
  final double masterOpacity;

  /// Progress of the logo's physical formation (0.0 to 1.0 between 500ms and 1800ms).
  final double formationProgress;

  SplashPainter({
    required this.animationProgress,
    required this.particleSystem,
    required this.logoCenter,
    required this.logoSize,
    required this.bounceScale,
    required this.masterOpacity,
    required this.formationProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (masterOpacity <= 0.001) return;

    final center = Offset(size.width / 2, size.height / 2);
    final ms = animationProgress * 3200.0;

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 1. ACTE 1, 4 & 6 : HALO RADIAL AMBIANT (BLEU #2979FF)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    _drawAmbientHalo(canvas, center, ms);

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 2. PARTICULES (Micro-particules ambiantes & traînées de forge)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    _drawParticles(canvas, center, ms);

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 3. ACTE 2 & 3 : FRONTS D'ÉNERGIE DE FORGE (LASER WAVEFRONTS)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    if (formationProgress > 0.001 && formationProgress < 0.999) {
      _drawFormationWavefronts(canvas, center, ms);
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 4. ACTE 3b & 3c : FLASHES DE COLLISION AUX CROISEMENTS
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    if (ms >= 1400 && ms <= 1800) {
      _drawIntersectionFlashes(canvas, center, ms);
    }

    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    // 5. ACTE 4 : SHOCKWAVE (ONDE DE CHOC EXPANSIVE)
    // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    if (ms >= 1800 && ms <= 2200) {
      _drawShockwave(canvas, center, ms);
    }
  }

  /// ACTE 1, 4 & 6 : Halo radial bleu (#2979FF) respirant au centre.
  void _drawAmbientHalo(Canvas canvas, Offset center, double ms) {
    double haloOpacity = 0.05;
    double haloRadius = 100.0;

    if (ms < 500) {
      // Acte 1 : respiration douce 3% -> 8% -> 5%
      final t = ms / 500.0;
      final cycle = math.sin(t * math.pi);
      haloOpacity = 0.03 + 0.05 * cycle;
      haloRadius = 80.0 + 40.0 * cycle;
    } else if (ms < 1200) {
      // Acte 2 : intensifie à mesure que les rubans se forgent (8% -> 15%)
      final t = (ms - 500) / 700.0;
      haloOpacity = 0.08 + 0.07 * Curves.easeOut.transform(t);
      haloRadius = 120.0 + 30.0 * t;
    } else if (ms < 1800) {
      // Acte 3 : concentration
      final t = (ms - 1200) / 600.0;
      haloOpacity = 0.15 - 0.05 * t;
      haloRadius = 150.0;
    } else if (ms < 2800) {
      // Acte 4 & 5 : glow stabilisé à 8%, rayon 180px
      haloOpacity = 0.08;
      haloRadius = 180.0;
    } else {
      // Acte 6 : respiration subtile 6% <-> 10%
      final t = (ms - 2800) / 400.0;
      final breath = math.sin(t * math.pi * 2);
      haloOpacity = 0.08 + 0.02 * breath;
      haloRadius = 180.0;
    }

    final effectiveOpacity = (haloOpacity * masterOpacity).clamp(0.0, 1.0);
    if (effectiveOpacity <= 0.001) return;

    final haloCenter = (ms >= 2200) ? logoCenter : center;

    final haloPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF2979FF).withValues(alpha: effectiveOpacity),
          const Color(0xFF00D4FF).withValues(alpha: effectiveOpacity * 0.4),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(
        Rect.fromCircle(center: haloCenter, radius: haloRadius),
      );

    canvas.drawCircle(haloCenter, haloRadius, haloPaint);
  }

  /// Dessine le système de particules.
  void _drawParticles(Canvas canvas, Offset center, double ms) {
    double particleOpacity = masterOpacity;
    if (ms < 500) {
      particleOpacity *= (ms / 500.0).clamp(0.0, 1.0);
    } else if (ms >= 1800 && ms < 2200) {
      particleOpacity *= (1.0 - (ms - 1800) / 400.0).clamp(0.0, 1.0);
    } else if (ms >= 2200) {
      particleOpacity = 0.0;
    }

    particleSystem.paint(canvas, center, particleOpacity);
  }

  /// ACTE 2 & 3 : Dessine les fronts d'énergie laser qui matérialisent le logo de zéro.
  void _drawFormationWavefronts(Canvas canvas, Offset center, double ms) {
    final hexR = (logoSize * bounceScale) * 0.46;
    final curveProgress = Curves.easeInOutCubic.transform(formationProgress);
    final halfAngle = (math.pi * 0.55) * curveProgress;

    // Angles centraux des deux pôles
    const angleUpper = -math.pi / 4; // Quadrant haut-droit
    const angleLower = 3 * math.pi / 4; // Quadrant bas-gauche

    // Points d'avance du front supérieur (Cyan)
    final pUpper1 = center + Offset(hexR * math.cos(angleUpper - halfAngle), hexR * math.sin(angleUpper - halfAngle));
    final pUpper2 = center + Offset(hexR * math.cos(angleUpper + halfAngle), hexR * math.sin(angleUpper + halfAngle));

    // Points d'avance du front inférieur (Violet)
    final pLower1 = center + Offset(hexR * math.cos(angleLower - halfAngle), hexR * math.sin(angleLower - halfAngle));
    final pLower2 = center + Offset(hexR * math.cos(angleLower + halfAngle), hexR * math.sin(angleLower + halfAngle));

    final effectiveOpacity = masterOpacity.clamp(0.0, 1.0);

    // 1. Rayons laser / Lames de forge (Cyan)
    final cyanGlowPaint = Paint()
      ..color = const Color(0xFF00D4FF).withValues(alpha: 0.5 * effectiveOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

    final cyanCorePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85 * effectiveOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Ligne de front supérieur
    canvas.drawLine(center, pUpper1, cyanGlowPaint);
    canvas.drawLine(center, pUpper1, cyanCorePaint);
    canvas.drawLine(center, pUpper2, cyanGlowPaint);
    canvas.drawLine(center, pUpper2, cyanCorePaint);

    // 2. Rayons laser / Lames de forge (Violet)
    final violetGlowPaint = Paint()
      ..color = const Color(0xFF7C4DFF).withValues(alpha: 0.5 * effectiveOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);

    final violetCorePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85 * effectiveOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // Ligne de front inférieur
    canvas.drawLine(center, pLower1, violetGlowPaint);
    canvas.drawLine(center, pLower1, violetCorePaint);
    canvas.drawLine(center, pLower2, violetGlowPaint);
    canvas.drawLine(center, pLower2, violetCorePaint);

    // 3. Têtes d'énergie lumineuses (étincelles intenses sur la crête d'extrusion)
    _drawSparkNode(canvas, pUpper1, const Color(0xFF00D4FF), effectiveOpacity);
    _drawSparkNode(canvas, pUpper2, const Color(0xFF00D4FF), effectiveOpacity);
    _drawSparkNode(canvas, pLower1, const Color(0xFF7C4DFF), effectiveOpacity);
    _drawSparkNode(canvas, pLower2, const Color(0xFF7C4DFF), effectiveOpacity);
  }

  void _drawSparkNode(Canvas canvas, Offset point, Color color, double opacity) {
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.9 * opacity),
          color.withValues(alpha: 0.6 * opacity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(Rect.fromCircle(center: point, radius: 14.0));

    canvas.drawCircle(point, 14.0, glow);
    canvas.drawCircle(point, 3.0, Paint()..color = Colors.white.withValues(alpha: opacity));
  }

  /// ACTE 3b & 3c : Flash blanc (#FFFFFF @ 60%) aux points de collision.
  void _drawIntersectionFlashes(Canvas canvas, Offset center, double ms) {
    final hexR = (logoSize * bounceScale) * 0.46;
    final leftCrossing = Offset(center.dx - hexR * 0.86, center.dy);
    final rightCrossing = Offset(center.dx + hexR * 0.86, center.dy);

    // Flash #1 (croisement gauche à ~1450ms)
    if (ms >= 1400 && ms <= 1550) {
      final t = (ms - 1400) / 150.0;
      final flashOpacity = (1.0 - t) * 0.6 * masterOpacity;
      if (flashOpacity > 0.0) {
        final flashPaint = Paint()
          ..shader = RadialGradient(
            colors: [
              Colors.white.withValues(alpha: flashOpacity),
              Colors.white.withValues(alpha: 0.0),
            ],
          ).createShader(Rect.fromCircle(center: leftCrossing, radius: 26.0));
        canvas.drawCircle(leftCrossing, 26.0, flashPaint);
      }
    }

    // Flash #2 (croisement droit à ~1650ms)
    if (ms >= 1600 && ms <= 1750) {
      final t = (ms - 1600) / 150.0;
      final flashOpacity = (1.0 - t) * 0.6 * masterOpacity;
      if (flashOpacity > 0.0) {
        final flashPaint = Paint()
          ..shader = RadialGradient(
            colors: [
              Colors.white.withValues(alpha: flashOpacity),
              Colors.white.withValues(alpha: 0.0),
            ],
          ).createShader(Rect.fromCircle(center: rightCrossing, radius: 26.0));
        canvas.drawCircle(rightCrossing, 26.0, flashPaint);
      }
    }
  }

  /// ACTE 4 : Shockwave circulaire (anneau de 2px, rayon 0 -> 300px).
  void _drawShockwave(Canvas canvas, Offset center, double ms) {
    final t = ((ms - 1800) / 400.0).clamp(0.0, 1.0);
    final shockwaveRadius = 300.0 * Curves.easeOut.transform(t);
    final shockwaveOpacity = (0.4 * (1.0 - t) * masterOpacity).clamp(0.0, 1.0);

    if (shockwaveOpacity <= 0.001) return;

    final shockwavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = const Color(0xFF2979FF).withValues(alpha: shockwaveOpacity);

    canvas.drawCircle(center, shockwaveRadius, shockwavePaint);
  }

  @override
  bool shouldRepaint(covariant SplashPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.logoCenter != logoCenter ||
        oldDelegate.logoSize != logoSize ||
        oldDelegate.bounceScale != bounceScale ||
        oldDelegate.masterOpacity != masterOpacity ||
        oldDelegate.formationProgress != formationProgress;
  }
}
