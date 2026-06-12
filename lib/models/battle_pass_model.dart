import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════════
//  REWARD RARITY
// ══════════════════════════════════════════════════════════════════

enum RewardRarity {
  common,
  rare,
  epic,
  legendary;

  String get displayName {
    switch (this) {
      case RewardRarity.common: return 'Common';
      case RewardRarity.rare: return 'Rare';
      case RewardRarity.epic: return 'Epic';
      case RewardRarity.legendary: return 'Legendary';
    }
  }

  Color get color {
    switch (this) {
      case RewardRarity.common: return const Color(0xFF00E5FF);
      case RewardRarity.rare: return const Color(0xFF9B59FF);
      case RewardRarity.epic: return const Color(0xFFFFD700);
      case RewardRarity.legendary: return const Color(0xFFFF1744);
    }
  }

  Color get glowColor {
    switch (this) {
      case RewardRarity.common: return const Color(0xFF00E5FF);
      case RewardRarity.rare: return const Color(0xFF9B59FF);
      case RewardRarity.epic: return const Color(0xFFFFD700);
      case RewardRarity.legendary: return const Color(0xFFFF6D00);
    }
  }
}

// ══════════════════════════════════════════════════════════════════
//  REWARD TYPE
// ══════════════════════════════════════════════════════════════════

enum RewardType {
  cardStyle,
  animatedBorder,
  eliminationFX,
  popularityGift,
  voicePack,
  nameplate,
  avatar,
  familyCrestFX,
  xpBoostToken,
  syndicateCoins,
  influencePoints,
  profileBackground,
  title;

  String get displayName {
    switch (this) {
      case RewardType.cardStyle: return 'Card Style';
      case RewardType.animatedBorder: return 'Animated Border';
      case RewardType.eliminationFX: return 'Elimination FX';
      case RewardType.popularityGift: return 'Popularity Gift';
      case RewardType.voicePack: return 'Voice Pack';
      case RewardType.nameplate: return 'Nameplate';
      case RewardType.avatar: return 'Avatar';
      case RewardType.familyCrestFX: return 'Family Crest FX';
      case RewardType.xpBoostToken: return 'XP Boost Token';
      case RewardType.syndicateCoins: return 'Syndicate Coins';
      case RewardType.influencePoints: return 'Influence Points';
      case RewardType.profileBackground: return 'Profile Background';
      case RewardType.title: return 'Title';
    }
  }

  IconData get icon {
    switch (this) {
      case RewardType.cardStyle: return Icons.style;
      case RewardType.animatedBorder: return Icons.auto_awesome;
      case RewardType.eliminationFX: return Icons.whatshot;
      case RewardType.popularityGift: return Icons.card_giftcard;
      case RewardType.voicePack: return Icons.record_voice_over;
      case RewardType.nameplate: return Icons.badge;
      case RewardType.avatar: return Icons.face;
      case RewardType.familyCrestFX: return Icons.shield;
      case RewardType.xpBoostToken: return Icons.bolt;
      case RewardType.syndicateCoins: return Icons.monetization_on;
      case RewardType.influencePoints: return Icons.trending_up;
      case RewardType.profileBackground: return Icons.wallpaper;
      case RewardType.title: return Icons.workspace_premium;
    }
  }

  String get previewHint {
    switch (this) {
      case RewardType.eliminationFX: return 'Tap to preview animation';
      case RewardType.animatedBorder: return 'Tap to preview border effect';
      case RewardType.voicePack: return 'Tap to hear audio preview';
      case RewardType.profileBackground: return 'Tap to preview background';
      default: return '';
    }
  }
}

// ══════════════════════════════════════════════════════════════════
//  CLAIM STATE
// ══════════════════════════════════════════════════════════════════

enum ClaimState {
  locked,
  unlockable,
  claimed,
  premiumLocked;
}

// ══════════════════════════════════════════════════════════════════
//  REWARD
// ══════════════════════════════════════════════════════════════════

class BattlePassReward {
  final String id;
  final String name;
  final String description;
  final RewardType type;
  final RewardRarity rarity;
  final bool isPremiumExclusive;
  final int? currencyAmount;

  const BattlePassReward({
    required this.id,
    required this.name,
    this.description = '',
    required this.type,
    this.rarity = RewardRarity.common,
    this.isPremiumExclusive = false,
    this.currencyAmount,
  });
}

// ══════════════════════════════════════════════════════════════════
//  TIER
// ══════════════════════════════════════════════════════════════════

class BattlePassTier {
  final int tier;
  final BattlePassReward freeReward;
  final BattlePassReward? premiumReward;
  final bool isUnlocked;
  final bool isFreeClaimed;
  final bool isPremiumClaimed;

  const BattlePassTier({
    required this.tier,
    required this.freeReward,
    this.premiumReward,
    this.isUnlocked = false,
    this.isFreeClaimed = false,
    this.isPremiumClaimed = false,
  });

  /// For backward compat
  bool get isClaimed => isFreeClaimed;

  ClaimState freeClaimState() {
    if (isFreeClaimed) return ClaimState.claimed;
    if (isUnlocked) return ClaimState.unlockable;
    return ClaimState.locked;
  }

