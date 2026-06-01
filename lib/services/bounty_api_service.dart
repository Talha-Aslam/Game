import '../models/bounty_model.dart';
import 'http_service.dart';

class BountyApiService {
  final HttpService _http = HttpService();

  Future<List<BountyModel>> getDailyBounties() async {
    try {
      final response = await _http.get('/bounties/daily');
      final List bountiesList = response['bounties'];
      return bountiesList.map((e) => BountyModel.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> claimBounty(String bountyId) async {
    try {
      final response = await _http.post('/bounties/$bountyId/claim');
      return response != null;
    } catch (e) {
      return false;
    }
  }
}
