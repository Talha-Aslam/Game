import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mafia_wars/providers/game_provider.dart';
import '../models/social/party_model.dart';
import '../models/social/friend_model.dart';
import '../services/party_service.dart';
import '../services/websocket_service.dart';

final partyServiceProvider = Provider<PartyService>((ref) => PartyService());

class PartyState {
  final PartyModel? currentParty;
  final List<PartyInviteModel> incomingInvites;
  final bool isLoading;

  const PartyState({
    this.currentParty,
    this.incomingInvites = const [],
    this.isLoading = false,
  });

  bool get isInParty => currentParty != null;
  int get inviteCount => incomingInvites
      .where((i) => i.status == PartyInviteStatus.pending)
      .length;

  PartyState copyWith({
    PartyModel? currentParty,
    List<PartyInviteModel>? incomingInvites,
    bool? isLoading,
    bool clearParty = false,
  }) {
    return PartyState(
      currentParty: clearParty ? null : (currentParty ?? this.currentParty),
      incomingInvites: incomingInvites ?? this.incomingInvites,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class PartyNotifier extends Notifier<PartyState> {
  @override
  PartyState build() {
    _loadInvites();
    return const PartyState(isLoading: true);
  }

  PartyService get _service => ref.read(partyServiceProvider);

  Future<void> _loadInvites() async {
    final invites = await _service.getIncomingInvites();
    state = state.copyWith(incomingInvites: invites, isLoading: false);
  }

  Future<void> createParty({String gameMode = 'casual'}) async {
    final party = await _service.createParty(gameMode: gameMode);
    state = state.copyWith(currentParty: party);
  }

  Future<void> inviteFriend(FriendModel friend) async {
    ref.read(wsServiceProvider).send('party_invite', {'targetId': friend.id});
    await _service.inviteFriendToParty(friend);
    final party = await _service.getCurrentParty();
    state = state.copyWith(currentParty: party);
  }

  Future<void> acceptInvite(String inviteId) async {
    await _service.acceptPartyInvite(inviteId);
    final party = await _service.getCurrentParty();
    final invites = await _service.getIncomingInvites();
    state = state.copyWith(currentParty: party, incomingInvites: invites);
  }

  Future<void> rejectInvite(String inviteId) async {
    await _service.rejectPartyInvite(inviteId);
    final invites = await _service.getIncomingInvites();
    state = state.copyWith(incomingInvites: invites);
  }

  Future<void> leaveParty() async {
    await _service.leaveParty();
    state = state.copyWith(clearParty: true);
  }

  Future<void> toggleReady() async {
    await _service.toggleReady();
    final party = await _service.getCurrentParty();
    state = state.copyWith(currentParty: party);
  }

  Future<void> refresh() async => _loadInvites();
}

final partyProvider = NotifierProvider<PartyNotifier, PartyState>(
  PartyNotifier.new,
);

final partyInviteCountProvider = Provider<int>((ref) {
  return ref.watch(partyProvider).inviteCount;
});
