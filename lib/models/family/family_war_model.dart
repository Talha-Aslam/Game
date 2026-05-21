/// Syndicate War status
enum WarStatus {
  pending,
  accepted,
  active,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case WarStatus.pending:
        return 'Pending';
      case WarStatus.accepted:
        return 'Accepted';
      case WarStatus.active:
        return 'Active';
      case WarStatus.completed:
        return 'Completed';
      case WarStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// War participant (subset of FamilyMember for rosters)
class WarParticipant {
  final String userId;
  final String username;
  final int rankTier;
  final double winRate;
  final bool isReady;

  const WarParticipant({
    required this.userId,
    required this.username,
    this.rankTier = 0,
    this.winRate = 0.0,
    this.isReady = false,
  });

  WarParticipant copyWith({bool? isReady}) {
    return WarParticipant(
      userId: userId,
      username: username,
      rankTier: rankTier,
      winRate: winRate,
      isReady: isReady ?? this.isReady,
    );
  }
}

/// Syndicate War model — 7v7 default, players can be less
class FamilyWarModel {
  final String id;
  final String challengerFamilyId;
  final String challengerFamilyName;
  final String challengerFamilyTag;
  final String defenderFamilyId;
  final String defenderFamilyName;
  final String defenderFamilyTag;
  final List<WarParticipant> challengerRoster;
  final List<WarParticipant> defenderRoster;
  final int maxTeamSize;
  final int challengerScore;
  final int defenderScore;
  final WarStatus status;
  final int trophiesAtStake;
  final int xpReward;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;

  const FamilyWarModel({
    required this.id,
    required this.challengerFamilyId,
    required this.challengerFamilyName,
    required this.challengerFamilyTag,
    required this.defenderFamilyId,
    required this.defenderFamilyName,
    required this.defenderFamilyTag,
    this.challengerRoster = const [],
    this.defenderRoster = const [],
    this.maxTeamSize = 7,
    this.challengerScore = 0,
    this.defenderScore = 0,
    this.status = WarStatus.pending,
    this.trophiesAtStake = 100,
    this.xpReward = 500,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
  });

  String? get winnerId {
    if (status != WarStatus.completed) return null;
    if (challengerScore > defenderScore) return challengerFamilyId;
    if (defenderScore > challengerScore) return defenderFamilyId;
    return null; // draw
  }

  FamilyWarModel copyWith({
    List<WarParticipant>? challengerRoster,
    List<WarParticipant>? defenderRoster,
    int? challengerScore,
    int? defenderScore,
    WarStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return FamilyWarModel(
      id: id,
      challengerFamilyId: challengerFamilyId,
      challengerFamilyName: challengerFamilyName,
      challengerFamilyTag: challengerFamilyTag,
      defenderFamilyId: defenderFamilyId,
      defenderFamilyName: defenderFamilyName,
      defenderFamilyTag: defenderFamilyTag,
      challengerRoster: challengerRoster ?? this.challengerRoster,
      defenderRoster: defenderRoster ?? this.defenderRoster,
      maxTeamSize: maxTeamSize,
      challengerScore: challengerScore ?? this.challengerScore,
      defenderScore: defenderScore ?? this.defenderScore,
      status: status ?? this.status,
      trophiesAtStake: trophiesAtStake,
      xpReward: xpReward,
      createdAt: createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

/// Persistent rivalry record
class RivalryRecord {
  final String rivalFamilyId;
  final String rivalFamilyName;
  final String rivalFamilyTag;
  final int wins;
  final int losses;
  final DateTime lastMatchDate;

  const RivalryRecord({
    required this.rivalFamilyId,
    required this.rivalFamilyName,
    required this.rivalFamilyTag,
    this.wins = 0,
    this.losses = 0,
    required this.lastMatchDate,
  });

  int get totalMatches => wins + losses;
  double get winRate => totalMatches > 0 ? wins / totalMatches * 100 : 0;
}
