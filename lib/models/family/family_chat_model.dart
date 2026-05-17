/// Chat message type
enum ChatMessageType {
  text,
  system,
  announcement;
}

/// Chat reaction
class ChatReaction {
  final String emoji;
  final List<String> userIds;

  const ChatReaction({required this.emoji, this.userIds = const []});
}

/// Family chat message
class FamilyChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final ChatMessageType type;
  final DateTime timestamp;
  final bool isPinned;
  final List<String> mentions;
  final List<ChatReaction> reactions;

  const FamilyChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    this.type = ChatMessageType.text,
    required this.timestamp,
    this.isPinned = false,
    this.mentions = const [],
    this.reactions = const [],
  });

  bool get isSystem => type == ChatMessageType.system;
  bool get isAnnouncement => type == ChatMessageType.announcement;

  FamilyChatMessage copyWith({
    bool? isPinned,
    List<ChatReaction>? reactions,
  }) {
    return FamilyChatMessage(
      id: id,
      senderId: senderId,
      senderName: senderName,
      content: content,
      type: type,
      timestamp: timestamp,
      isPinned: isPinned ?? this.isPinned,
      mentions: mentions,
      reactions: reactions ?? this.reactions,
    );
  }
}
