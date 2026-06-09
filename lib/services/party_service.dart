import 'dart:async';
import 'dart:math';
import '../models/social/friend_model.dart';
import '../models/social/party_model.dart';

/// Mock party service simulating party lobby system
class PartyService {
  final _rng = Random();
  PartyModel? _currentParty;
  final List<PartyInviteModel> _incomingInvites = [];
  final _inviteController = StreamController<PartyInviteModel>.broadcast();

  Stream<PartyInviteModel> get inviteStream => _inviteController.stream;

  PartyService() {
    // Simulate incoming invites periodically
    _simulateIncomingInvites();
  }

  // ── Party Management ──

  Future<PartyModel> createParty({String gameMode = 'ranked'}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentParty = PartyModel(
      id: 'party_${DateTime.now().millisecondsSinceEpoch}',
      leaderId: 'local_user',
      members: [
        const PartyMember(
          player: FriendModel(id: 'local_user', username: 'You', rankTier: 2),
          isLeader: true,
          isReady: true,
          isVoiceConnected: true,
        ),
      ],
      gameMode: gameMode,
    );
    return _currentParty!;
  }

  Future<PartyModel?> getCurrentParty() async {
    return _currentParty;
  }

  Future<void> leaveParty() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentParty = null;
  }

  // ── Inviting ──

  Future<void> inviteFriendToParty(FriendModel friend) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_currentParty == null) {
      // Auto-create party
      await createParty();
    }
    // Simulate friend joining after delay
    Future.delayed(Duration(seconds: 1 + _rng.nextInt(3)), () {
      if (_currentParty != null && !_currentParty!.isFull) {
        final members = List<PartyMember>.from(_currentParty!.members);
        members.add(PartyMember(
          player: friend,
          isReady: false,
          isVoiceConnected: _rng.nextBool(),
        ));
        _currentParty = _currentParty!.copyWith(members: members);
      }
    });
  }

  // ── Incoming Invites ──

  Future<List<PartyInviteModel>> getIncomingInvites() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(
      _incomingInvites.where((i) => i.status == PartyInviteStatus.pending),
    );
  }

  Future<void> acceptPartyInvite(String inviteId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _incomingInvites.indexWhere((i) => i.id == inviteId);
    if (idx != -1) {
      _incomingInvites[idx] = _incomingInvites[idx].copyWith(
        status: PartyInviteStatus.accepted,
      );
      // Join the party
      await createParty(gameMode: _incomingInvites[idx].gameMode);
      final members = List<PartyMember>.from(_currentParty!.members);
      members.add(PartyMember(
        player: _incomingInvites[idx].fromUser,
        isLeader: true,
        isReady: true,
        isVoiceConnected: true,
      ));
      _currentParty = _currentParty!.copyWith(
        leaderId: _incomingInvites[idx].fromUser.id,
        members: members,
      );
    }
  }

  Future<void> rejectPartyInvite(String inviteId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _incomingInvites.indexWhere((i) => i.id == inviteId);
    if (idx != -1) {
      _incomingInvites[idx] = _incomingInvites[idx].copyWith(
        status: PartyInviteStatus.rejected,
      );
    }
  }

  // ── Ready System ──

  Future<void> toggleReady() async {
    if (_currentParty == null) return;
    final members = _currentParty!.members.map((m) {
      if (m.player.id == 'local_user') {
        return m.copyWith(isReady: !m.isReady);
      }
      return m;
    }).toList();
    _currentParty = _currentParty!.copyWith(members: members);
  }

  // ── Chat ──

  Future<void> sendChatMessage(String message) async {
    if (_currentParty == null) return;
    final messages = List<PartyChatMessage>.from(_currentParty!.chatMessages);
    messages.add(PartyChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'local_user',
      senderName: 'You',
      message: message,
      timestamp: DateTime.now(),
    ));
    _currentParty = _currentParty!.copyWith(chatMessages: messages);
  }

  // ── Simulation ──

  void _simulateIncomingInvites() {
    // Disabled mock invites so they don't spam the user
  }

  void dispose() {
    _inviteController.close();
  }
}
