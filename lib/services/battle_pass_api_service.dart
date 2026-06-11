import 'http_service.dart';

class BattlePassApiService {
  final HttpService _http = HttpService();

  Future<Map<String, dynamic>?> getSeasonInfo() async {
    try {
      final response = await _http.get('/battlepass/season');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<bool> claimTier(int tier, bool isPremium) async {
    try {
      await _http.post('/battlepass/claim', body: {
        'tier': tier,
        'is_premium': isPremium,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> buyPremiumPass({bool isPremiumPlus = false}) async {
    try {
      await _http.post('/battlepass/buy-premium', body: {
        'is_premium_plus': isPremiumPlus,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> purchaseTiers(int count) async {
    try {
      await _http.post('/battlepass/purchase-tiers', body: {
        'count': count,
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}
