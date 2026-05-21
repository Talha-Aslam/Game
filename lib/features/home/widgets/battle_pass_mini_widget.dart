import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/battle_pass_provider.dart';

/// Dynamic Battle Pass mini-widget (top-right) with tier, XP, countdown, FOMO
class BattlePassMiniWidget extends ConsumerStatefulWidget {
  const BattlePassMiniWidget({super.key});
  @override
  ConsumerState<BattlePassMiniWidget> createState() => _BattlePassMiniWidgetState();
}

class _BattlePassMiniWidgetState extends ConsumerState<BattlePassMiniWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmer;
  late Timer _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(duration: const Duration(seconds: 3), vsync: this)..repeat();
    _updateTimer();
    _timer = Timer.periodic(const Duration(seconds: 60), (_) => _updateTimer());
  }

  void _updateTimer() {
    final bp = ref.read(battlePassProvider);
    setState(() => _remaining = bp.timeRemaining);
  }

  @override
  void dispose() { _shimmer.dispose(); _timer.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final bp = ref.watch(battlePassProvider);
    final xpToNext = bp.xpToNextTier - bp.currentXP;
    final isClose = xpToNext < 300; // FOMO trigger

    return GestureDetector(
      onTap: () => context.push('/battle-pass'),
      child: AnimatedBuilder(animation: _shimmer, builder: (_, __) {
        final s = _shimmer.value;
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              width: 140, padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: isClose
                    ? AppColors.gold.withValues(alpha: 0.04 + s * 0.03)
                    : AppColors.white05,
                border: Border.all(color: isClose
                    ? AppColors.gold.withValues(alpha: 0.3 + s * 0.15)
                    : AppColors.glassBorder, width: 0.5),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Tier + Premium badge
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(5),
                      gradient: const LinearGradient(colors: [AppColors.gold, Color(0xFFFF8F00)])),
                    child: Text('T${bp.currentTier}', style: const TextStyle(
                      color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                  ),
                  const SizedBox(width: 4),
                  if (bp.isPremium) const Text('⭐', style: TextStyle(fontSize: 10)),
                  const Spacer(),
                  // Countdown
                  Text('${_remaining.inDays}d', style: TextStyle(
                    color: _remaining.inDays < 3 ? AppColors.crimsonRed : AppColors.white30,
                    fontSize: 8, fontWeight: FontWeight.w600)),
                ]),
                const SizedBox(height: 4),
                // XP Progress bar
                Container(height: 4, decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2), color: AppColors.white05),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: bp.progress.clamp(0.0, 1.0),
                    child: Container(decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: LinearGradient(colors: isClose
                          ? [AppColors.gold, const Color(0xFFFF8F00)]
                          : [AppColors.purpleNeon, AppColors.purpleDeep]),
                      boxShadow: isClose ? [BoxShadow(color: AppColors.gold.withValues(alpha: 0.4), blurRadius: 4)] : null)),
                  ),
                ),
                const SizedBox(height: 3),
                // FOMO text
                Text(
                  isClose ? '⚡ ${xpToNext} XP to reward!' : 'BATTLE PASS',
                  style: TextStyle(
                    color: isClose ? AppColors.gold : AppColors.white30,
                    fontSize: 8, fontWeight: isClose ? FontWeight.w700 : FontWeight.w500),
                ),
              ]),
            ),
          ),
        );
      }),
    );
  }
}
