import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/social/friend_model.dart';
import '../models/social/friend_request_model.dart';
import '../services/social_service.dart';

// ── Service Provider ──
final socialServiceProvider = Provider<SocialService>((ref) => SocialService());

// ── State Classes ──

class FriendsState {
  final List<FriendModel> allFriends;
  final List<FriendModel> onlineFriends;
  final List<FriendRequestModel> pendingRequests;
  final List<FriendModel> recentPlayers;
  final List<FriendModel> searchResults;
  final bool isLoading;
  final String? error;

  const FriendsState({
    this.allFriends = const [],
    this.onlineFriends = const [],
    this.pendingRequests = const [],
    this.recentPlayers = const [],
    this.searchResults = const [],
    this.isLoading = false,
    this.error,
  });

  int get pendingIncomingCount =>
      pendingRequests.where((r) => r.isIncoming).length;

  int get onlineCount => onlineFriends.length;

  FriendsState copyWith({
    List<FriendModel>? allFriends,
    List<FriendModel>? onlineFriends,
    List<FriendRequestModel>? pendingRequests,
    List<FriendModel>? recentPlayers,
    List<FriendModel>? searchResults,
    bool? isLoading,
    String? error,
  }) {
    return FriendsState(
      allFriends: allFriends ?? this.allFriends,
      onlineFriends: onlineFriends ?? this.onlineFriends,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      recentPlayers: recentPlayers ?? this.recentPlayers,
      searchResults: searchResults ?? this.searchResults,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ── Notifier ──

class FriendsNotifier extends Notifier<FriendsState> {
  @override
  FriendsState build() {
    _loadAll();
    return const FriendsState(isLoading: true);
  }

  SocialService get _service => ref.read(socialServiceProvider);

  Future<void> _loadAll() async {
    try {
      final friends = await _service.getFriends();
      final online = await _service.getOnlineFriends();
      final requests = await _service.getFriendRequests();
      final recent = await _service.getRecentPlayers();
      state = state.copyWith(
        allFriends: friends,
        onlineFriends: online,
        pendingRequests: requests,
        recentPlayers: recent,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async => _loadAll();

  Future<void> sendFriendRequest(String userId) async {
    await _service.sendFriendRequest(userId);
    final requests = await _service.getFriendRequests();
    state = state.copyWith(pendingRequests: requests);
  }

  Future<void> acceptRequest(String requestId) async {
    await _service.acceptFriendRequest(requestId);
    await _loadAll();
  }

  Future<void> rejectRequest(String requestId) async {
    await _service.rejectFriendRequest(requestId);
    final requests = await _service.getFriendRequests();
    state = state.copyWith(pendingRequests: requests);
  }

  Future<void> cancelRequest(String requestId) async {
    await _service.cancelFriendRequest(requestId);
    final requests = await _service.getFriendRequests();
    state = state.copyWith(pendingRequests: requests);
  }

  Future<void> blockUser(String userId) async {
    await _service.blockUser(userId);
    await _loadAll();
  }

  Future<void> removeFriend(String friendId) async {
    await _service.removeFriend(friendId);
    await _loadAll();
  }

  Future<void> searchUsers(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(searchResults: []);
      return;
    }
    final results = await _service.searchUsers(query);
    state = state.copyWith(searchResults: results);
  }

  void clearSearch() {
    state = state.copyWith(searchResults: []);
  }
}

// ── Provider ──

final friendsProvider = NotifierProvider<FriendsNotifier, FriendsState>(
  FriendsNotifier.new,
);

// ── Derived Providers ──

final onlineFriendCountProvider = Provider<int>((ref) {
  return ref.watch(friendsProvider).onlineCount;
});

final pendingRequestCountProvider = Provider<int>((ref) {
  return ref.watch(friendsProvider).pendingIncomingCount;
});

final hasNotificationsProvider = Provider<bool>((ref) {
  final friends = ref.watch(friendsProvider);
  return friends.pendingIncomingCount > 0;
});
