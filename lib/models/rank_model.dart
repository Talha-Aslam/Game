import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Rank tier model
class RankModel {
  final int tier;
  final String name;
  final int minPoints;
  final int maxPoints;
  final Color color;
  final Color glowColor;

  const RankModel({
    required this.tier,
    required this.name,
    required this.minPoints,
    required this.maxPoints,
    required this.color,
    required this.glowColor,
  });

  /// All rank tiers
  static const List<RankModel> allRanks = [
    RankModel(
      tier: 0,
      name: 'Bronze',
      minPoints: 0,
      maxPoints: 999,
      color: Color(0xFFCD7F32),
      glowColor: Color(0x66CD7F32),
    ),
    RankModel(
      tier: 1,
      name: 'Silver',
      minPoints: 1000,
      maxPoints: 2499,
      color: Color(0xFFC0C0C0),
      glowColor: Color(0x66C0C0C0),
    ),
    RankModel(
      tier: 2,
      name: 'Gold',
      minPoints: 2500,
      maxPoints: 4999,
      color: Color(0xFFFFD700),
      glowColor: Color(0x66FFD700),
    ),
    RankModel(
      tier: 3,
      name: 'Diamond',
      minPoints: 5000,
      maxPoints: 9999,
      color: Color(0xFF00E5FF),
      glowColor: Color(0x6600E5FF),
    ),
    RankModel(
      tier: 4,
      name: 'Syndicate Boss',
      minPoints: 10000,
      maxPoints: 99999,
      color: AppColors.purpleNeon,
      glowColor: Color(0x669B59FF),
    ),
  ];

  static RankModel fromTier(int tier) {
    return allRanks[tier.clamp(0, allRanks.length - 1)];
  }

  static RankModel fromPoints(int points) {
    for (int i = allRanks.length - 1; i >= 0; i--) {
      if (points >= allRanks[i].minPoints) return allRanks[i];
    }
    return allRanks[0];
  }

  double progressToNext(int currentPoints) {
    if (tier >= allRanks.length - 1) return 1.0;
    final range = maxPoints - minPoints;
    return ((currentPoints - minPoints) / range).clamp(0.0, 1.0);
  }
}
