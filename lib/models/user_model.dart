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
      popularityScore: popularityScore ?? this.popularityScore,
      popularityRank: popularityRank ?? this.popularityRank,
      friendCount: friendCount ?? this.friendCount,
      onlineFriendCount: onlineFriendCount ?? this.onlineFriendCount,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      premiumAvatarId: json['premiumAvatarId'] as String?,
      bio: json['bio'] as String?,
      equippedTitle: json['equippedTitle'] as String?,
      ownedAvatars:
          (json['ownedAvatars'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      rankTier: json['rankTier'] as int? ?? 0,
      rankPoints: json['rankPoints'] as int? ?? 0,
      influencePoints: json['influencePoints'] as int? ?? 0,
      syndicateCoins: json['syndicateCoins'] as int? ?? 0,
      totalGames: json['totalGames'] as int? ?? 0,
      wins: json['wins'] as int? ?? 0,
      losses: json['losses'] as int? ?? 0,
      familyId: json['familyId'] as String?,
      familyName: json['familyName'] as String?,
      familyRole: json['familyRole'] as String?,
      hasBattlePass: json['hasBattlePass'] as bool? ?? false,
      battlePassTier: json['battlePassTier'] as int? ?? 0,
      popularityScore: json['popularityScore'] as int? ?? 0,
      popularityRank: json['popularityRank'] as String? ?? 'Rising Star',
      friendCount: json['friendCount'] as int? ?? 0,
      onlineFriendCount: json['onlineFriendCount'] as int? ?? 0,
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
    'popularityScore': popularityScore,
    'popularityRank': popularityRank,
    'friendCount': friendCount,
    'onlineFriendCount': onlineFriendCount,
  };
}
