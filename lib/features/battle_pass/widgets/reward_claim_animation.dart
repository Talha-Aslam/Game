import 'dart:math';
import 'package:flutter/material.dart';
import '../../../models/battle_pass_model.dart';

/// Claim reward explosion animation overlay
class RewardClaimAnimation extends StatefulWidget {
  final RewardRarity rarity;
  final VoidCallback? onComplete;

  const RewardClaimAnimation({super.key, required this.rarity, this.onComplete});

  static void play(BuildContext context, {required RewardRarity rarity, VoidCallback? onComplete}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(builder: (_) => RewardClaimAnimation(
      rarity: rarity,
      onComplete: () { entry.remove(); onComplete?.call(); },
    ));
    overlay.insert(entry);
  }

  @override
  State<RewardClaimAnimation> createState() => _RewardClaimAnimationState();
}

class _RewardClaimAnimationState extends State<RewardClaimAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  final _particles = <_Particle>[];
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    // Generate particles
    for (int i = 0; i < 20; i++) {
      _particles.add(_Particle(
        angle: _rng.nextDouble() * 2 * pi,
        speed: 80 + _rng.nextDouble() * 200,
        size: 3 + _rng.nextDouble() * 5,
        color: i % 2 == 0 ? widget.rarity.color : widget.rarity.glowColor,
      ));
    }
    _ctrl = AnimationController(duration: const Duration(milliseconds: 800), vsync: this)
      ..addStatusListener((s) { if (s == AnimationStatus.completed) widget.onComplete?.call(); })
      ..forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnimatedBuilder(animation: _ctrl, builder: (_, __) {
      final t = _ctrl.value;
      final opacity = (1.0 - t).clamp(0.0, 1.0);
      return IgnorePointer(child: Stack(children: [
        // Glow burst
        Positioned(
          left: size.width / 2 - 60, top: size.height / 2 - 60,
          child: Opacity(opacity: opacity, child: Container(
            width: 120 + t * 100, height: 120 + t * 100,
            decoration: BoxDecoration(shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                widget.rarity.color.withValues(alpha: 0.4 * opacity),
                widget.rarity.color.withValues(alpha: 0.0),
              ])),
          )),
        ),
        // Particles
        ...(_particles.map((p) {
          final dx = size.width / 2 + cos(p.angle) * p.speed * t;
          final dy = size.height / 2 + sin(p.angle) * p.speed * t;
          return Positioned(
            left: dx - p.size / 2, top: dy - p.size / 2,
            child: Opacity(opacity: opacity, child: Container(
              width: p.size, height: p.size,
              decoration: BoxDecoration(shape: BoxShape.circle, color: p.color))),
          );
        })),
      ]));
    });
  }
}

class _Particle {
  final double angle;
  final double speed;
  final double size;
  final Color color;
  _Particle({required this.angle, required this.speed, required this.size, required this.color});
}
