import 'http_service.dart';

/// API service for the Family/Syndicate system
class FamilyApiService {
  final HttpService _http = HttpService();

  // ── Family CRUD ──

  Future<Map<String, dynamic>?> getMyFamily() async {
    final data = await _http.get('/family/me');
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  Future<Map<String, dynamic>> createFamily({
    required String name,
    required String tag,
    String description = '',
    String slogan = '',
    String privacy = 'approvalRequired',
  }) async {
    final data = await _http.post('/family/create', body: {
      'name': name,
      'tag': tag,
      'description': description,
      'slogan': slogan,
      'privacy': privacy,
    });
    return Map<String, dynamic>.from(data);
  }

  Future<void> leaveFamily() async {
    await _http.post('/family/leave');
  }

  Future<void> deleteFamily() async {
    await _http.delete('/family/delete');
  }

  // ── Settings ──

  Future<Map<String, dynamic>> updateSettings(Map<String, dynamic> updates) async {
    final data = await _http.put('/family/settings', body: updates);
    return Map<String, dynamic>.from(data);
  }

  // ── Members ──

  Future<void> kickMember(String targetUserId) async {
    await _http.post('/family/kick/$targetUserId');
  }

  Future<void> promoteMember(String targetUserId) async {
    await _http.post('/family/promote/$targetUserId');
  }

  Future<void> demoteMember(String targetUserId) async {
    await _http.post('/family/demote/$targetUserId');
  }

  Future<void> muteMember(String targetUserId) async {
    await _http.post('/family/mute/$targetUserId');
  }

  // ── Treasury ──

  Future<void> donate(int amount) async {
    await _http.post('/family/treasury/donate', body: {'amount': amount});
  }

  // ── Chat ──

  Future<List<Map<String, dynamic>>> getChatMessages() async {
    final data = await _http.get('/family/chat');
    return List<Map<String, dynamic>>.from(data ?? []);
  }

  Future<Map<String, dynamic>> sendChatMessage(String content) async {
    final data = await _http.post('/family/chat', body: {'content': content});
    return Map<String, dynamic>.from(data);
  }

  // ── Search ──

  Future<List<Map<String, dynamic>>> searchFamilies(String query) async {
    final data = await _http.get('/family/search?query=$query');
    return List<Map<String, dynamic>>.from(data ?? []);
  }

  // ── Applications ──

  Future<void> applyToFamily(String familyId, {String message = ''}) async {
    await _http.post('/family/apply/$familyId', body: {'message': message});
  }

  Future<void> acceptApplication(String appId) async {
    await _http.post('/family/applications/$appId/accept');
  }

  Future<void> rejectApplication(String appId) async {
    await _http.post('/family/applications/$appId/reject');
  }

  Future<void> activateBoost(String boostType) async {
    await _http.post('/family/treasury/boost', body: {'boost_type': boostType});
  }

  Future<List<Map<String, dynamic>>> getRivalries() async {
    final data = await _http.get('/family/rivalries');
    return List<Map<String, dynamic>>.from(data ?? []);
  }

  Future<void> transferOwnership(String targetUserId) async {
    await _http.post('/family/transfer_ownership/$targetUserId');
  }

  Future<void> pinMessage(String msgId) async {
    await _http.post('/family/chat/$msgId/pin');
  }

  Future<String> getVoiceToken(String channelName) async {
    final data = await _http.post('/voice/token', body: {'channel_name': channelName, 'role': 1});
    return data['token'] as String;
  }

  Future<List<Map<String, dynamic>>> getAchievements() async {
    final data = await _http.get('/family/achievements');
    return List<Map<String, dynamic>>.from(data ?? []);
  }
}

