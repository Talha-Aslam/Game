import 'package:flutter_riverpod/flutter_riverpod.dart';

class RankingEntry {
  final int position;
  final String username;
  final String avatarUrl;
  final int rankTier;
  final int points;
  final String? familyTag;

  const RankingEntry({
    required this.position,
    required this.username,
    this.avatarUrl = '',
    required this.rankTier,
    required this.points,
    this.familyTag,
  });
}

final leaderboardProvider = Provider<List<RankingEntry>>((ref) {
  return const [
    RankingEntry(position: 1, username: 'DarkOracle', rankTier: 4, points: 15200, familyTag: '[SHADOW]'),
    RankingEntry(position: 2, username: 'SilverBlade', rankTier: 4, points: 14800, familyTag: '[COBRA]'),
    RankingEntry(position: 3, username: 'CrimsonEye', rankTier: 4, points: 13900),
    RankingEntry(position: 4, username: 'VoidWalker', rankTier: 3, points: 9800, familyTag: '[VENOM]'),
    RankingEntry(position: 5, username: 'NeonWraith', rankTier: 3, points: 8700),
    RankingEntry(position: 6, username: 'ShadowKing', rankTier: 2, points: 3200, familyTag: '[COBRA]'),
    RankingEntry(position: 7, username: 'PhantomAce', rankTier: 2, points: 2900),
    RankingEntry(position: 8, username: 'IronJaw', rankTier: 1, points: 1800, familyTag: '[STEEL]'),
    RankingEntry(position: 9, username: 'MidnightRose', rankTier: 1, points: 1500),
    RankingEntry(position: 10, username: 'BlazeFury', rankTier: 0, points: 900),
  ];
});
