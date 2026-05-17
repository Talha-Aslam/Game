import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/family/family_achievement_model.dart';

/// Achievement card with progress bar
class FamilyAchievementCard extends StatelessWidget {
  final FamilyAchievement achievement;
  const FamilyAchievementCard({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    final color = achievement.isUnlocked ? AppColors.gold : AppColors.white30;
    return Container(
      margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),
        color: achievement.isUnlocked ? AppColors.gold.withValues(alpha: 0.05) : AppColors.white05,
        border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Row(children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(
          shape: BoxShape.circle, color: color.withValues(alpha: 0.12)),
          child: Icon(achievement.icon, color: color, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(achievement.title, style: TextStyle(
            color: color, fontSize: 13, fontWeight: FontWeight.w700)),
          Text(achievement.description, style: const TextStyle(
            color: AppColors.white30, fontSize: 10)),
          const SizedBox(height: 4),
          // Progress
          ClipRRect(borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: achievement.progressPercent, minHeight: 4,
              backgroundColor: AppColors.white05,
              color: achievement.isUnlocked ? AppColors.gold : AppColors.purpleNeon)),
          const SizedBox(height: 2),
          Text('${achievement.currentProgress}/${achievement.target}',
            style: const TextStyle(color: AppColors.white30, fontSize: 9)),
        ])),
        if (achievement.isUnlocked) const Padding(
          padding: EdgeInsets.only(left: 8),
          child: Icon(Icons.check_circle, color: AppColors.gold, size: 20)),
      ]),
    );
  }
}
