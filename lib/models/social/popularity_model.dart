import 'package:flutter/material.dart';
import 'friend_model.dart';

/// Popularity rank tiers
enum PopularityRank {
  risingStar,
  influencer,
  syndicateIcon,
  mafiaCelebrity,
  cityLegend;

  String get displayName {
    switch (this) {
      case PopularityRank.risingStar:
        return 'Rising Star';
      case PopularityRank.influencer:
        return 'Influencer';
      case PopularityRank.syndicateIcon:
        return 'Syndicate Icon';
      case PopularityRank.mafiaCelebrity:
        return 'Mafia Celebrity';
      case PopularityRank.cityLegend:
        return 'City Legend';
    }
  }

  Color get color {
    switch (this) {
      case PopularityRank.risingStar:
        return const Color(0xFFC0C0C0);
      case PopularityRank.influencer:
        return const Color(0xFF00E5FF);
      case PopularityRank.syndicateIcon:
        return const Color(0xFF9B59FF);
      case PopularityRank.mafiaCelebrity:
        return const Color(0xFFFFD700);
      case PopularityRank.cityLegend:
        return const Color(0xFFFF1744);
    }
  }

  IconData get icon {
    switch (this) {
      case PopularityRank.risingStar:
        return Icons.star_outline;
      case PopularityRank.influencer:
        return Icons.star_half;
      case PopularityRank.syndicateIcon:
        return Icons.star;
      case PopularityRank.mafiaCelebrity:
        return Icons.auto_awesome;
      case PopularityRank.cityLegend:
        return Icons.whatshot;
    }
  }

  int get minScore {
    switch (this) {
      case PopularityRank.risingStar:
        return 0;
      case PopularityRank.influencer:
        return 100;
      case PopularityRank.syndicateIcon:
        return 500;
      case PopularityRank.mafiaCelebrity:
        return 2000;
      case PopularityRank.cityLegend:
        return 5000;
    }
  }

  static PopularityRank fromScore(int score) {
    if (score >= 5000) return PopularityRank.cityLegend;
    if (score >= 2000) return PopularityRank.mafiaCelebrity;
    if (score >= 500) return PopularityRank.syndicateIcon;
    if (score >= 100) return PopularityRank.influencer;
    return PopularityRank.risingStar;
  }
}

/// Gift type for animated gift icons
enum GiftAnimationType {
  goldenRose,
  mafiaCrown,
  neonCoin,
  syndicateMedal,
  crimsonHeart,
  diamondCard;

  String get displayName {
    switch (this) {
      case GiftAnimationType.goldenRose:
        return 'Golden Rose';
      case GiftAnimationType.mafiaCrown:
        return 'Mafia Crown';
      case GiftAnimationType.neonCoin:
        return 'Neon Coin';
      case GiftAnimationType.syndicateMedal:
        return 'Syndicate Medal';
      case GiftAnimationType.crimsonHeart:
        return 'Crimson Heart';
      case GiftAnimationType.diamondCard:
        return 'Diamond Card';
    }
  }

  IconData get icon {
    switch (this) {
      case GiftAnimationType.goldenRose:
        return Icons.local_florist;
      case GiftAnimationType.mafiaCrown:
        return Icons.workspace_premium;
      case GiftAnimationType.neonCoin:
        return Icons.toll;
      case GiftAnimationType.syndicateMedal:
        return Icons.military_tech;
      case GiftAnimationType.crimsonHeart:
        return Icons.favorite;
      case GiftAnimationType.diamondCard:
        return Icons.diamond;
    }
  }

  Color get color {
    switch (this) {
      case GiftAnimationType.goldenRose:
        return const Color(0xFFFFD700);
      case GiftAnimationType.mafiaCrown:
        return const Color(0xFF9B59FF);
      case GiftAnimationType.neonCoin:
        return const Color(0xFF00E5FF);
      case GiftAnimationType.syndicateMedal:
        return const Color(0xFFFF9100);
      case GiftAnimationType.crimsonHeart:
        return const Color(0xFFFF1744);
      case GiftAnimationType.diamondCard:
        return const Color(0xFF00E5FF);
    }
  }
}

