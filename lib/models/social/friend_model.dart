/// Online presence status for a player
enum OnlineStatus {
  online,
  offline,
  inMatch,
  inFamilyLobby,
  busy,
  doNotDisturb;

  String get displayName {
    switch (this) {
      case OnlineStatus.online:
        return 'Online';
      case OnlineStatus.offline:
        return 'Offline';
      case OnlineStatus.inMatch:
        return 'In Match';
      case OnlineStatus.inFamilyLobby:
        return 'In Family Lobby';
      case OnlineStatus.busy:
        return 'Busy';
      case OnlineStatus.doNotDisturb:
        return 'Do Not Disturb';
    }
  }

  bool get isAvailable =>
      this == OnlineStatus.online || this == OnlineStatus.inFamilyLobby;
}

/// Current activity of a player
enum PlayerActivity {
  idle,
  inLobby,
  inMatch,
  lookingForTeam,
  inStore,
  inBattlePass;

  String get displayName {
    switch (this) {
      case PlayerActivity.idle:
        return 'Idle';
      case PlayerActivity.inLobby:
        return 'In Lobby';
      case PlayerActivity.inMatch:
        return 'In Match';
      case PlayerActivity.lookingForTeam:
        return 'Looking for Team';
      case PlayerActivity.inStore:
        return 'Browsing Store';
      case PlayerActivity.inBattlePass:
        return 'Viewing Battle Pass';
    }
  }
}

/// Friend / player social profile model
class FriendModel {
  final String id;
  final String username;
  final String avatarUrl;
  final int rankTier;
  final String? equippedTitle;
  final String? familyTag;
  final String? familyName;
  final int popularityScore;
  final String popularityRank;
  final OnlineStatus onlineStatus;
  final PlayerActivity currentActivity;
  final DateTime? lastSeen;
  final int mutualFriendCount;
  final bool isBlocked;
  final int unreadCount;

  final int gamesPlayed;
  final double winRate;
  
  final Map<String, dynamic>? equippedCosmetics;

  const FriendModel({
    required this.id,
    required this.username,
    this.avatarUrl = '',
    this.rankTier = 0,
    this.equippedTitle,
    this.familyTag,
    this.familyName,
    this.popularityScore = 0,
    this.popularityRank = 'Rising Star',
    this.onlineStatus = OnlineStatus.offline,
    this.currentActivity = PlayerActivity.idle,
    this.lastSeen,
    this.mutualFriendCount = 0,
    this.isBlocked = false,
    this.unreadCount = 0,
    this.gamesPlayed = 0,
    this.winRate = 0.0,
    this.equippedCosmetics,
  });

  bool get isOnline => onlineStatus != OnlineStatus.offline;

  String get rankName {
    const ranks = ['Bronze', 'Silver', 'Gold', 'Diamond', 'Syndicate Boss'];
    return ranks[rankTier.clamp(0, ranks.length - 1)];
  }

  String get statusText {
    if (onlineStatus == OnlineStatus.offline) {
      if (lastSeen != null) {
        final diff = DateTime.now().difference(lastSeen!);
        if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
        if (diff.inHours < 24) return '${diff.inHours}h ago';
        return '${diff.inDays}d ago';
      }
      return 'Offline';
    }
    if (onlineStatus == OnlineStatus.inMatch) return 'In Match';
    if (currentActivity == PlayerActivity.lookingForTeam) {
      return 'Looking for Team';
    }
    return currentActivity.displayName;
  }

  FriendModel copyWith({
    String? id,
    String? username,
    String? avatarUrl,
    int? rankTier,
    String? equippedTitle,
    String? familyTag,
    String? familyName,
    int? popularityScore,
    String? popularityRank,
    OnlineStatus? onlineStatus,
    PlayerActivity? currentActivity,
    DateTime? lastSeen,
    int? mutualFriendCount,
    bool? isBlocked,
    int? gamesPlayed,
    double? winRate,
    Map<String, dynamic>? equippedCosmetics,
  }) {
    return FriendModel(
      id: id ?? this.id,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rankTier: rankTier ?? this.rankTier,
      equippedTitle: equippedTitle ?? this.equippedTitle,
      familyTag: familyTag ?? this.familyTag,
      familyName: familyName ?? this.familyName,
      popularityScore: popularityScore ?? this.popularityScore,
      popularityRank: popularityRank ?? this.popularityRank,
      onlineStatus: onlineStatus ?? this.onlineStatus,
      currentActivity: currentActivity ?? this.currentActivity,
      lastSeen: lastSeen ?? this.lastSeen,
      mutualFriendCount: mutualFriendCount ?? this.mutualFriendCount,
      isBlocked: isBlocked ?? this.isBlocked,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      winRate: winRate ?? this.winRate,
      equippedCosmetics: equippedCosmetics ?? this.equippedCosmetics,
    );
  }
}
