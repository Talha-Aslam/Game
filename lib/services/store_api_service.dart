import 'http_service.dart';

class StoreApiService {
  final HttpService _http = HttpService();

  Future<bool> purchaseItem(String itemId, String currency, int price, String category) async {
    try {
      await _http.post('/store/buy', body: {
        'item_id': itemId,
        'currency': currency,
        'price': price,
        'category': category,
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}
