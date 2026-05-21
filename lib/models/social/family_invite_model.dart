import 'friend_model.dart';

/// Family invite status
enum FamilyInviteStatus {
  pending,
  accepted,
  rejected,
  expired;
}

/// Family invite model
class FamilyInviteModel {
  final String id;
  final String familyId;
  final String familyName;
  final String familyTag;
  final String familyEmblem; // icon name or asset path
  final FriendModel fromUser;
  final String toUserId;
  final int memberCount;
  final int maxMembers;
  final int familyReputation;
  final int familySeasonPoints;
  final int familyTotalWins;
  final FamilyInviteStatus status;
  final DateTime timestamp;

  const FamilyInviteModel({
    required this.id,
    required this.familyId,
    required this.familyName,
    required this.familyTag,
    this.familyEmblem = 'groups',
    required this.fromUser,
    required this.toUserId,
    this.memberCount = 0,
    this.maxMembers = 50,
    this.familyReputation = 0,
    this.familySeasonPoints = 0,
    this.familyTotalWins = 0,
    this.status = FamilyInviteStatus.pending,
    required this.timestamp,
  });

  bool get isFull => memberCount >= maxMembers;

  FamilyInviteModel copyWith({
    String? id,
    String? familyId,
    String? familyName,
    String? familyTag,
    String? familyEmblem,
    FriendModel? fromUser,
    String? toUserId,
    int? memberCount,
    int? maxMembers,
    int? familyReputation,
    int? familySeasonPoints,
    int? familyTotalWins,
    FamilyInviteStatus? status,
    DateTime? timestamp,
  }) {
    return FamilyInviteModel(
      id: id ?? this.id,
      familyId: familyId ?? this.familyId,
      familyName: familyName ?? this.familyName,
      familyTag: familyTag ?? this.familyTag,
      familyEmblem: familyEmblem ?? this.familyEmblem,
      fromUser: fromUser ?? this.fromUser,
      toUserId: toUserId ?? this.toUserId,
      memberCount: memberCount ?? this.memberCount,
      maxMembers: maxMembers ?? this.maxMembers,
      familyReputation: familyReputation ?? this.familyReputation,
      familySeasonPoints: familySeasonPoints ?? this.familySeasonPoints,
      familyTotalWins: familyTotalWins ?? this.familyTotalWins,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
