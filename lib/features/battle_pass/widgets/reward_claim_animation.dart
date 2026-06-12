import 'package:flutter/material.dart';
import '../../../models/battle_pass_model.dart';
import '../../../core/theme/app_colors.dart';

/// Claim reward animation overlay
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
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(duration: const Duration(milliseconds: 600), vsync: this)
      ..forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _dismiss() {
    if (_isDismissing) return;
    _isDismissing = true;
    _ctrl.reverse().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: _dismiss,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(animation: _ctrl, builder: (_, _) {
          final t = _ctrl.value;
          final opacity = t.clamp(0.0, 1.0);
          final scale = 0.8 + Curves.easeOutBack.transform(t) * 0.2;

          return Stack(children: [
            // Dark background overlay
            Positioned.fill(
              child: Opacity(
                opacity: (t * 0.8).clamp(0.0, 1.0),
                child: Container(color: Colors.black),
              ),
            ),
            // Ambient Glow behind card
            Center(
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: 300, height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.reward.rarity.glowColor.withValues(alpha: 0.3 * opacity), 
                        blurRadius: 100,
                        spreadRadius: 20
                      )
                    ]
                  ),
                ),
              ),
            ),
            // Central Reward Card
            Center(
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: 220,
                    height: 280,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                        colors: [
                          widget.reward.rarity.color.withValues(alpha: 0.9),
                          AppColors.surface,
                        ],
                      ),
                      border: Border.all(color: widget.reward.rarity.color, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: widget.reward.rarity.glowColor.withValues(alpha: 0.5 * opacity), 
                          blurRadius: 30,
                          offset: const Offset(0, 10)
                        )
                      ]
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(widget.reward.type.icon, size: 72, color: widget.reward.rarity.color),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(widget.reward.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: widget.reward.rarity.color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: widget.reward.rarity.color.withValues(alpha: 0.5)),
                          ),
                          child: Text(widget.reward.rarity.displayName.toUpperCase(),
                            style: TextStyle(color: widget.reward.rarity.color, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1)
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Tap to continue
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: opacity,
                child: const Text(
                  'Tap anywhere to continue',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ]);
        }),
      ),
    );
  }
}
