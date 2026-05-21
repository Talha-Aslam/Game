import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Animated XP progress bar with level and glow
class FamilyLevelProgressBar extends StatelessWidget {
  final int level;
  final int currentXP;
  final int xpToNextLevel;
  final Color color;

  const FamilyLevelProgressBar({
    super.key, required this.level, required this.currentXP,
    required this.xpToNextLevel, this.color = AppColors.purpleNeon,
  });

  @override
  Widget build(BuildContext context) {
    final progress = xpToNextLevel > 0 ? (currentXP / xpToNextLevel).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Level $level', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
          Text('$currentXP / $xpToNextLevel XP',
            style: const TextStyle(color: AppColors.white30, fontSize: 10)),
        ]),
        const SizedBox(height: 6),
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4), color: AppColors.white05,
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft, widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.6)]),
                boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 6)],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
