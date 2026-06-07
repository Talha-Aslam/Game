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
  ConsumerState<BattlePassMiniWidget> createState() =>
      _BattlePassMiniWidgetState();
}

class _BattlePassMiniWidgetState extends ConsumerState<BattlePassMiniWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmer;
  late Timer _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    _updateTimer();
    _timer = Timer.periodic(const Duration(seconds: 60), (_) => _updateTimer());
  }

  void _updateTimer() {
    final bp = ref.read(battlePassProvider);
    setState(() => _remaining = bp.timeRemaining);
  }

  @override
  void dispose() {
    _shimmer.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bp = ref.watch(battlePassProvider);
    final xpToNext = bp.xpToNextTier - bp.currentXP;
    final isClose = xpToNext < 300; // FOMO trigger

    return GestureDetector(
      onTap: () => context.push('/battle-pass'),
      child: AnimatedBuilder(
        animation: _shimmer,
        builder: (_, _) {
          final s = _shimmer.value;
          return ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: 140,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: isClose
                      ? AppColors.gold.withValues(alpha: 0.04 + s * 0.03)
                      : Colors.white.withValues(alpha: 0.02),
                  border: Border.all(
                    color: isClose
                        ? AppColors.gold.withValues(alpha: 0.3 + s * 0.15)
                        : Colors.white.withValues(alpha: 0.15),
                    width: 0.8,
                  ),
                ),
                child: Stack(
                  children: [
                    // Texture Layer
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.03,
                        child: CustomPaint(painter: _MeshPainter()),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tier + Premium badge
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                gradient: const LinearGradient(
                                  colors: [AppColors.purpleDeep, AppColors.purpleNeon],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.purpleNeon.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'T${bp.currentTier}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  if (bp.isPremium) ...[
                                    const SizedBox(width: 2),
                                    const Icon(
                                      Icons.auto_awesome,
                                      color: Colors.white,
                                      size: 8,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const Spacer(),
                            // Countdown with Icon
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.timer_sharp,
                                  size: 10,
                                  color: _remaining.inDays < 3
                                      ? AppColors.crimsonRed
                                      : AppColors.white30,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${_remaining.inDays}d',
                                  style: TextStyle(
                                    color: _remaining.inDays < 3
                                        ? AppColors.crimsonRed
                                        : AppColors.white30,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // XP Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            height: 5,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: Colors.black38,
                            ),
                            child: Stack(
                              children: [
                                FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: bp.progress.clamp(0.0, 1.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: isClose
                                            ? [AppColors.gold, const Color(0xFFFF8F00)]
                                            : [
                                                AppColors.purpleNeon,
                                                AppColors.purpleDeep,
                                              ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (isClose ? AppColors.gold : AppColors.purpleNeon)
                                              .withValues(alpha: 0.5),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // FOMO text
                        Text(
                          isClose ? '⚡ $xpToNext XP TO REWARD' : 'BATTLE PASS',
                          style: TextStyle(
                            color: isClose ? AppColors.gold : AppColors.white30,
                            fontSize: 8,
                            fontWeight: isClose ? FontWeight.w900 : FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MeshPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 1.0;
    
    for (double i = -size.height; i < size.width; i += 8) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}