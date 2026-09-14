import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Single particle instance for the Otrhys splash animation.
class SplashParticle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  Color baseColor;
  double opacity;
  double life; // 0.0 to 1.0
  double decayRate;
  bool isTrail;

  SplashParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.baseColor,
    required this.opacity,
    required this.life,
    required this.decayRate,
    this.isTrail = false,
  });
}

/// Particle simulation system managing Act 1 ambient and Act 2 trail particles.
class SplashParticleSystem {
  final math.Random _random = math.Random(42); // Seeded for deterministic aesthetics
  final List<SplashParticle> _ambientParticles = [];
  final List<SplashParticle> _trailParticles = [];

  static const int maxTrailParticles = 30;

  SplashParticleSystem() {
    _initAmbientParticles();
  }

  void _initAmbientParticles() {
    _ambientParticles.clear();
    // 6 ambient micro-particles floating near the center (Act 1 specifications)
    for (int i = 0; i < 6; i++) {
      final angle = (i / 6) * 2 * math.pi + _random.nextDouble() * 0.5;
      final dist = 15.0 + _random.nextDouble() * 30.0;
      _ambientParticles.add(
        SplashParticle(
          x: math.cos(angle) * dist,
          y: math.sin(angle) * dist,
          vx: (_random.nextDouble() - 0.5) * 0.3,
          vy: (_random.nextDouble() - 0.5) * 0.3,
          size: 1.0 + _random.nextDouble() * 1.2,
          baseColor: const Color(0xFF00D4FF),
          opacity: 0.25 + _random.nextDouble() * 0.15,
          life: 1.0,
          decayRate: 0.0,
          isTrail: false,
        ),
      );
    }
  }

  /// Update particle positions and lifecycle.
  void update({
    required double dt,
    required Offset center,
    required bool isEmittingTrails,
    Offset? cyanHead,
    Offset? violetHead,
    required double trailEmissionFactor,
    required double globalParticleOpacity,
  }) {
    // 1. Update ambient particles
    for (final p in _ambientParticles) {
      p.x += p.vx;
      p.y += p.vy;

      // Soft circular boundary around center (~60px radius)
      final distSq = p.x * p.x + p.y * p.y;
      if (distSq > 60 * 60) {
        p.vx = -p.vx * 0.8 + (_random.nextDouble() - 0.5) * 0.1;
        p.vy = -p.vy * 0.8 + (_random.nextDouble() - 0.5) * 0.1;
      }
    }

    // 2. Update and age existing trail particles
    for (int i = _trailParticles.length - 1; i >= 0; i--) {
      final p = _trailParticles[i];
      p.life -= p.decayRate * dt;
      p.x += p.vx;
      p.y += p.vy;
      p.vx *= 0.94; // Deceleration
      p.vy *= 0.94;

      if (p.life <= 0.0) {
        _trailParticles.removeAt(i);
      }
    }

    // 3. Emit new trail particles if active
    if (isEmittingTrails && _trailParticles.length < maxTrailParticles) {
      if (cyanHead != null && _random.nextDouble() < trailEmissionFactor) {
        _emitTrail(
          cyanHead.dx - center.dx,
          cyanHead.dy - center.dy,
          const Color(0xFF00D4FF),
        );
      }
      if (violetHead != null && _random.nextDouble() < trailEmissionFactor) {
        _emitTrail(
          violetHead.dx - center.dx,
          violetHead.dy - center.dy,
          const Color(0xFF7C4DFF),
        );
      }
    }
  }

  void _emitTrail(double rx, double ry, Color color) {
    if (_trailParticles.length >= maxTrailParticles) return;

    final spreadAngle = _random.nextDouble() * 2 * math.pi;
    final speed = 0.5 + _random.nextDouble() * 1.5;

    _trailParticles.add(
      SplashParticle(
        x: rx + (_random.nextDouble() - 0.5) * 10,
        y: ry + (_random.nextDouble() - 0.5) * 10,
        vx: math.cos(spreadAngle) * speed,
        vy: math.sin(spreadAngle) * speed,
        size: 1.2 + _random.nextDouble() * 1.6,
        baseColor: color,
        opacity: 0.5 + _random.nextDouble() * 0.3,
        life: 1.0,
        decayRate: 2.8 + _random.nextDouble() * 0.8, // ~300ms life
        isTrail: true,
      ),
    );
  }

  /// Draw all particles centered around [center].
  void paint(Canvas canvas, Offset center, double globalOpacity) {
    if (globalOpacity <= 0.001) return;

    final paint = Paint()..style = PaintingStyle.fill;

    // Ambient particles
    for (final p in _ambientParticles) {
      final alpha = (p.opacity * globalOpacity).clamp(0.0, 1.0);
      paint.color = p.baseColor.withValues(alpha: alpha);
      canvas.drawCircle(
        Offset(center.dx + p.x, center.dy + p.y),
        p.size,
        paint,
      );
    }

    // Trail particles
    for (final p in _trailParticles) {
      final trailOpacity = (p.opacity * p.life * globalOpacity).clamp(0.0, 1.0);
      paint.color = p.baseColor.withValues(alpha: trailOpacity);
      canvas.drawCircle(
        Offset(center.dx + p.x, center.dy + p.y),
        p.size * p.life,
        paint,
      );
    }
  }
}
