import 'package:flutter/material.dart';

/// Family boost types
enum FamilyBoostType {
  influenceBonus,
  battlePassXP,
  matchmakingSpeed,
  familyXPDouble;

  String get displayName {
    switch (this) {
      case FamilyBoostType.influenceBonus:
        return '+10% Influence Earned';
      case FamilyBoostType.battlePassXP:
        return '+15% Battle Pass XP';
      case FamilyBoostType.matchmakingSpeed:
        return 'Fast Matchmaking';
      case FamilyBoostType.familyXPDouble:
        return 'Double Family XP';
    }
  }

  IconData get icon {
    switch (this) {
      case FamilyBoostType.influenceBonus:
        return Icons.trending_up;
      case FamilyBoostType.battlePassXP:
        return Icons.auto_awesome;
      case FamilyBoostType.matchmakingSpeed:
        return Icons.speed;
      case FamilyBoostType.familyXPDouble:
        return Icons.bolt;
    }
  }

  Color get color {
    switch (this) {
      case FamilyBoostType.influenceBonus:
        return const Color(0xFF00E5FF);
      case FamilyBoostType.battlePassXP:
        return const Color(0xFFFFD700);
      case FamilyBoostType.matchmakingSpeed:
        return const Color(0xFF00F5A0);
      case FamilyBoostType.familyXPDouble:
        return const Color(0xFF9B59FF);
    }
  }

  int get cost {
    switch (this) {
      case FamilyBoostType.influenceBonus:
        return 500;
      case FamilyBoostType.battlePassXP:
        return 750;
      case FamilyBoostType.matchmakingSpeed:
        return 300;
      case FamilyBoostType.familyXPDouble:
        return 1000;
    }
  }

  /// All boosts last 24 hours
  Duration get duration => const Duration(hours: 24);
}

/// Active boost instance
class FamilyBoost {
  final String id;
  final FamilyBoostType type;
  final DateTime activatedAt;
  final DateTime expiresAt;
  final String activatedBy;

  const FamilyBoost({
    required this.id,
    required this.type,
    required this.activatedAt,
    required this.expiresAt,
    required this.activatedBy,
  });

  bool get isActive => DateTime.now().isBefore(expiresAt);

  Duration get remainingDuration {
    final remaining = expiresAt.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  String get remainingText {
    final d = remainingDuration;
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m';
    if (d.inMinutes > 0) return '${d.inMinutes}m';
    return 'Expired';
  }
}

/// Treasury donation record
class TreasuryDonation {
  final String id;
  final String userId;
  final String username;
  final int amount;
  final DateTime timestamp;

  const TreasuryDonation({
    required this.id,
    required this.userId,
    required this.username,
    required this.amount,
    required this.timestamp,
  });
}

/// Top contributor entry
class TreasuryContributor {
  final String userId;
  final String username;
  final int totalDonated;

  const TreasuryContributor({
    required this.userId,
    required this.username,
    required this.totalDonated,
  });
}

/// Family treasury state
class FamilyTreasury {
  final int balance;
  final List<FamilyBoost> activeBoosts;
  final List<TreasuryDonation> recentDonations;
  final List<TreasuryContributor> topContributors;

  const FamilyTreasury({
    this.balance = 0,
    this.activeBoosts = const [],
    this.recentDonations = const [],
    this.topContributors = const [],
  });

  List<FamilyBoost> get currentActiveBoosts =>
      activeBoosts.where((b) => b.isActive).toList();

  FamilyTreasury copyWith({
    int? balance,
    List<FamilyBoost>? activeBoosts,
    List<TreasuryDonation>? recentDonations,
    List<TreasuryContributor>? topContributors,
  }) {
    return FamilyTreasury(
      balance: balance ?? this.balance,
      activeBoosts: activeBoosts ?? this.activeBoosts,
      recentDonations: recentDonations ?? this.recentDonations,
      topContributors: topContributors ?? this.topContributors,
    );
  }
}
