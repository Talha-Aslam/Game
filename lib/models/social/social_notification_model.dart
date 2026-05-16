/// Social notification types
enum SocialNotificationType {
  friendOnline,
  friendRequest,
  partyInvite,
  familyInvite,
  letsPlay,
  giftReceived,
  matchReady,
  seasonalEvent;

  String get displayName {
    switch (this) {
      case SocialNotificationType.friendOnline:
        return 'Friend Online';
      case SocialNotificationType.friendRequest:
        return 'Friend Request';
      case SocialNotificationType.partyInvite:
        return 'Party Invite';
      case SocialNotificationType.familyInvite:
        return 'Family Invite';
      case SocialNotificationType.letsPlay:
        return "Let's Play";
      case SocialNotificationType.giftReceived:
        return 'Gift Received';
      case SocialNotificationType.matchReady:
        return 'Match Ready';
      case SocialNotificationType.seasonalEvent:
        return 'Seasonal Event';
    }
  }
}

/// Social notification model
class SocialNotification {
  final String id;
  final SocialNotificationType type;
  final String title;
  final String body;
  final String? fromUserId;
  final String? fromUsername;
  final String? fromAvatarUrl;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic> actionData;

  const SocialNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.fromUserId,
    this.fromUsername,
    this.fromAvatarUrl,
    required this.timestamp,
    this.isRead = false,
    this.actionData = const {},
  });

  SocialNotification copyWith({
    String? id,
    SocialNotificationType? type,
    String? title,
    String? body,
    String? fromUserId,
    String? fromUsername,
    String? fromAvatarUrl,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? actionData,
  }) {
    return SocialNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      fromUserId: fromUserId ?? this.fromUserId,
      fromUsername: fromUsername ?? this.fromUsername,
      fromAvatarUrl: fromAvatarUrl ?? this.fromAvatarUrl,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      actionData: actionData ?? this.actionData,
    );
  }
}
