import 'friend_model.dart';

/// Status of a friend request
enum FriendRequestStatus {
  pending,
  accepted,
  rejected,
  cancelled;

  String get displayName {
    switch (this) {
      case FriendRequestStatus.pending:
        return 'Pending';
      case FriendRequestStatus.accepted:
        return 'Accepted';
      case FriendRequestStatus.rejected:
        return 'Rejected';
      case FriendRequestStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// Friend request model
class FriendRequestModel {
  final String id;
  final FriendModel fromUser;
  final String toUserId;
  final FriendRequestStatus status;
  final DateTime timestamp;
  final int mutualFriendCount;
  final bool isIncoming; // true = received, false = sent

  const FriendRequestModel({
    required this.id,
    required this.fromUser,
    required this.toUserId,
    this.status = FriendRequestStatus.pending,
    required this.timestamp,
    this.mutualFriendCount = 0,
    this.isIncoming = true,
  });

  FriendRequestModel copyWith({
    String? id,
    FriendModel? fromUser,
    String? toUserId,
    FriendRequestStatus? status,
    DateTime? timestamp,
    int? mutualFriendCount,
    bool? isIncoming,
  }) {
    return FriendRequestModel(
      id: id ?? this.id,
      fromUser: fromUser ?? this.fromUser,
      toUserId: toUserId ?? this.toUserId,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      mutualFriendCount: mutualFriendCount ?? this.mutualFriendCount,
      isIncoming: isIncoming ?? this.isIncoming,
    );
  }
}
