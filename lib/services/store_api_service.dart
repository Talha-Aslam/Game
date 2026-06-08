import 'http_service.dart';

class StoreApiService {
  final HttpService _http = HttpService();

  Future<Map<String, dynamic>?> purchaseItem(String itemId, String currency, int price, String category) async {
    try {
      final response = await _http.post('/store/buy', body: {
        'item_id': itemId,
        'currency': currency,
        'price': price,
        'category': category,
      });
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> equipItem(String itemId, String category) async {
    try {
      final response = await _http.post('/store/equip', body: {
        'item_id': itemId,
        'category': category,
      });
      return response as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }
}
