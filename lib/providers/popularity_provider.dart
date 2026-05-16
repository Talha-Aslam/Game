import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/social/popularity_model.dart';
import '../services/popularity_service.dart';

final popularityServiceProvider = Provider<PopularityService>(
  (ref) => PopularityService(),
);

class PopularityState {
  final PopularityProfile profile;
  final List<GiftTransaction> giftHistory;
  final bool isLoading;
  final bool isSending;

  const PopularityState({
    this.profile = const PopularityProfile(),
    this.giftHistory = const [],
    this.isLoading = false,
    this.isSending = false,
  });

  PopularityState copyWith({
    PopularityProfile? profile,
    List<GiftTransaction>? giftHistory,
    bool? isLoading,
    bool? isSending,
  }) {
    return PopularityState(
      profile: profile ?? this.profile,
      giftHistory: giftHistory ?? this.giftHistory,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
    );
  }
}

class PopularityNotifier extends Notifier<PopularityState> {
  @override
  PopularityState build() {
    _loadProfile();
    return const PopularityState(isLoading: true);
  }

  PopularityService get _service => ref.read(popularityServiceProvider);

  Future<void> _loadProfile() async {
    final profile = await _service.getProfile();
    final history = await _service.getGiftHistory();
    state = state.copyWith(
      profile: profile,
      giftHistory: history,
      isLoading: false,
    );
  }

  Future<bool> sendFreeGift(String toUserId, PopularityGift gift) async {
    state = state.copyWith(isSending: true);
    final success = await _service.sendFreePopularity(toUserId, gift);
    await _loadProfile();
    state = state.copyWith(isSending: false);
    return success;
  }

  Future<bool> sendPremiumGift(
    String toUserId, PopularityGift gift, int availableCoins,
  ) async {
    state = state.copyWith(isSending: true);
    final success = await _service.sendPremiumPopularity(
      toUserId, gift, availableCoins,
    );
    await _loadProfile();
    state = state.copyWith(isSending: false);
    return success;
  }

  Future<void> refresh() async => _loadProfile();
}

final popularityProvider = NotifierProvider<PopularityNotifier, PopularityState>(
  PopularityNotifier.new,
);

final dailyFreeRemainingProvider = Provider<int>((ref) {
  return ref.watch(popularityProvider).profile.dailyFreeRemaining;
});
