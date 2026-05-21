/// Application status
enum ApplicationStatus {
  pending,
  accepted,
  rejected,
  withdrawn;

  String get displayName {
    switch (this) {
      case ApplicationStatus.pending:
        return 'Pending';
      case ApplicationStatus.accepted:
        return 'Accepted';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.withdrawn:
        return 'Withdrawn';
    }
  }
}

/// Family join application
class FamilyApplication {
  final String id;
  final String applicantId;
  final String applicantName;
  final String familyId;
  final int rankTier;
  final int rankPoints;
  final double winRate;
  final int totalGames;
  final double trustRating;
  final int popularityScore;
  final String? mostPlayedRole;
  final String? previousFamilyName;
  final ApplicationStatus status;
  final DateTime submittedAt;
  final String? reviewedBy;
  final DateTime? reviewedAt;

  const FamilyApplication({
    required this.id,
    required this.applicantId,
    required this.applicantName,
    required this.familyId,
    this.rankTier = 0,
    this.rankPoints = 0,
    this.winRate = 0.0,
    this.totalGames = 0,
    this.trustRating = 5.0,
    this.popularityScore = 0,
    this.mostPlayedRole,
    this.previousFamilyName,
    this.status = ApplicationStatus.pending,
    required this.submittedAt,
    this.reviewedBy,
    this.reviewedAt,
  });

  String get rankName {
    const ranks = ['Bronze', 'Silver', 'Gold', 'Diamond', 'Syndicate Boss'];
    return ranks[rankTier.clamp(0, ranks.length - 1)];
  }

  FamilyApplication copyWith({
    ApplicationStatus? status,
    String? reviewedBy,
    DateTime? reviewedAt,
  }) {
    return FamilyApplication(
      id: id,
      applicantId: applicantId,
      applicantName: applicantName,
      familyId: familyId,
      rankTier: rankTier,
      rankPoints: rankPoints,
      winRate: winRate,
      totalGames: totalGames,
      trustRating: trustRating,
      popularityScore: popularityScore,
      mostPlayedRole: mostPlayedRole,
      previousFamilyName: previousFamilyName,
      status: status ?? this.status,
      submittedAt: submittedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }
}
