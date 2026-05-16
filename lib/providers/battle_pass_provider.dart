import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/battle_pass_model.dart';

class BattlePassNotifier extends Notifier<BattlePassModel> {
  @override
  BattlePassModel build() => _mockBattlePass;

  static final BattlePassModel _mockBattlePass = BattlePassModel(
    currentTier: 23,
    maxTier: 50,
    currentXP: 750,
    xpToNextTier: 1000,
    isPremium: true,
    tiers: List.generate(50, (i) {
      return BattlePassTier(
        tier: i + 1,
        freeReward: BattlePassReward(
          id: 'free_$i',
          name: i % 5 == 0 ? 'Card Style ${i + 1}' : '${(i + 1) * 100} IP',
          type: i % 5 == 0 ? RewardType.cardStyle : RewardType.influencePoints,
          currencyAmount: i % 5 != 0 ? (i + 1) * 100 : null,
        ),
        premiumReward: BattlePassReward(
          id: 'prem_$i',
          name: i % 3 == 0
              ? 'Elite Border ${i + 1}'
              : i % 3 == 1
                  ? 'Elim FX ${i + 1}'
                  : '${(i + 1) * 50} SC',
          type: i % 3 == 0
              ? RewardType.borderEffect
              : i % 3 == 1
                  ? RewardType.eliminationEffect
                  : RewardType.syndicateCoins,
        ),
        isUnlocked: i < 23,
        isClaimed: i < 20,
      );
    }),
  );

  void claimReward(int tier) {
    final tiers = List<BattlePassTier>.from(state.tiers);
    final idx = tiers.indexWhere((t) => t.tier == tier);
    if (idx != -1) {
      tiers[idx] = BattlePassTier(
        tier: tiers[idx].tier,
        freeReward: tiers[idx].freeReward,
        premiumReward: tiers[idx].premiumReward,
        isUnlocked: tiers[idx].isUnlocked,
        isClaimed: true,
      );
      state = state.copyWith(tiers: tiers);
    }
  }
}

final battlePassProvider =
    NotifierProvider<BattlePassNotifier, BattlePassModel>(BattlePassNotifier.new);
