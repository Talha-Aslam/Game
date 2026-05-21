import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'http_service.dart';

class AuthApiService {
  final HttpService _http = HttpService();
  final _storage = const FlutterSecureStorage();

  Future<bool> login(String email, String password) async {
    try {
      final response = await _http.post('/auth/login', body: {
        'email': email,
        'password': password,
      });
      final token = response['access_token'];
      if (token != null) {
        await _storage.write(key: 'jwt_token', value: token);
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> register(String username, String email, String password) async {
    try {
      final response = await _http.post('/auth/register', body: {
        'username': username,
        'email': email,
        'password': password,
      });
      final token = response['access_token'];
      if (token != null) {
        await _storage.write(key: 'jwt_token', value: token);
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'jwt_token');
    return token != null;
  }
}
