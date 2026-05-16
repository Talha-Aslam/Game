/// Family (Clan) model
class FamilyModel {
  final String id;
  final String name;
  final String tag; // e.g. [COBRA]
  final String description;
  final String logoUrl;
  final int memberCount;
  final int maxMembers;
  final int totalWins;
  final int seasonPoints;
  final List<FamilyMember> members;

  const FamilyModel({
    required this.id,
    required this.name,
    required this.tag,
    this.description = '',
    this.logoUrl = '',
    this.memberCount = 0,
    this.maxMembers = 50,
    this.totalWins = 0,
    this.seasonPoints = 0,
    this.members = const [],
  });

  FamilyModel copyWith({
    String? id,
    String? name,
    String? tag,
    String? description,
    String? logoUrl,
    int? memberCount,
    int? maxMembers,
    int? totalWins,
    int? seasonPoints,
    List<FamilyMember>? members,
  }) {
    return FamilyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      tag: tag ?? this.tag,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      memberCount: memberCount ?? this.memberCount,
      maxMembers: maxMembers ?? this.maxMembers,
      totalWins: totalWins ?? this.totalWins,
      seasonPoints: seasonPoints ?? this.seasonPoints,
      members: members ?? this.members,
    );
  }
}

/// Family member
class FamilyMember {
  final String userId;
  final String username;
  final String avatarUrl;
  final FamilyRole role;
  final int contributedPoints;
  final bool isOnline;

  const FamilyMember({
    required this.userId,
    required this.username,
    this.avatarUrl = '',
    this.role = FamilyRole.associate,
    this.contributedPoints = 0,
    this.isOnline = false,
  });
}

/// Family roles
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
}
