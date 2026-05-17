import 'package:flutter/material.dart';
import '../../../models/battle_pass_model.dart';

/// Colored rarity badge
class RewardRarityBadge extends StatelessWidget {
  final RewardRarity rarity;
  const RewardRarityBadge({super.key, required this.rarity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: rarity.color.withValues(alpha: 0.12),
        border: Border.all(color: rarity.color.withValues(alpha: 0.3)),
      ),
      child: Text(rarity.displayName.toUpperCase(), style: TextStyle(
        color: rarity.color, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1)),
    );
  }
}
