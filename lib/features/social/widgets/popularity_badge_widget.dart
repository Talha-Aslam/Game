import 'package:flutter/material.dart';
import '../../../models/social/popularity_model.dart';

/// Popularity rank badge with glow effect
class PopularityBadgeWidget extends StatelessWidget {
  final int score;
  final double size;
  final bool showScore;
  final bool compact;

  const PopularityBadgeWidget({
    super.key,
    required this.score,
    this.size = 32,
    this.showScore = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final rank = PopularityRank.fromScore(score);
    final color = rank.color;

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: color.withValues(alpha: 0.15),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(rank.icon, color: color, size: 12),
            const SizedBox(width: 3),
            Text(
              _formatScore(score),
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 12,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.6)],
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(rank.icon, color: Colors.white, size: size * 0.55),
          ),
          if (showScore) ...[
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  rank.displayName,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  _formatScore(score),
                  style: TextStyle(
                    color: color.withValues(alpha: 0.7),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatScore(int s) {
    if (s >= 10000) return '${(s / 1000).toStringAsFixed(1)}K';
    if (s >= 1000) return '${(s / 1000).toStringAsFixed(1)}K';
    return '$s';
  }
}
