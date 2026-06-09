import 'friend_model.dart';

/// Party status
enum PartyStatus {
  forming,
  ready,
  queuing,
  inMatch;

  String get displayName {
    switch (this) {
      case PartyStatus.forming:
        return 'Forming Party';
      case PartyStatus.ready:
        return 'Ready';
      case PartyStatus.queuing:
        return 'In Queue';
      case PartyStatus.inMatch:
        return 'In Match';
    }
  }
}

/// Party member with ready state
class PartyMember {
  final FriendModel player;
  final bool isReady;
  final bool isLeader;
  final bool isVoiceConnected;

  const PartyMember({
    required this.player,
    this.isReady = false,
    this.isLeader = false,
    this.isVoiceConnected = false,
  });

  PartyMember copyWith({
    FriendModel? player,
    bool? isReady,
    bool? isLeader,
    bool? isVoiceConnected,
  }) {
    return PartyMember(
      player: player ?? this.player,
      isReady: isReady ?? this.isReady,
      isLeader: isLeader ?? this.isLeader,
      isVoiceConnected: isVoiceConnected ?? this.isVoiceConnected,
    );
  }
}

/// Party chat message
class PartyChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime timestamp;

  const PartyChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
  });
}

/// Party lobby model
class PartyModel {
  final String id;
  final String leaderId;
  final List<PartyMember> members;
  final int maxSize;
  final PartyStatus status;
  final String gameMode; // 'ranked'
  final List<PartyChatMessage> chatMessages;

  const PartyModel({
    required this.id,
    required this.leaderId,
    this.members = const [],
    this.maxSize = 8,
    this.status = PartyStatus.forming,
    this.gameMode = 'ranked',
    this.chatMessages = const [],
  });

  bool get isFull => members.length >= maxSize;
  bool get allReady => members.every((m) => m.isReady);
  int get readyCount => members.where((m) => m.isReady).length;

  PartyModel copyWith({
    String? id,
    String? leaderId,
    List<PartyMember>? members,
    int? maxSize,
    PartyStatus? status,
    String? gameMode,
    List<PartyChatMessage>? chatMessages,
  }) {
    return PartyModel(
      id: id ?? this.id,
      leaderId: leaderId ?? this.leaderId,
      members: members ?? this.members,
      maxSize: maxSize ?? this.maxSize,
      status: status ?? this.status,
      gameMode: gameMode ?? this.gameMode,
      chatMessages: chatMessages ?? this.chatMessages,
    );
  }
}

/// Party invite status
enum PartyInviteStatus {
  pending,
  accepted,
  rejected,
  expired;
}

/// Party invite model
class PartyInviteModel {
  final String id;
  final String partyId;
  final FriendModel fromUser;
  final String toUserId;
  final PartyInviteStatus status;
  final DateTime timestamp;
  final int currentPartySize;
  final int maxPartySize;
  final String gameMode;

  const PartyInviteModel({
    required this.id,
    required this.partyId,
    required this.fromUser,
    required this.toUserId,
    this.status = PartyInviteStatus.pending,
    required this.timestamp,
    this.currentPartySize = 1,
    this.maxPartySize = 8,
    this.gameMode = 'ranked',
  });

  bool get isExpired =>
      DateTime.now().difference(timestamp).inSeconds > 30;

  PartyInviteModel copyWith({
    String? id,
    String? partyId,
    FriendModel? fromUser,
    String? toUserId,
    PartyInviteStatus? status,
    DateTime? timestamp,
    int? currentPartySize,
    int? maxPartySize,
    String? gameMode,
  }) {
    return PartyInviteModel(
      id: id ?? this.id,
      partyId: partyId ?? this.partyId,
      fromUser: fromUser ?? this.fromUser,
      toUserId: toUserId ?? this.toUserId,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      currentPartySize: currentPartySize ?? this.currentPartySize,
      maxPartySize: maxPartySize ?? this.maxPartySize,
      gameMode: gameMode ?? this.gameMode,
    );
  }
}
