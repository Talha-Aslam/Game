/// User profile model
class UserModel {
  final String id;
  final String username;
  final String email;
  final String avatarUrl;
  final String? premiumAvatarId;
  final String? bio;
  final String? equippedTitle;
  final List<String> ownedAvatars;
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
  final List<String> equippedCosmetics;
  final bool hasBattlePass;
  final int battlePassTier;
  final int battlePassXP;
  final bool hasPremiumPass;
  final List<int> claimedFreeTiers;
  final List<int> claimedPremiumTiers;
  final int popularityScore;
  final String popularityRank;
  final int friendCount;
  final int onlineFriendCount;

  const UserModel({
    required this.id,
    required this.username,
    this.email = '',
    this.avatarUrl = '',
    this.premiumAvatarId,
    this.bio,
    this.equippedTitle,
    this.ownedAvatars = const [],
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
    this.equippedCosmetics = const [],
    this.hasBattlePass = false,
    this.battlePassTier = 0,
    this.battlePassXP = 0,
    this.hasPremiumPass = false,
    this.claimedFreeTiers = const [],
    this.claimedPremiumTiers = const [],
    this.popularityScore = 0,
    this.popularityRank = 'Rising Star',
    this.friendCount = 0,
    this.onlineFriendCount = 0,
  });

  double get winRate => totalGames > 0 ? (wins / totalGames * 100) : 0;

  String get rankName {
    const ranks = ['Bronze', 'Silver', 'Gold', 'Diamond', 'Syndicate Boss'];
    return ranks[rankTier.clamp(0, ranks.length - 1)];
  }

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? avatarUrl,
    String? premiumAvatarId,
    String? bio,
    String? equippedTitle,
    List<String>? ownedAvatars,
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
    List<String>? equippedCosmetics,
    bool? hasBattlePass,
    int? battlePassTier,
    int? battlePassXP,
    bool? hasPremiumPass,
    List<int>? claimedFreeTiers,
    List<int>? claimedPremiumTiers,
    int? popularityScore,
    String? popularityRank,
    int? friendCount,
    int? onlineFriendCount,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      premiumAvatarId: premiumAvatarId ?? this.premiumAvatarId,
      bio: bio ?? this.bio,
      equippedTitle: equippedTitle ?? this.equippedTitle,
      ownedAvatars: ownedAvatars ?? this.ownedAvatars,
      rankTier: rankTier ?? this.rankTier,
      rankPoints: rankPoints ?? this.rankPoints,
      influencePoints: influencePoints ?? this.influencePoints,
      syndicateCoins: syndicateCoins ?? this.syndicateCoins,
      totalGames: totalGames ?? this.totalGames,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      familyId: familyId ?? this.familyId,
      familyName: familyName ?? this.familyName,
      familyRole: familyRole ?? this.familyRole,
      equippedCosmetics: equippedCosmetics ?? this.equippedCosmetics,
      hasBattlePass: hasBattlePass ?? this.hasBattlePass,
      battlePassTier: battlePassTier ?? this.battlePassTier,
      battlePassXP: battlePassXP ?? this.battlePassXP,
      hasPremiumPass: hasPremiumPass ?? this.hasPremiumPass,
      claimedFreeTiers: claimedFreeTiers ?? this.claimedFreeTiers,
      claimedPremiumTiers: claimedPremiumTiers ?? this.claimedPremiumTiers,
      popularityScore: popularityScore ?? this.popularityScore,
      popularityRank: popularityRank ?? this.popularityRank,
      friendCount: friendCount ?? this.friendCount,
      onlineFriendCount: onlineFriendCount ?? this.onlineFriendCount,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Helper to map string rank from backend to rankTier int
    int parseRankTier(dynamic rankVal) {
      if (rankVal is int) return rankVal;
      if (rankVal is String) {
        final r = rankVal.toLowerCase();
        if (r.contains('silver')) return 1;
        if (r.contains('gold')) return 2;
        if (r.contains('diamond')) return 3;
        if (r.contains('boss') || r.contains('syndicate')) return 4;
      }
      return 0; // Default Bronze
    }

    final inventory = json['inventory'] as Map<String, dynamic>?;
    final friendsList = json['friends'] as List<dynamic>?;
    final battlePassTier =
        json['battle_pass_tier'] ?? json['battlePassTier'] ?? 0;

    return UserModel(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      avatarUrl:
          json['profile_picture']?.toString() ??
          json['avatarUrl']?.toString() ??
          '',
      premiumAvatarId:
          json['premium_avatar']?.toString() ??
          json['premiumAvatarId']?.toString(),
      bio: json['bio']?.toString(),
      equippedTitle:
          json['title']?.toString() ?? json['equippedTitle']?.toString(),
      ownedAvatars:
          (inventory?['premium_avatars'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          (json['ownedAvatars'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      rankTier: parseRankTier(json['rank'] ?? json['rankTier']),
      rankPoints: json['mmr'] ?? json['rankPoints'] ?? 0,
      influencePoints: json['influence'] ?? json['influencePoints'] ?? 0,
      syndicateCoins: json['syndicate_coins'] ?? json['syndicateCoins'] ?? 0,
      totalGames: json['games_played'] ?? json['totalGames'] ?? 0,
      wins: json['wins'] ?? 0,
      losses: json['losses'] ?? 0,
      familyId: json['family_id']?.toString() ?? json['familyId']?.toString(),
      familyName: json['familyName']
          ?.toString(), // Fetched separately later if needed
      familyRole: json['familyRole']?.toString(),
      hasBattlePass:
          (battlePassTier as int) > 0 ||
          (json['hasBattlePass'] as bool? ?? false),
      battlePassTier: battlePassTier,
      battlePassXP: json['battle_pass_xp'] ?? json['battlePassXP'] ?? 0,
      hasPremiumPass:
          json['has_premium_pass'] ?? json['hasPremiumPass'] ?? false,
      claimedFreeTiers:
          (json['claimed_free_tiers'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          (json['claimedFreeTiers'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      claimedPremiumTiers:
          (json['claimed_premium_tiers'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          (json['claimedPremiumTiers'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      popularityScore: json['popularity'] ?? json['popularityScore'] ?? 0,
      popularityRank: json['popularityRank']?.toString() ?? 'Rising Star',
      friendCount: friendsList?.length ?? json['friendCount'] ?? 0,
      onlineFriendCount: json['onlineFriendCount'] ?? 0,
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
    'ownedAvatars': ownedAvatars,
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
  };
}