/// Popularity gift item
class PopularityGift {
  final String id;
  final String name;
  final GiftAnimationType animationType;
  final int value; // popularity points given
  final bool isPremium;
  final int cost; // syndicateCoins cost (0 for free)

  const PopularityGift({
    required this.id,
    required this.name,
    required this.animationType,
    required this.value,
    this.isPremium = false,
    this.cost = 0,
  });

  IconData get icon => animationType.icon;
  Color get color => animationType.color;

  /// All available gifts
  static const List<PopularityGift> allGifts = [
    // Free gifts
    PopularityGift(
      id: 'free_like',
      name: 'Like',
      animationType: GiftAnimationType.crimsonHeart,
      value: 1,
    ),
    PopularityGift(
      id: 'free_coin',
      name: 'Neon Coin',
      animationType: GiftAnimationType.neonCoin,
      value: 2,
    ),
    // Premium gifts
    PopularityGift(
      id: 'golden_rose',
      name: 'Golden Rose',
      animationType: GiftAnimationType.goldenRose,
      value: 10,
      isPremium: true,
      cost: 50,
    ),
    PopularityGift(
      id: 'mafia_crown',
      name: 'Mafia Crown',
      animationType: GiftAnimationType.mafiaCrown,
      value: 25,
      isPremium: true,
      cost: 100,
    ),
    PopularityGift(
      id: 'syndicate_medal',
      name: 'Syndicate Medal',
      animationType: GiftAnimationType.syndicateMedal,
      value: 50,
      isPremium: true,
      cost: 200,
    ),
    PopularityGift(
      id: 'diamond_card',
      name: 'Diamond Card',
      animationType: GiftAnimationType.diamondCard,
      value: 100,
      isPremium: true,
      cost: 500,
    ),
  ];

  static List<PopularityGift> get freeGifts =>
      allGifts.where((g) => !g.isPremium).toList();

  static List<PopularityGift> get premiumGifts =>
      allGifts.where((g) => g.isPremium).toList();
}

/// Gift transaction record
class GiftTransaction {
  final String id;
  final FriendModel fromUser;
  final FriendModel toUser;
  final PopularityGift gift;
  final DateTime timestamp;

  const GiftTransaction({
    required this.id,
    required this.fromUser,
    required this.toUser,
    required this.gift,
    required this.timestamp,
  });
}

/// User popularity profile
class PopularityProfile {
  final int totalScore;
  final PopularityRank rank;
  final int dailyFreeRemaining;
  final int dailyFreeMax;
  final List<FriendModel> topSupporters;
  final List<GiftTransaction> recentGifts;

  const PopularityProfile({
    this.totalScore = 0,
    this.rank = PopularityRank.risingStar,
    this.dailyFreeRemaining = 5,
    this.dailyFreeMax = 5,
    this.topSupporters = const [],
    this.recentGifts = const [],
  });

  double get progressToNextRank {
    final currentMin = rank.minScore;
    final nextRankIndex = PopularityRank.values.indexOf(rank) + 1;
    if (nextRankIndex >= PopularityRank.values.length) return 1.0;
    final nextMin = PopularityRank.values[nextRankIndex].minScore;
    final range = nextMin - currentMin;
    return ((totalScore - currentMin) / range).clamp(0.0, 1.0);
  }

  PopularityProfile copyWith({
    int? totalScore,
    PopularityRank? rank,
    int? dailyFreeRemaining,
    int? dailyFreeMax,
    List<FriendModel>? topSupporters,
    List<GiftTransaction>? recentGifts,
  }) {
    return PopularityProfile(
      totalScore: totalScore ?? this.totalScore,
      rank: rank ?? this.rank,
      dailyFreeRemaining: dailyFreeRemaining ?? this.dailyFreeRemaining,
      dailyFreeMax: dailyFreeMax ?? this.dailyFreeMax,
      topSupporters: topSupporters ?? this.topSupporters,
      recentGifts: recentGifts ?? this.recentGifts,
    );
  }
}
