import 'http_service.dart';

class UserApiService {
  final HttpService _http = HttpService();

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _http.get('/user/me');
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _http.put('/user/update', body: data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> giftPopularity(String targetId, int amount) async {
    try {
      await _http.post('/user/gift-popularity/$targetId?amount=$amount');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> uploadAvatar(String filePath) async {
    try {
      final response = await _http.uploadImage('/user/me/avatar', filePath);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
