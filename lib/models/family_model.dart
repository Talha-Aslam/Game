import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════════
//  FAMILY ROLES & PERMISSIONS
// ══════════════════════════════════════════════════════════════════

/// Family roles with hierarchical permissions
enum FamilyRole {
  boss,
  underboss,
  capo,
  associate;

  String get displayName {
    switch (this) {
      case FamilyRole.boss:
        return 'Boss';
      case FamilyRole.underboss:
        return 'Underboss';
      case FamilyRole.capo:
        return 'Capo';
      case FamilyRole.associate:
        return 'Associate';
    }
  }

  Color get color {
    switch (this) {
      case FamilyRole.boss:
        return const Color(0xFFFFD700);
      case FamilyRole.underboss:
        return const Color(0xFF9B59FF);
      case FamilyRole.capo:
        return const Color(0xFF00E5FF);
      case FamilyRole.associate:
        return const Color(0x80FFFFFF);
    }
  }

  IconData get icon {
    switch (this) {
      case FamilyRole.boss:
        return Icons.workspace_premium;
      case FamilyRole.underboss:
        return Icons.shield;
      case FamilyRole.capo:
        return Icons.military_tech;
      case FamilyRole.associate:
        return Icons.person;
    }
  }

  int get hierarchyLevel {
    switch (this) {
      case FamilyRole.boss:
        return 0;
      case FamilyRole.underboss:
        return 1;
      case FamilyRole.capo:
        return 2;
      case FamilyRole.associate:
        return 3;
    }
  }

  bool get canKick =>
      this == FamilyRole.boss || this == FamilyRole.underboss;
  bool get canInvite =>
      this != FamilyRole.associate;
  bool get canPromote =>
      this == FamilyRole.boss;
  bool get canEditSettings =>
      this == FamilyRole.boss || this == FamilyRole.underboss;
  bool get canManageTreasury =>
      this == FamilyRole.boss;
  bool get canModerateChat =>
      this != FamilyRole.associate;
  bool get canEditMOTD =>
      this == FamilyRole.boss || this == FamilyRole.underboss;
  bool get canViewAuditLog =>
      this == FamilyRole.boss || this == FamilyRole.underboss;
  bool get canDeleteFamily =>
      this == FamilyRole.boss;
  bool get canTransferOwnership =>
      this == FamilyRole.boss;
}

// ══════════════════════════════════════════════════════════════════
//  FAMILY PRIVACY
// ══════════════════════════════════════════════════════════════════

enum FamilyPrivacy {
  public,
  approvalRequired,
  inviteOnly;

  String get displayName {
    switch (this) {
      case FamilyPrivacy.public:
        return 'Public';
      case FamilyPrivacy.approvalRequired:
        return 'Approval Required';
      case FamilyPrivacy.inviteOnly:
        return 'Invite Only';
    }
  }

  IconData get icon {
    switch (this) {
      case FamilyPrivacy.public:
        return Icons.public;
      case FamilyPrivacy.approvalRequired:
        return Icons.how_to_reg;
      case FamilyPrivacy.inviteOnly:
        return Icons.lock;
    }
  }
}

// ══════════════════════════════════════════════════════════════════
//  FAMILY MEMBER ACTIVITY
// ══════════════════════════════════════════════════════════════════

enum MemberActivity {
  online,
  offline,
  inMatch,
  inVoiceChat,
  inParty,
  spectating,
  idle;

  String get displayName {
    switch (this) {
      case MemberActivity.online:
        return 'Online';
      case MemberActivity.offline:
        return 'Offline';
      case MemberActivity.inMatch:
        return 'In Match';
      case MemberActivity.inVoiceChat:
        return 'In Voice Chat';
      case MemberActivity.inParty:
        return 'In Party';
      case MemberActivity.spectating:
        return 'Spectating';
      case MemberActivity.idle:
        return 'Idle';
    }
  }

  Color get statusColor {
    switch (this) {
      case MemberActivity.online:
        return const Color(0xFF00E676);
      case MemberActivity.offline:
        return const Color(0xFF616161);
      case MemberActivity.inMatch:
        return const Color(0xFFFF1744);
      case MemberActivity.inVoiceChat:
        return const Color(0xFF00E5FF);
      case MemberActivity.inParty:
        return const Color(0xFF448AFF);
      case MemberActivity.spectating:
        return const Color(0xFFFFD700);
      case MemberActivity.idle:
        return const Color(0xFFFFC107);
    }
  }

  bool get isAvailable =>
      this == MemberActivity.online || this == MemberActivity.idle;
}

// ══════════════════════════════════════════════════════════════════
//  FAMILY ENTRY REQUIREMENTS
// ══════════════════════════════════════════════════════════════════

class FamilyRequirements {
  final int minRankTier;
  final int minRankPoints;
  final int minGamesPlayed;
  final String language;
  final String region;

  const FamilyRequirements({
    this.minRankTier = 0,
    this.minRankPoints = 0,
    this.minGamesPlayed = 0,
    this.language = 'Any',
    this.region = 'Any',
  });

