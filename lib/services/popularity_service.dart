import 'dart:async';
import 'dart:math';
import '../models/social/friend_model.dart';
import '../models/social/popularity_model.dart';

/// Mock popularity / gifting service
class PopularityService {
  final _rng = Random();
  late PopularityProfile _profile;
  final List<GiftTransaction> _giftHistory = [];

  PopularityService() {
    final score = 1250 + _rng.nextInt(2000);
    _profile = PopularityProfile(
      totalScore: score,
      rank: PopularityRank.fromScore(score),
      dailyFreeRemaining: 5,
      dailyFreeMax: 5,
      topSupporters: _generateTopSupporters(),
    );
  }

  Future<PopularityProfile> getProfile() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _profile;
  }

  Future<bool> sendFreePopularity(String toUserId, PopularityGift gift) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (_profile.dailyFreeRemaining <= 0 || gift.isPremium) return false;
    _profile = _profile.copyWith(
      dailyFreeRemaining: _profile.dailyFreeRemaining - 1,
    );
    _giftHistory.add(GiftTransaction(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      fromUser: const FriendModel(id: 'local_user', username: 'You'),
      toUser: FriendModel(id: toUserId, username: 'Friend'),
      gift: gift,
      timestamp: DateTime.now(),
    ));
    return true;
  }

  Future<bool> sendPremiumPopularity(
    String toUserId, PopularityGift gift, int availableCoins,
  ) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (!gift.isPremium || availableCoins < gift.cost) return false;
    _giftHistory.add(GiftTransaction(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      fromUser: const FriendModel(id: 'local_user', username: 'You'),
      toUser: FriendModel(id: toUserId, username: 'Friend'),
      gift: gift,
      timestamp: DateTime.now(),
    ));
    return true;
  }

  Future<void> receivePopularity(int points) async {
    final newScore = _profile.totalScore + points;
    _profile = _profile.copyWith(
      totalScore: newScore,
      rank: PopularityRank.fromScore(newScore),
    );
  }

  Future<List<GiftTransaction>> getGiftHistory() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_giftHistory);
  }

  List<FriendModel> _generateTopSupporters() {
    final names = ['GhostWalker', 'NightViper', 'IronFist', 'DarkOracle'];
    return List.generate(names.length, (i) => FriendModel(
      id: 'supporter_$i',
      username: names[i],
      rankTier: 2 + _rng.nextInt(3),
      popularityScore: 500 + _rng.nextInt(3000),
    ));
  }
}
