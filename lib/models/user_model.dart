import 'rank_model.dart';

/// Role specific statistics
class RoleStats {
  final int mafiaWins;
  final int civilianWins;
  final int detectiveWins;
  final int doctorSaves;
  final int perfectMafiaSweeps;

  const RoleStats({
    this.mafiaWins = 0,
    this.civilianWins = 0,
    this.detectiveWins = 0,
    this.doctorSaves = 0,
    this.perfectMafiaSweeps = 0,
  });

  factory RoleStats.fromJson(Map<String, dynamic> json) {
    return RoleStats(
      mafiaWins: json['mafia_wins'] ?? 0,
      civilianWins: json['civilian_wins'] ?? 0,
      detectiveWins: json['detective_wins'] ?? 0,
      doctorSaves: json['doctor_saves'] ?? 0,
      perfectMafiaSweeps: json['perfect_mafia_sweeps'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'mafia_wins': mafiaWins,
    'civilian_wins': civilianWins,
    'detective_wins': detectiveWins,
    'doctor_saves': doctorSaves,
    'perfect_mafia_sweeps': perfectMafiaSweeps,
  };
}

/// Inventory tracking
class InventoryModel {
  final List<String> premiumAvatars;
  final List<String> cardStyles;
  final List<String> borders;
  final List<String> eliminationFx;
  final List<String> voicePacks;
  final List<String> bundles;

  const InventoryModel({
    this.premiumAvatars = const [],
    this.cardStyles = const [],
    this.borders = const [],
    this.eliminationFx = const [],
    this.voicePacks = const [],
    this.bundles = const [],
  });

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    List<String> parseList(String key) {
      return (json[key] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    }

    return InventoryModel(
      premiumAvatars: parseList('premium_avatars') + parseList('avatars'),
      cardStyles: parseList('card_styles') + parseList('cardStyles'),
      borders: parseList('borders'),
      eliminationFx: parseList('elimination_fx') + parseList('eliminationEffects'),
      voicePacks: parseList('voice_packs') + parseList('voicePacks'),
      bundles: parseList('bundles'),
    );
  }

  List<String> getCategoryList(String category) {
    switch (category) {
      case 'avatars': return premiumAvatars;
      case 'cardStyles': return cardStyles;
      case 'borders': return borders;
      case 'eliminationEffects': return eliminationFx;
      case 'voicePacks': return voicePacks;
      case 'bundles': return bundles;
      default: return [];
    }
  }

  InventoryModel copyWith({
    List<String>? premiumAvatars,
    List<String>? cardStyles,
    List<String>? borders,
    List<String>? eliminationFx,
    List<String>? voicePacks,
    List<String>? bundles,
  }) {
    return InventoryModel(
      premiumAvatars: premiumAvatars ?? this.premiumAvatars,
      cardStyles: cardStyles ?? this.cardStyles,
      borders: borders ?? this.borders,
      eliminationFx: eliminationFx ?? this.eliminationFx,
      voicePacks: voicePacks ?? this.voicePacks,
      bundles: bundles ?? this.bundles,
    );
  }

  Map<String, dynamic> toJson() => {
    'premium_avatars': premiumAvatars,
    'card_styles': cardStyles,
    'borders': borders,
    'elimination_fx': eliminationFx,
    'voice_packs': voicePacks,
    'bundles': bundles,
  };
}

/// Equipped cosmetics tracking
class EquippedCosmeticsModel {
  final String cardBorder;
  final String nameplate;
  final String background;
  final String voicePack;

  const EquippedCosmeticsModel({
    this.cardBorder = '',
    this.nameplate = '',
    this.background = '',
    this.voicePack = '',
  });

  factory EquippedCosmeticsModel.fromJson(Map<String, dynamic> json) {
    return EquippedCosmeticsModel(
      cardBorder: json['card_border']?.toString() ?? json['cardBorder']?.toString() ?? '',
      nameplate: json['nameplate']?.toString() ?? '',
      background: json['background']?.toString() ?? '',
      voicePack: json['voice_pack']?.toString() ?? json['voicePack']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'card_border': cardBorder,
    'nameplate': nameplate,
    'background': background,
    'voice_pack': voicePack,
  };
}

/// User profile model
class UserModel {
  final String id;
  final String username;
  final String email;
  final String avatarUrl;
  final String? premiumAvatarId;
  final String? bio;
  final String? equippedTitle;
  final int rankTier;
  final int rankPoints;
  final int influencePoints; // free currency
  final int syndicateCoins; // premium currency
  final int totalGames;
  final int wins;
  final int losses;
  final String? familyId;
  final String? familyName;
  final String? familyRole;
  final InventoryModel inventory;
  final EquippedCosmeticsModel equippedCosmetics;
  final bool hasBattlePass;
  final int battlePassTier;
  final int battlePassXP;
  final bool hasPremiumPass;
  final bool hasPremiumPlus;
  final List<int> claimedFreeTiers;
  final List<int> claimedPremiumTiers;
  final int popularityScore;
  final String popularityRank;
  final int friendCount;
  final int onlineFriendCount;
  final RoleStats roleStats;
  final List<String> matchHistory;

  const UserModel({
    required this.id,
    required this.username,
    this.email = '',
    this.avatarUrl = '',
    this.premiumAvatarId,
    this.bio,
    this.equippedTitle,
    this.rankTier = 0,
    this.rankPoints = 0,
    this.influencePoints = 0,
    this.syndicateCoins = 0,
    this.totalGames = 0,
    this.wins = 0,
    this.losses = 0,
    this.familyId,
    this.familyName,
    this.familyRole,
    this.inventory = const InventoryModel(),
    this.equippedCosmetics = const EquippedCosmeticsModel(),
    this.hasBattlePass = false,
    this.battlePassTier = 0,
    this.battlePassXP = 0,
    this.hasPremiumPass = false,
    this.hasPremiumPlus = false,
    this.claimedFreeTiers = const [],
    this.claimedPremiumTiers = const [],
    this.popularityScore = 0,
    this.popularityRank = 'Rising Star',
    this.friendCount = 0,
    this.onlineFriendCount = 0,
    this.roleStats = const RoleStats(),
    this.matchHistory = const [],
  });

  double get winRate => totalGames > 0 ? (wins / totalGames * 100) : 0;

  String get rankName => RankModel.fromTier(rankTier).name;

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? avatarUrl,
    String? premiumAvatarId,
    String? bio,
    String? equippedTitle,
    int? rankTier,
    int? rankPoints,
    int? influencePoints,
    int? syndicateCoins,
    int? totalGames,
    int? wins,
    int? losses,
    String? familyId,
    String? familyName,
    String? familyRole,
    InventoryModel? inventory,
    EquippedCosmeticsModel? equippedCosmetics,
    bool? hasBattlePass,
    int? battlePassTier,
    int? battlePassXP,
    bool? hasPremiumPass,
    bool? hasPremiumPlus,
    List<int>? claimedFreeTiers,
    List<int>? claimedPremiumTiers,
    int? popularityScore,
    String? popularityRank,
    int? friendCount,
    int? onlineFriendCount,
    RoleStats? roleStats,
    List<String>? matchHistory,
  }) {
    int finalRankTier = rankTier ?? this.rankTier;
    if (rankPoints != null && rankTier == null) {
      finalRankTier = RankModel.fromPoints(rankPoints).tier;
    }

    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      premiumAvatarId: premiumAvatarId ?? this.premiumAvatarId,
      bio: bio ?? this.bio,
      equippedTitle: equippedTitle ?? this.equippedTitle,
      rankTier: finalRankTier,
      rankPoints: rankPoints ?? this.rankPoints,
      influencePoints: influencePoints ?? this.influencePoints,
      syndicateCoins: syndicateCoins ?? this.syndicateCoins,
      totalGames: totalGames ?? this.totalGames,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      familyId: familyId ?? this.familyId,
      familyName: familyName ?? this.familyName,
      familyRole: familyRole ?? this.familyRole,
      inventory: inventory ?? this.inventory,
      equippedCosmetics: equippedCosmetics ?? this.equippedCosmetics,
      hasBattlePass: hasBattlePass ?? this.hasBattlePass,
      battlePassTier: battlePassTier ?? this.battlePassTier,
      battlePassXP: battlePassXP ?? this.battlePassXP,
      hasPremiumPass: hasPremiumPass ?? this.hasPremiumPass,
      hasPremiumPlus: hasPremiumPlus ?? this.hasPremiumPlus,
      claimedFreeTiers: claimedFreeTiers ?? this.claimedFreeTiers,
      claimedPremiumTiers: claimedPremiumTiers ?? this.claimedPremiumTiers,
      popularityScore: popularityScore ?? this.popularityScore,
      popularityRank: popularityRank ?? this.popularityRank,
      friendCount: friendCount ?? this.friendCount,
      onlineFriendCount: onlineFriendCount ?? this.onlineFriendCount,
      roleStats: roleStats ?? this.roleStats,
      matchHistory: matchHistory ?? this.matchHistory,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    int parseRankTier(dynamic rankVal, int points) {
      if (rankVal is int) return rankVal;
      final derived = RankModel.fromPoints(points).tier;
      if (rankVal is String) {
        final r = rankVal.toLowerCase();
        if (r.contains('silver')) return derived < 1 ? 1 : derived;
        if (r.contains('gold')) return derived < 2 ? 2 : derived;
        if (r.contains('diamond')) return derived < 3 ? 3 : derived;
        if (r.contains('boss') || r.contains('syndicate')) return derived < 4 ? 4 : derived;
      }
      return derived;
    }

    final points = json['mmr'] ?? json['rankPoints'] ?? 0;
    final friendsList = json['friends'] as List<dynamic>?;
    final battlePassTier = json['battle_pass_tier'] ?? json['battlePassTier'] ?? 0;

    return UserModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      avatarUrl: json['profile_picture']?.toString() ?? json['avatarUrl']?.toString() ?? '',
      premiumAvatarId: json['premium_avatar']?.toString() ?? json['premiumAvatarId']?.toString(),
      bio: json['bio']?.toString(),
      equippedTitle: json['title']?.toString() ?? json['equippedTitle']?.toString(),
      rankTier: parseRankTier(json['rank'] ?? json['rankTier'], points),
      rankPoints: points,
      influencePoints: json['influence'] ?? json['influencePoints'] ?? 0,
      syndicateCoins: json['syndicate_coins'] ?? json['syndicateCoins'] ?? 0,
      totalGames: json['games_played'] ?? json['totalGames'] ?? 0,
      wins: json['wins'] ?? 0,
      losses: json['losses'] ?? 0,
      familyId: json['family_id']?.toString() ?? json['familyId']?.toString(),
      familyName: json['familyName']?.toString(),
      familyRole: json['familyRole']?.toString(),
      inventory: json['inventory'] != null ? InventoryModel.fromJson(json['inventory']) : const InventoryModel(),
      equippedCosmetics: json['equipped_cosmetics'] != null ? EquippedCosmeticsModel.fromJson(json['equipped_cosmetics']) : (json['equippedCosmetics'] != null ? EquippedCosmeticsModel.fromJson(json['equippedCosmetics']) : const EquippedCosmeticsModel()),
      hasBattlePass: (battlePassTier as int) > 0 || (json['hasBattlePass'] as bool? ?? false),
      battlePassTier: battlePassTier,
      battlePassXP: json['battle_pass_xp'] ?? json['battlePassXP'] ?? 0,
      hasPremiumPass: json['has_premium_pass'] ?? json['hasPremiumPass'] ?? false,
      hasPremiumPlus: json['has_premium_plus'] ?? json['hasPremiumPlus'] ?? false,
      claimedFreeTiers: (json['claimed_free_tiers'] as List<dynamic>?)?.map((e) => e as int).toList() ?? (json['claimedFreeTiers'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [],
      claimedPremiumTiers: (json['claimed_premium_tiers'] as List<dynamic>?)?.map((e) => e as int).toList() ?? (json['claimedPremiumTiers'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [],
      popularityScore: json['popularity'] ?? json['popularityScore'] ?? 0,
      popularityRank: json['popularityRank']?.toString() ?? 'Rising Star',
      friendCount: friendsList?.length ?? json['friendCount'] ?? 0,
      onlineFriendCount: json['onlineFriendCount'] ?? 0,
      roleStats: json['role_stats'] != null ? RoleStats.fromJson(json['role_stats']) : (json['roleStats'] != null ? RoleStats.fromJson(json['roleStats']) : const RoleStats()),
      matchHistory: (json['match_history'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? (json['matchHistory'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'avatarUrl': avatarUrl,
    'premiumAvatarId': premiumAvatarId,
    'bio': bio,
    'equippedTitle': equippedTitle,
    'rankTier': rankTier,
    'rankPoints': rankPoints,
    'influencePoints': influencePoints,
    'syndicateCoins': syndicateCoins,
    'totalGames': totalGames,
    'wins': wins,
    'losses': losses,
    'familyId': familyId,
    'familyName': familyName,
    'familyRole': familyRole,
    'inventory': inventory.toJson(),
    'equipped_cosmetics': equippedCosmetics.toJson(),
    'hasBattlePass': hasBattlePass,
    'battlePassTier': battlePassTier,
    'battlePassXP': battlePassXP,
    'hasPremiumPass': hasPremiumPass,
    'claimedFreeTiers': claimedFreeTiers,
    'claimedPremiumTiers': claimedPremiumTiers,
    'popularityScore': popularityScore,
    'popularityRank': popularityRank,
    'friendCount': friendCount,
    'onlineFriendCount': onlineFriendCount,
    'roleStats': roleStats.toJson(),
    'match_history': matchHistory,
  };
}
