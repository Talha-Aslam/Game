import 'package:flutter/material.dart';
import '../models/rank_model.dart';

class RankBadge extends StatelessWidget {
  final int tier;
  final double size;
  final bool showLabel;

  const RankBadge({super.key, required this.tier, this.size = 32, this.showLabel = true});

  @override
  Widget build(BuildContext context) {
    final rank = RankModel.fromTier(tier);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size, height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [rank.color, rank.color.withValues(alpha: 0.6)]),
            boxShadow: [BoxShadow(color: rank.glowColor, blurRadius: 10, spreadRadius: 1)],
            border: Border.all(color: rank.color.withValues(alpha: 0.8), width: 1.5),
          ),
          child: Icon(_rankIcon(tier), color: Colors.white, size: size * 0.5),
        ),
        if (showLabel) ...[
          const SizedBox(height: 4),
          Text(rank.name, style: TextStyle(color: rank.color, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ],
    );
  }

  IconData _rankIcon(int tier) {
    switch (tier) {
      case 0: return Icons.shield_outlined;
      case 1: return Icons.shield;
      case 2: return Icons.military_tech;
      case 3: return Icons.diamond;
      case 4: return Icons.workspace_premium;
      default: return Icons.shield_outlined;
    }
  }
}
