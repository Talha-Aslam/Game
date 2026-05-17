import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Animated XP progress bar with boost indicator and tier markers
class XPProgressBar extends StatelessWidget {
  final int currentXP;
  final int maxXP;
  final int currentTier;
  final bool hasBoost;
  final Color color;

  const XPProgressBar({
    super.key, required this.currentXP, required this.maxXP,
    required this.currentTier, this.hasBoost = false,
    this.color = AppColors.gold,
  });

  @override
  Widget build(BuildContext context) {
    final progress = maxXP > 0 ? (currentXP / maxXP).clamp(0.0, 1.0) : 0.0;
    final barColor = hasBoost ? AppColors.mintGreen : color;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          Text('Tier $currentTier', style: TextStyle(
            color: barColor, fontSize: 12, fontWeight: FontWeight.w700)),
          if (hasBoost) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(4),
                color: AppColors.mintGreen.withValues(alpha: 0.15)),
              child: const Text('2X XP', style: TextStyle(
                color: AppColors.mintGreen, fontSize: 8, fontWeight: FontWeight.w800))),
          ],
        ]),
        Text('$currentXP / $maxXP XP', style: const TextStyle(
          color: AppColors.white30, fontSize: 10)),
      ]),
      const SizedBox(height: 6),
      Container(height: 8, decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4), color: AppColors.white05,
        border: Border.all(color: AppColors.glassBorder)),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft, widthFactor: progress,
          child: Container(decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(colors: [barColor, barColor.withValues(alpha: 0.6)]),
            boxShadow: [BoxShadow(color: barColor.withValues(alpha: 0.4), blurRadius: 6)])),
        )),
    ]);
  }
}