  ClaimState premiumClaimState(bool hasPremium) {
    if (premiumReward == null) return ClaimState.locked;
    if (isPremiumClaimed) return ClaimState.claimed;
    if (!hasPremium) return ClaimState.premiumLocked;
    if (isUnlocked) return ClaimState.unlockable;
    return ClaimState.locked;
  }

  BattlePassTier copyWith({
    bool? isUnlocked,
    bool? isFreeClaimed,
    bool? isPremiumClaimed,
  }) {
    return BattlePassTier(
      tier: tier,
      freeReward: freeReward,
      premiumReward: premiumReward,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isFreeClaimed: isFreeClaimed ?? this.isFreeClaimed,
      isPremiumClaimed: isPremiumClaimed ?? this.isPremiumClaimed,
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  XP BOOST
// ══════════════════════════════════════════════════════════════════

enum XPBoostType {
  oneHour,
  twentyFourHour,
  familyBoost;

  String get displayName {
    switch (this) {
      case XPBoostType.oneHour: return '1 Hour 2X XP';
      case XPBoostType.twentyFourHour: return '24 Hour 2X XP';
      case XPBoostType.familyBoost: return 'Family XP Boost';
    }
  }

  Duration get duration {
    switch (this) {
      case XPBoostType.oneHour: return const Duration(hours: 1);
      case XPBoostType.twentyFourHour: return const Duration(hours: 24);
      case XPBoostType.familyBoost: return const Duration(hours: 4);
    }
  }

  double get multiplier => 2.0;

  int get cost {
    switch (this) {
      case XPBoostType.oneHour: return 50;
      case XPBoostType.twentyFourHour: return 200;
      case XPBoostType.familyBoost: return 150;
    }
  }

  IconData get icon {
    switch (this) {
      case XPBoostType.oneHour: return Icons.bolt;
      case XPBoostType.twentyFourHour: return Icons.local_fire_department;
      case XPBoostType.familyBoost: return Icons.groups;
    }
  }
}

class XPBoost {
  final XPBoostType type;
  final DateTime activatedAt;
  final DateTime expiresAt;

  const XPBoost({
    required this.type,
    required this.activatedAt,
    required this.expiresAt,
  });

  bool get isActive => DateTime.now().isBefore(expiresAt);
  Duration get remaining {
    final r = expiresAt.difference(DateTime.now());
    return r.isNegative ? Duration.zero : r;
  }
}

// ══════════════════════════════════════════════════════════════════
//  BATTLE PASS MODEL
// ══════════════════════════════════════════════════════════════════

class BattlePassModel {
  final String seasonName;
  final DateTime seasonEndDate;
  final int currentTier;
  final int maxTier;
  final int currentXP;
  final int xpToNextTier;
  final bool isPremium;
  final bool isPremiumPlus;
  final List<BattlePassTier> tiers;
  final XPBoost? activeBoost;

  // Economy
  final int premiumCost;
  final int premiumPlusCost;
  final int tierSkipCost;

  const BattlePassModel({
    this.seasonName = 'Season 1: MAFIA AT CITY',
    required this.seasonEndDate,
    this.currentTier = 1,
    this.maxTier = 50,
    this.currentXP = 0,
    this.xpToNextTier = 1000,
    this.isPremium = false,
    this.isPremiumPlus = false,
    this.tiers = const [],
    this.activeBoost,
    this.premiumCost = 999,
    this.premiumPlusCost = 1999,
    this.tierSkipCost = 100,
  });

  double get progress => xpToNextTier > 0 ? currentXP / xpToNextTier : 0;
  bool get hasActiveBoost => activeBoost != null && activeBoost!.isActive;
  double get boostMultiplier => hasActiveBoost ? activeBoost!.type.multiplier : 1.0;

  Duration get timeRemaining {
    final r = seasonEndDate.difference(DateTime.now());
    return r.isNegative ? Duration.zero : r;
  }

  bool get isUrgent => timeRemaining.inDays < 3;

  int claimableCount(bool isPrem) {
    return tiers.where((t) {
      if (t.isUnlocked && !t.isFreeClaimed) return true;
      if (isPrem && t.isUnlocked && t.premiumReward != null && !t.isPremiumClaimed) return true;
      return false;
    }).length;
  }

  BattlePassModel copyWith({
    String? seasonName,
    DateTime? seasonEndDate,
    int? currentTier,
    int? maxTier,
    int? currentXP,
    int? xpToNextTier,
    bool? isPremium,
    bool? isPremiumPlus,
    List<BattlePassTier>? tiers,
    XPBoost? activeBoost,
    bool clearBoost = false,
  }) {
    return BattlePassModel(
      seasonName: seasonName ?? this.seasonName,
      seasonEndDate: seasonEndDate ?? this.seasonEndDate,
      currentTier: currentTier ?? this.currentTier,
      maxTier: maxTier ?? this.maxTier,
      currentXP: currentXP ?? this.currentXP,
      xpToNextTier: xpToNextTier ?? this.xpToNextTier,
      isPremium: isPremium ?? this.isPremium,
      isPremiumPlus: isPremiumPlus ?? this.isPremiumPlus,
      tiers: tiers ?? this.tiers,
      activeBoost: clearBoost ? null : (activeBoost ?? this.activeBoost),
      premiumCost: premiumCost,
      premiumPlusCost: premiumPlusCost,
      tierSkipCost: tierSkipCost,
    );
  }
}
