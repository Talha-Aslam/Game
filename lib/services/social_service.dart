import 'dart:async';
import '../models/social/friend_model.dart';
import '../models/social/friend_request_model.dart';
import '../models/social/private_chat_message.dart';
import 'social_api_service.dart';

/// Social service backed by FastAPI
class SocialService {
  final SocialApiService _api = SocialApiService();

  // ── Friends List ──

  Future<List<FriendModel>> getFriends() async {
    try {
      final data = await _api.getFriends();
      return data.map((json) => _friendFromJson(json)).toList();
    } catch (_) {
      return [];
    }
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
    try {
      final data = await _api.getFriendRequests();
      return data.map((json) => _requestFromJson(json)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<int> getPendingRequestCount() async {
    final pending = await getFriendRequests();
    return pending.where((r) => r.isIncoming).length;
  }

  Future<void> sendFriendRequest(String targetUserId) async {
    await _api.sendFriendRequest(targetUserId);
  }

  Future<void> acceptFriendRequest(String requestId) async {
    await _api.acceptFriendRequest(requestId);
  }

  Future<void> rejectFriendRequest(String requestId) async {
    await _api.rejectFriendRequest(requestId);
  }

  Future<void> cancelFriendRequest(String requestId) async {
    await _api.rejectFriendRequest(requestId);
  }

  // ── Leaderboard ──

  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 50}) async {
    return await _api.getLeaderboard(limit: limit);
  }

  // ── Private Chat ──

  Future<List<PrivateChatMessage>> getPrivateChatHistory(String friendId, {int limit = 50}) async {
    try {
      final data = await _api.getPrivateChatHistory(friendId, limit: limit);
      return data.map((json) => PrivateChatMessage.fromJson(json)).toList();
    } catch (_) {
      return [];
    }
  }

  // ── Block ──

  Future<void> blockUser(String userId) async {
    await _api.removeFriend(userId);
  }

  // ── Recent Players ──

  Future<List<FriendModel>> getRecentPlayers() async {
    // No dedicated backend endpoint yet — return empty
    return [];
  }

  // ── Search ──

  Future<List<FriendModel>> searchUsers(String query) async {
    try {
      final data = await _api.searchUsers(query);
      return data.map((json) => _friendFromJson(json)).toList();
    } catch (_) {
      return [];
    }
  }

  // ── Remove Friend ──

  Future<void> removeFriend(String friendId) async {
    await _api.removeFriend(friendId);
  }

  // ── JSON Converters ──

  FriendModel _friendFromJson(Map<String, dynamic> json) {
    return FriendModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      avatarUrl: json['avatarUrl'] ?? json['avatar_url'] ?? '',
      rankTier: json['rankTier'] ?? json['rank_tier'] ?? 0,
      familyTag: json['familyTag'] ?? json['family_tag'],
      familyName: json['familyName'] ?? json['family_name'],
      popularityScore: json['popularityScore'] ?? json['popularity_score'] ?? 0,
      onlineStatus: _parseOnlineStatus(json['onlineStatus'] ?? json['online_status'] ?? 'offline'),
      currentActivity: _parseActivity(json['currentActivity'] ?? json['current_activity'] ?? 'idle'),
      mutualFriendCount: json['mutualFriendCount'] ?? json['mutual_friend_count'] ?? 0,
    );
  }

  FriendRequestModel _requestFromJson(Map<String, dynamic> json) {
    final fromUser = json['fromUser'] ?? json['from_user'] ?? {};
    return FriendRequestModel(
      id: json['id'] ?? '',
      fromUser: _friendFromJson(Map<String, dynamic>.from(fromUser)),
      toUserId: json['toUserId'] ?? json['to_user_id'] ?? '',
      status: _parseRequestStatus(json['status'] ?? 'pending'),
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      mutualFriendCount: json['mutualFriendCount'] ?? json['mutual_friend_count'] ?? 0,
      isIncoming: json['isIncoming'] ?? json['is_incoming'] ?? true,
    );
  }

  OnlineStatus _parseOnlineStatus(String s) {
    switch (s.toLowerCase()) {
      case 'online': return OnlineStatus.online;
      case 'inmatch': case 'in_match': return OnlineStatus.inMatch;
      case 'infamilylobby': case 'in_family_lobby': return OnlineStatus.inFamilyLobby;
      case 'busy': return OnlineStatus.busy;
      case 'donotdisturb': case 'do_not_disturb': return OnlineStatus.doNotDisturb;
      default: return OnlineStatus.offline;
    }
  }

  PlayerActivity _parseActivity(String s) {
    switch (s.toLowerCase()) {
      case 'inlobby': case 'in_lobby': return PlayerActivity.inLobby;
      case 'inmatch': case 'in_match': return PlayerActivity.inMatch;
      case 'lookingforteam': case 'looking_for_team': return PlayerActivity.lookingForTeam;
      case 'instore': case 'in_store': return PlayerActivity.inStore;
      case 'inbattlepass': case 'in_battle_pass': return PlayerActivity.inBattlePass;
      default: return PlayerActivity.idle;
    }
  }

  FriendRequestStatus _parseRequestStatus(String s) {
    switch (s.toLowerCase()) {
      case 'accepted': return FriendRequestStatus.accepted;
      case 'rejected': return FriendRequestStatus.rejected;
      case 'cancelled': return FriendRequestStatus.cancelled;
      default: return FriendRequestStatus.pending;
    }
  }
}