  FamilyRequirements copyWith({
    int? minRankTier,
    int? minRankPoints,
    int? minGamesPlayed,
    String? language,
    String? region,
  }) {
    return FamilyRequirements(
      minRankTier: minRankTier ?? this.minRankTier,
      minRankPoints: minRankPoints ?? this.minRankPoints,
      minGamesPlayed: minGamesPlayed ?? this.minGamesPlayed,
      language: language ?? this.language,
      region: region ?? this.region,
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  FAMILY MEMBER
// ══════════════════════════════════════════════════════════════════

class FamilyMember {
  final String userId;
  final String username;
  final String avatarUrl;
  final FamilyRole role;
  final int contributedPoints;
  final MemberActivity activity;
  final int rankTier;
  final int rankPoints;
  final double winRate;
  final int totalGames;
  final double trustRating;
  final int popularityScore;
  final String? mostPlayedRole;
  final DateTime joinedAt;
  final DateTime lastActive;
  final bool isMuted;

  const FamilyMember({
    required this.userId,
    required this.username,
    this.avatarUrl = '',
    this.role = FamilyRole.associate,
    this.contributedPoints = 0,
    this.activity = MemberActivity.offline,
    this.rankTier = 0,
    this.rankPoints = 0,
    this.winRate = 0.0,
    this.totalGames = 0,
    this.trustRating = 5.0,
    this.popularityScore = 0,
    this.mostPlayedRole,
    required this.joinedAt,
    required this.lastActive,
    this.isMuted = false,
  });

  bool get isOnline => activity != MemberActivity.offline;

  String get rankName {
    const ranks = ['Bronze', 'Silver', 'Gold', 'Diamond', 'Syndicate Boss'];
    return ranks[rankTier.clamp(0, ranks.length - 1)];
  }

  FamilyMember copyWith({
    String? userId,
    String? username,
    String? avatarUrl,
    FamilyRole? role,
    int? contributedPoints,
    MemberActivity? activity,
    int? rankTier,
    int? rankPoints,
    double? winRate,
    int? totalGames,
    double? trustRating,
    int? popularityScore,
    String? mostPlayedRole,
    DateTime? joinedAt,
    DateTime? lastActive,
    bool? isMuted,
  }) {
    return FamilyMember(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      contributedPoints: contributedPoints ?? this.contributedPoints,
      activity: activity ?? this.activity,
      rankTier: rankTier ?? this.rankTier,
      rankPoints: rankPoints ?? this.rankPoints,
      winRate: winRate ?? this.winRate,
      totalGames: totalGames ?? this.totalGames,
      trustRating: trustRating ?? this.trustRating,
      popularityScore: popularityScore ?? this.popularityScore,
      mostPlayedRole: mostPlayedRole ?? this.mostPlayedRole,
      joinedAt: joinedAt ?? this.joinedAt,
      lastActive: lastActive ?? this.lastActive,
      isMuted: isMuted ?? this.isMuted,
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  FAMILY MODEL
// ══════════════════════════════════════════════════════════════════

class FamilyModel {
  final String id;
  final String name;
  final String tag;
  final String description;
  final String slogan;
  final String logoUrl;
  final String crestIcon;
  final Color themeColor;
  final FamilyPrivacy privacy;
  final FamilyRequirements requirements;

  // Members
  final List<FamilyMember> members;
  final int maxMembers;

  // Progression
  final int level;
  final int currentXP;
  final int xpToNextLevel;

  // Treasury
  final int treasuryBalance;

  // MOTD
  final String motd;
  final DateTime? motdUpdatedAt;

  // Metadata
  final DateTime createdAt;
  final String createdBy;

  const FamilyModel({
    required this.id,
    required this.name,
    required this.tag,
    this.description = '',
    this.slogan = '',
    this.logoUrl = '',
    this.crestIcon = 'groups',
    this.themeColor = const Color(0xFF9B59FF),
    this.privacy = FamilyPrivacy.approvalRequired,
    this.requirements = const FamilyRequirements(),
    this.members = const [],
    this.maxMembers = 25,
    this.level = 1,
    this.currentXP = 0,
    this.xpToNextLevel = 1000,
    this.treasuryBalance = 0,
    this.motd = '',
    this.motdUpdatedAt,
    required this.createdAt,
    this.createdBy = '',
  });

  int get memberCount => members.length;
  int get onlineCount => members.where((m) => m.isOnline).length;

  /// Max members based on family level
  int get levelMaxMembers {
    if (level >= 20) return 100;
    if (level >= 10) return 75;
    if (level >= 5) return 50;
    return 25;
  }

  FamilyModel copyWith({
    String? id,
    String? name,
    String? tag,
    String? description,
    String? slogan,
    String? logoUrl,
    String? crestIcon,
    Color? themeColor,
    FamilyPrivacy? privacy,
    FamilyRequirements? requirements,
    List<FamilyMember>? members,
    int? maxMembers,
    int? level,
    int? currentXP,
    int? xpToNextLevel,
    int? treasuryBalance,
    String? motd,
    DateTime? motdUpdatedAt,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return FamilyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      tag: tag ?? this.tag,
      description: description ?? this.description,
      slogan: slogan ?? this.slogan,
      logoUrl: logoUrl ?? this.logoUrl,
      crestIcon: crestIcon ?? this.crestIcon,
      themeColor: themeColor ?? this.themeColor,
      privacy: privacy ?? this.privacy,
      requirements: requirements ?? this.requirements,
      members: members ?? this.members,
      maxMembers: maxMembers ?? this.maxMembers,
      level: level ?? this.level,
      currentXP: currentXP ?? this.currentXP,
      xpToNextLevel: xpToNextLevel ?? this.xpToNextLevel,
      treasuryBalance: treasuryBalance ?? this.treasuryBalance,
      motd: motd ?? this.motd,
      motdUpdatedAt: motdUpdatedAt ?? this.motdUpdatedAt,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
