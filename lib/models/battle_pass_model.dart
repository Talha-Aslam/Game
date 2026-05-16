/// Battle pass tier and reward model
class BattlePassModel {
  final int currentTier;
  final int maxTier;
  final int currentXP;
  final int xpToNextTier;
  final bool isPremium;
  final List<BattlePassTier> tiers;

  const BattlePassModel({
    this.currentTier = 1,
    this.maxTier = 50,
    this.currentXP = 0,
    this.xpToNextTier = 1000,
    this.isPremium = false,
    this.tiers = const [],
  });

  double get progress => xpToNextTier > 0 ? currentXP / xpToNextTier : 0;

  BattlePassModel copyWith({
    int? currentTier,
    int? maxTier,
    int? currentXP,
    int? xpToNextTier,
    bool? isPremium,
    List<BattlePassTier>? tiers,
  }) {
    return BattlePassModel(
      currentTier: currentTier ?? this.currentTier,
      maxTier: maxTier ?? this.maxTier,
      currentXP: currentXP ?? this.currentXP,
      xpToNextTier: xpToNextTier ?? this.xpToNextTier,
      isPremium: isPremium ?? this.isPremium,
      tiers: tiers ?? this.tiers,
    );
  }
}

/// Individual battle pass tier
class BattlePassTier {
  final int tier;
  final BattlePassReward freeReward;
  final BattlePassReward? premiumReward;
  final bool isUnlocked;
  final bool isClaimed;

  const BattlePassTier({
    required this.tier,
    required this.freeReward,
    this.premiumReward,
    this.isUnlocked = false,
    this.isClaimed = false,
  });
}

/// Battle pass reward
class BattlePassReward {
  final String id;
  final String name;
  final String description;
  final RewardType type;
  final String? imageUrl;
  final int? currencyAmount;

  const BattlePassReward({
    required this.id,
    required this.name,
    this.description = '',
    required this.type,
    this.imageUrl,
    this.currencyAmount,
  });
}

/// Reward types
enum RewardType {
  cardStyle,
  borderEffect,
  eliminationEffect,
  voicePack,
  influencePoints,
  syndicateCoins,
  avatar,
  title;

  String get displayName {
    switch (this) {
      case RewardType.cardStyle:
        return 'Card Style';
      case RewardType.borderEffect:
        return 'Border Effect';
      case RewardType.eliminationEffect:
        return 'Elimination Effect';
      case RewardType.voicePack:
        return 'Voice Pack';
      case RewardType.influencePoints:
        return 'Influence Points';
      case RewardType.syndicateCoins:
        return 'Syndicate Coins';
      case RewardType.avatar:
        return 'Avatar';
      case RewardType.title:
        return 'Title';
    }
  }
}
