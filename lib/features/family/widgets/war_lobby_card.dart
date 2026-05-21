import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/family/family_war_model.dart';

/// War lobby matchup card
class WarLobbyCard extends StatelessWidget {
  final FamilyWarModel war;
  final VoidCallback? onAction;
  const WarLobbyCard({super.key, required this.war, this.onAction});

  @override
  Widget build(BuildContext context) {
    final isCompleted = war.status == WarStatus.completed;
    return Container(
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(18),
        color: AppColors.crimsonRed.withValues(alpha: 0.04),
        border: Border.all(color: AppColors.crimsonRed.withValues(alpha: 0.2))),
      child: Column(children: [
        // VS header
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _TeamCol(war.challengerFamilyName, war.challengerFamilyTag, isCompleted ? war.challengerScore : null),
          Text('VS', style: TextStyle(color: AppColors.crimsonRed, fontSize: 18, fontWeight: FontWeight.w800)),
          _TeamCol(war.defenderFamilyName, war.defenderFamilyTag, isCompleted ? war.defenderScore : null),
        ]),
        const SizedBox(height: 10),
        // Status + format
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8), color: AppColors.white05),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Text('7v7', style: TextStyle(color: AppColors.crimsonRed, fontSize: 11, fontWeight: FontWeight.w700)),
            Text(war.status.displayName, style: TextStyle(
              color: war.status == WarStatus.active ? AppColors.online : AppColors.white50,
              fontSize: 11, fontWeight: FontWeight.w600)),
            Text('🏆 ${war.trophiesAtStake}', style: TextStyle(
              color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.w600)),
          ]),
        ),
        if (war.status == WarStatus.pending) ...[
          const SizedBox(height: 10),
          GestureDetector(onTap: onAction, child: Container(
            width: double.infinity, height: 36,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(colors: [AppColors.crimsonRed, AppColors.crimsonDeep])),
            child: const Center(child: Text('ACCEPT CHALLENGE',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 1))),
          )),
        ],
      ]),
    );
  }
}

class _TeamCol extends StatelessWidget {
  final String name; final String tag; final int? score;
  const _TeamCol(this.name, this.tag, this.score);
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(width: 44, height: 44, decoration: BoxDecoration(
        shape: BoxShape.circle, color: AppColors.purpleNeon.withValues(alpha: 0.12),
        border: Border.all(color: AppColors.purpleNeon.withValues(alpha: 0.3))),
        child: const Icon(Icons.groups, color: AppColors.purpleGlow, size: 22)),
      const SizedBox(height: 4),
      Text(tag, style: TextStyle(color: AppColors.purpleGlow, fontSize: 10, fontWeight: FontWeight.w700)),
      if (score != null) Text('$score', style: TextStyle(
        color: AppColors.gold, fontSize: 20, fontWeight: FontWeight.w800)),
    ]);
  }
}
