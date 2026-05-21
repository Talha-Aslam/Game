import 'http_service.dart';

class BattlePassApiService {
  final HttpService _http = HttpService();

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

  Future<bool> buyPremiumPass() async {
    try {
      await _http.post('/battlepass/buy-premium', body: {});
      return true;
    } catch (e) {
      return false;
    }
  }
}
