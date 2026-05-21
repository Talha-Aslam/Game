import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/family/family_war_model.dart';

/// Rivalry record card
class RivalryHistoryCard extends StatelessWidget {
  final RivalryRecord rivalry;
  const RivalryHistoryCard({super.key, required this.rivalry});

  @override
  Widget build(BuildContext context) {
    final isWinning = rivalry.wins > rivalry.losses;
    return Container(
      margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
        color: AppColors.white05, border: Border.all(color: AppColors.glassBorder)),
      child: Row(children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(
          shape: BoxShape.circle, color: AppColors.purpleNeon.withValues(alpha: 0.12)),
          child: const Icon(Icons.groups, color: AppColors.purpleGlow, size: 18)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(rivalry.rivalFamilyName, style: const TextStyle(
            color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          Text(rivalry.rivalFamilyTag, style: const TextStyle(color: AppColors.white30, fontSize: 10)),
        ])),
        Column(children: [
          Text('${rivalry.wins}W - ${rivalry.losses}L', style: TextStyle(
            color: isWinning ? AppColors.online : AppColors.crimsonRed,
            fontSize: 12, fontWeight: FontWeight.w700)),
          Text('${rivalry.totalMatches} matches', style: const TextStyle(
            color: AppColors.white30, fontSize: 9)),
        ]),
      ]),
    );
  }
}
