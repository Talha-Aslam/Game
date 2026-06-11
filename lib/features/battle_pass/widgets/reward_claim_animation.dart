import 'dart:math';
import 'package:flutter/material.dart';
import '../../../models/battle_pass_model.dart';
import '../../../core/theme/app_colors.dart';

/// Claim reward explosion animation overlay
class RewardClaimAnimation extends StatefulWidget {
  final BattlePassReward reward;
  final VoidCallback? onComplete;

  const RewardClaimAnimation({super.key, required this.reward, this.onComplete});

  static void play(BuildContext context, {required BattlePassReward reward, VoidCallback? onComplete}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(builder: (_) => RewardClaimAnimation(
      reward: reward,
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
    for (int i = 0; i < 40; i++) {
      _particles.add(_Particle(
        angle: _rng.nextDouble() * 2 * pi,
        speed: 100 + _rng.nextDouble() * 300,
        size: 4 + _rng.nextDouble() * 8,
        color: i % 2 == 0 ? widget.reward.rarity.color : widget.reward.rarity.glowColor,
      ));
    }
    _ctrl = AnimationController(duration: const Duration(milliseconds: 2500), vsync: this)
      ..addStatusListener((s) { if (s == AnimationStatus.completed) widget.onComplete?.call(); })
      ..forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return AnimatedBuilder(animation: _ctrl, builder: (_, _) {
      final t = _ctrl.value;
      // Burst phase (0 to 0.3)
      final burst = (t / 0.3).clamp(0.0, 1.0);
      // Hold phase (0.3 to 0.8)
      // Fade phase (0.8 to 1.0)
      final fade = ((1.0 - t) / 0.2).clamp(0.0, 1.0);
      
      final opacity = t < 0.8 ? 1.0 : fade;
      final scale = 0.5 + Curves.easeOutBack.transform(burst) * 0.5;

      return IgnorePointer(
        ignoring: false, // Let user tap to skip if wanted (future)
        child: Stack(children: [
          // Dark background overlay
          Positioned.fill(
            child: Opacity(
              opacity: (burst * 0.8) * opacity,
              child: Container(color: Colors.black),
            ),
          ),
          // Glow burst
          Positioned(
            left: size.width / 2 - 150, top: size.height / 2 - 150,
            child: Opacity(
              opacity: (1.0 - burst) * 0.8, // Initial flash
              child: Container(
                width: 300, height: 300,
                decoration: BoxDecoration(shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    widget.reward.rarity.color.withValues(alpha: 0.8),
                    widget.reward.rarity.color.withValues(alpha: 0.0),
                  ])),
              ),
            ),
          ),
          // Ambient Glow behind card
          Positioned(
            left: size.width / 2 - 100, top: size.height / 2 - 100,
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: 200, height: 200,
                decoration: BoxDecoration(shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: widget.reward.rarity.glowColor.withValues(alpha: 0.5), blurRadius: 100)]),
              ),
            ),
          ),
          // Particles
          ...(_particles.map((p) {
            final dx = size.width / 2 + cos(p.angle) * p.speed * burst;
            final dy = size.height / 2 + sin(p.angle) * p.speed * burst;
            return Positioned(
              left: dx - p.size / 2, top: dy - p.size / 2,
              child: Opacity(
                opacity: opacity * (1.0 - burst * 0.5),
                child: Container(
                  width: p.size, height: p.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, color: p.color,
                    boxShadow: [BoxShadow(color: p.color.withValues(alpha: 0.8), blurRadius: 4)],
                  )
                ),
              ),
            );
          })),
          // Central Reward Card
          Positioned(
            left: size.width / 2 - 100,
            top: size.height / 2 - 120,
            child: Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: 200,
                  height: 240,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [
                        widget.reward.rarity.color.withValues(alpha: 0.8),
                        AppColors.surface,
                      ],
                    ),
                    border: Border.all(color: widget.reward.rarity.color, width: 2),
                    boxShadow: [
                      BoxShadow(color: widget.reward.rarity.glowColor.withValues(alpha: 0.4), blurRadius: 20)
                    ]
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(widget.reward.type.icon, size: 64, color: widget.reward.rarity.color),
                      const SizedBox(height: 16),
                      Text(widget.reward.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
                      ),
                      const SizedBox(height: 8),
                      Text(widget.reward.rarity.displayName,
                        style: TextStyle(color: widget.reward.rarity.color, fontSize: 14, fontWeight: FontWeight.w600)
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ]),
      );
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
