import 'http_service.dart';

/// API service for social features (friends, requests, search, leaderboard)
class SocialApiService {
  final HttpService _http = HttpService();

  // ── Friends ──

  Future<List<Map<String, dynamic>>> getFriends() async {
    final data = await _http.get('/social/friends');
    return List<Map<String, dynamic>>.from(data ?? []);
  }

  Future<Map<String, dynamic>?> getPublicProfile(String targetId) async {
    final data = await _http.get('/social/profile/$targetId');
    return data;
  }

  // ── Friend Requests ──

  Future<List<Map<String, dynamic>>> getFriendRequests() async {
    final data = await _http.get('/social/requests');
    return List<Map<String, dynamic>>.from(data ?? []);
  }

  Future<void> sendFriendRequest(String targetUserId) async {
    await _http.post('/social/request/$targetUserId');
  }

  Future<void> acceptFriendRequest(String requestId) async {
    await _http.post('/social/accept/$requestId');
  }

  Future<void> rejectFriendRequest(String requestId) async {
    await _http.post('/social/reject/$requestId');
  }

  Future<void> removeFriend(String friendId) async {
    await _http.delete('/social/friend/$friendId');
  }

  // ── Search ──

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final data = await _http.get('/social/search?query=$query');
    return List<Map<String, dynamic>>.from(data ?? []);
  }

  // ── Leaderboard ──

  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 50}) async {
    final data = await _http.get('/social/leaderboard?limit=$limit');
    return List<Map<String, dynamic>>.from(data ?? []);
  }

  // ── Private Chat ──

  Future<List<Map<String, dynamic>>> getPrivateChatHistory(String friendId, {int limit = 50}) async {
    final data = await _http.get('/social/chat/$friendId?limit=$limit');
    return List<Map<String, dynamic>>.from(data ?? []);
  }

  Future<void> markMessagesRead(String friendId) async {
    await _http.post('/social/chat/$friendId/read');
  }
}
