import 'http_service.dart';

class PaymentApiService {
  final HttpService _http = HttpService();

  Future<Map<String, dynamic>?> getPackages() async {
    try {
      final response = await _http.get('/payment/packages');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<Map<String, dynamic>?> processPayment({
    required String packageId,
    required double price,
    required String transactionId,
    required String statusCode,
  }) async {
    try {
      final response = await _http.post('/payment/process', body: {
        'package_id': packageId,
        'price': price,
        'transaction_id': transactionId,
        'status_code': statusCode,
      });
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<List<dynamic>?> getHistory() async {
    try {
      final response = await _http.get('/payment/history');
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}
