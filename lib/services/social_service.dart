import 'dart:async';
import 'dart:math';
import '../models/social/friend_model.dart';
import '../models/social/friend_request_model.dart';
import '../models/social/popularity_model.dart';

/// Mock social service simulating friend management
class SocialService {
  final _rng = Random(42);
  late List<FriendModel> _friends;
  final List<FriendRequestModel> _requests = [];
  final List<FriendModel> _recentPlayers = [];
  final Set<String> _blockedIds = {};

  SocialService() {
    _friends = _generateMockFriends();
    _requests.addAll(_generateMockRequests());
    _recentPlayers.addAll(_generateRecentPlayers());
  }

  // ── Friends List ──

  Future<List<FriendModel>> getFriends() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(
      _friends.where((f) => !_blockedIds.contains(f.id)),
    );
  }

  Future<List<FriendModel>> getOnlineFriends() async {
    final all = await getFriends();
    return all.where((f) => f.isOnline).toList();
  }

  Future<int> getOnlineFriendCount() async {
    final online = await getOnlineFriends();
    return online.length;
  }

  // ── Friend Requests ──

  Future<List<FriendRequestModel>> getFriendRequests() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(
      _requests.where((r) => r.status == FriendRequestStatus.pending),
    );
  }

  Future<int> getPendingRequestCount() async {
    final pending = await getFriendRequests();
    return pending.where((r) => r.isIncoming).length;
  }

  Future<void> sendFriendRequest(String targetUserId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _requests.add(FriendRequestModel(
      id: 'req_${DateTime.now().millisecondsSinceEpoch}',
      fromUser: const FriendModel(id: 'local_user', username: 'You'),
      toUserId: targetUserId,
      timestamp: DateTime.now(),
      isIncoming: false,
    ));
  }

  Future<void> acceptFriendRequest(String requestId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _requests.indexWhere((r) => r.id == requestId);
    if (idx != -1) {
      final req = _requests[idx];
      _requests[idx] = req.copyWith(status: FriendRequestStatus.accepted);
      // Add to friends list
      _friends.add(req.fromUser.copyWith(
        onlineStatus: OnlineStatus.online,
        currentActivity: PlayerActivity.idle,
      ));
    }
  }

  Future<void> rejectFriendRequest(String requestId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _requests.indexWhere((r) => r.id == requestId);
    if (idx != -1) {
      _requests[idx] = _requests[idx].copyWith(
        status: FriendRequestStatus.rejected,
      );
    }
  }

  Future<void> cancelFriendRequest(String requestId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _requests.indexWhere((r) => r.id == requestId);
    if (idx != -1) {
      _requests[idx] = _requests[idx].copyWith(
        status: FriendRequestStatus.cancelled,
      );
    }
  }

  // ── Block ──

  Future<void> blockUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _blockedIds.add(userId);
    _friends.removeWhere((f) => f.id == userId);
  }

  // ── Recent Players ──

  Future<List<FriendModel>> getRecentPlayers() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_recentPlayers);
  }

  // ── Search ──

  Future<List<FriendModel>> searchUsers(String query) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (query.trim().isEmpty) return [];
    final lq = query.toLowerCase();
    final allKnown = [..._friends, ..._recentPlayers];
    return allKnown.where((u) {
      return u.username.toLowerCase().contains(lq) ||
          u.id.toLowerCase().contains(lq);
    }).toList();
  }

  // ── Remove Friend ──

  Future<void> removeFriend(String friendId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _friends.removeWhere((f) => f.id == friendId);
  }

  // ── Mock Data Generators ──

  List<FriendModel> _generateMockFriends() {
    final names = [
      'ShadowKing', 'NightViper', 'IronFist', 'GhostWalker',
      'RedPhantom', 'DarkOracle', 'SilverBlade', 'CrimsonEye',
      'StormBringer', 'VenomStrike', 'BladeRunner', 'NeonWraith',
      'DeathWhisper', 'FrostBite', 'ThunderBolt', 'PhantomAce',
    ];

    final statuses = OnlineStatus.values;
    final activities = PlayerActivity.values;
    final tags = [null, '[COBRA]', '[VENOM]', '[GHOST]', '[BLAZE]', null];

    return List.generate(names.length, (i) {
      final isOnline = _rng.nextDouble() < 0.45;
      return FriendModel(
        id: 'friend_$i',
        username: names[i],
        rankTier: _rng.nextInt(5),
        familyTag: tags[i % tags.length],
        familyName: tags[i % tags.length] != null
            ? 'Family ${tags[i % tags.length]}'
            : null,
        popularityScore: _rng.nextInt(6000),
        popularityRank: PopularityRank
            .fromScore(_rng.nextInt(6000))
            .displayName,
        onlineStatus: isOnline
            ? statuses[_rng.nextInt(4)] // skip offline
                .index == 1
                ? OnlineStatus.online
                : statuses[_rng.nextInt(statuses.length - 1) + 1 == 1
                    ? 0
                    : _rng.nextInt(4)]
            : OnlineStatus.offline,
        currentActivity: isOnline
            ? activities[_rng.nextInt(activities.length)]
            : PlayerActivity.idle,
        lastSeen: !isOnline
            ? DateTime.now().subtract(Duration(
                minutes: _rng.nextInt(1440),
              ))
            : null,
        mutualFriendCount: _rng.nextInt(8),
      );
    });
  }

  List<FriendRequestModel> _generateMockRequests() {
    final requesters = [
      const FriendModel(
        id: 'req_user_1',
        username: 'MidnightRogue',
        rankTier: 3,
        familyTag: '[SHADOW]',
        popularityScore: 1200,
      ),
      const FriendModel(
        id: 'req_user_2',
        username: 'CyberNinja',
        rankTier: 2,
        popularityScore: 450,
      ),
      const FriendModel(
        id: 'req_user_3',
        username: 'ViperQueen',
        rankTier: 4,
        familyTag: '[VENOM]',
        popularityScore: 3200,
      ),
    ];

    return List.generate(requesters.length, (i) {
      return FriendRequestModel(
        id: 'req_$i',
        fromUser: requesters[i],
        toUserId: 'local_user',
        timestamp: DateTime.now().subtract(Duration(hours: i * 2 + 1)),
        mutualFriendCount: _rng.nextInt(5),
        isIncoming: i < 2, // first 2 incoming, last outgoing
      );
    });
  }

  List<FriendModel> _generateRecentPlayers() {
    final names = [
      'ZeroGravity', 'SteelNerve', 'QuickDraw', 'SilentKill',
      'RapidFire', 'NightShade', 'IcePick', 'FlameWard',
      'ToxicBlade', 'ShadowHawk', 'BulletProof', 'GrimReaper',
      'SnakeEyes', 'GoldFinger', 'HotShot', 'WildCard',
      'AceSpade', 'DeadShot', 'KnightOwl', 'BlitzKrieg',
    ];

    return List.generate(min(20, names.length), (i) {
      return FriendModel(
        id: 'recent_$i',
        username: names[i],
        rankTier: _rng.nextInt(5),
        familyTag: i % 4 == 0 ? '[WOLF]' : null,
        popularityScore: _rng.nextInt(3000),
        onlineStatus: _rng.nextDouble() < 0.3
            ? OnlineStatus.online
            : OnlineStatus.offline,
        lastSeen: DateTime.now().subtract(Duration(
          hours: _rng.nextInt(24),
        )),
      );
    });
  }
}
