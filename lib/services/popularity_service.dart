import 'dart:async';
import '../models/social/popularity_model.dart';
import 'user_api_service.dart';
import 'auth_service.dart';

/// Popularity / gifting service backed by FastAPI
class PopularityService {
  final UserApiService _api = UserApiService();
  final AuthService _auth = AuthService();

  Future<PopularityProfile> getProfile() async {
    // For now, load from current authenticated user, eventually we'll need an endpoint to get the full PopularityProfile including supporters.
    final user = await _auth.fetchProfile();
    final score = user?.popularityScore ?? 0;
    return PopularityProfile(
      totalScore: score,
      rank: PopularityRank.fromScore(score),
      dailyFreeRemaining: 5,
      dailyFreeMax: 5,
      topSupporters: [], // Mocked for now until we build the history tables
    );
  }

  Future<bool> sendFreePopularity(String toUserId, PopularityGift gift) async {
    try {
      if (gift.isPremium) return false;
      await _api.giftPopularity(toUserId, gift.value);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> sendPremiumPopularity(
    String toUserId,
    PopularityGift gift,
    int availableCoins,
  ) async {
    try {
      if (!gift.isPremium || availableCoins < gift.cost) return false;
      await _api.giftPopularity(toUserId, gift.value);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> receivePopularity(int points) async {
    // Usually updated via websockets or push, for now we just rely on fetchProfile.
    await _auth.fetchProfile();
  }

  Future<List<GiftTransaction>> getGiftHistory() async {
    // Backend doesn't support transaction history yet. Returning empty list.
    return [];
  }
}
