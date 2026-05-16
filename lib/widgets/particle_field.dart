import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Animated particle field background
class ParticleField extends StatefulWidget {
  final int particleCount;
  final Color particleColor;
  final Widget? child;

  const ParticleField({
    super.key,
    this.particleCount = 40,
    this.particleColor = AppColors.purpleNeon,
    this.child,
  });

  @override
  State<ParticleField> createState() => _ParticleFieldState();
}

class _ParticleFieldState extends State<ParticleField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    _particles = List.generate(
      widget.particleCount,
      (_) => _Particle.random(widget.particleColor),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              size: Size.infinite,
              painter: _ParticlePainter(
                particles: _particles,
                progress: _controller.value,
              ),
            );
          },
        ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class _Particle {
  double x, y, size, speed, opacity;
  Color color;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.color,
  });

  factory _Particle.random(Color baseColor) {
    final rng = Random();
    return _Particle(
      x: rng.nextDouble(),
      y: rng.nextDouble(),
      size: rng.nextDouble() * 3 + 0.5,
      speed: rng.nextDouble() * 0.3 + 0.1,
      opacity: rng.nextDouble() * 0.4 + 0.1,
      color: baseColor,
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final y = (p.y + progress * p.speed) % 1.0;
      final x = p.x + sin(progress * pi * 2 + p.y * pi) * 0.02;

      final paint = Paint()
        ..color = p.color.withValues(alpha: p.opacity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.size);

      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) => true;
}
