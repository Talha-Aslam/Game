import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/battle_pass_model.dart';
import '../services/battle_pass_api_service.dart';
import 'auth_provider.dart';

class BattlePassNotifier extends Notifier<BattlePassModel> {
  final _api = BattlePassApiService();

  @override
  BattlePassModel build() {
    final user = ref.watch(authProvider).user;
    var baseModel = _buildMock();
    
    if (user != null) {
      // Sync with user data
      baseModel = baseModel.copyWith(
        currentTier: user.battlePassTier,
        currentXP: user.battlePassXP,
        isPremium: user.hasPremiumPass,
      );

      final updatedTiers = baseModel.tiers.map((t) {
        return t.copyWith(
          isUnlocked: t.tier <= user.battlePassTier,
          isFreeClaimed: user.claimedFreeTiers.contains(t.tier),
          isPremiumClaimed: user.claimedPremiumTiers.contains(t.tier),
        );
      }).toList();

      baseModel = baseModel.copyWith(tiers: updatedTiers);
    }
    
    return baseModel;
  }

  // ── Claim ──
  Future<void> claimFreeReward(int tier) async {
    final success = await _api.claimTier(tier, false);
    if (success) {
      await ref.read(authServiceProvider).fetchProfile();
      ref.invalidate(authProvider);
    }
  }

  Future<void> claimPremiumReward(int tier) async {
    final success = await _api.claimTier(tier, true);
    if (success) {
      await ref.read(authServiceProvider).fetchProfile();
      ref.invalidate(authProvider);
    }
  }

  /// Backward compat
  void claimReward(int tier) => claimFreeReward(tier);

  // ── Premium ──
  Future<void> purchasePremium() async {
    final success = await _api.buyPremiumPass();
    if (success) {
      await ref.read(authServiceProvider).fetchProfile();
      ref.invalidate(authProvider);
    }
  }

  Future<void> purchasePremiumPlus() async {
    // Left as future work (need another endpoint or param)
    await purchasePremium();
  }

  // ── Tier Purchase ──
  Future<void> purchaseTiers(int count) async {
    // Left as future work
  }

  // ── XP ──
  void addXP(int amount) {
    final boosted = (amount * state.boostMultiplier).round();
    var xp = state.currentXP + boosted;
    var tier = state.currentTier;
    var threshold = state.xpToNextTier;
    final tiers = List<BattlePassTier>.from(state.tiers);

    while (xp >= threshold && tier < state.maxTier) {
      xp -= threshold;
      tier++;
      threshold = 1000 + (tier * 50);
      if (tier - 1 < tiers.length) {
        tiers[tier - 1] = tiers[tier - 1].copyWith(isUnlocked: true);
      }
    }
    state = state.copyWith(
      currentXP: xp, currentTier: tier,
      xpToNextTier: threshold, tiers: tiers,
    );
  }

  // ── Boost ──
  void activateBoost(XPBoostType type) {
    final now = DateTime.now();
    state = state.copyWith(
      activeBoost: XPBoost(
        type: type, activatedAt: now,
        expiresAt: now.add(type.duration),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  //  MOCK DATA
  // ══════════════════════════════════════════════════════

  static BattlePassModel _buildMock() {
    final seasonEnd = DateTime.now().add(const Duration(days: 30));
    const currentTier = 1; // Start new users at Tier 1

    final rewardTable = <_TierDef>[
      _TierDef(1, 'Welcome Pack', RewardType.influencePoints, RewardRarity.common, amt: 200,
        pName: 'Neon Cyan Border', pType: RewardType.animatedBorder, pRarity: RewardRarity.rare),
      _TierDef(2, '150 IP', RewardType.influencePoints, RewardRarity.common, amt: 150,
        pName: 'Shadow Voice', pType: RewardType.voicePack, pRarity: RewardRarity.rare),
      _TierDef(3, 'Basic Nameplate', RewardType.nameplate, RewardRarity.common,
        pName: '200 SC', pType: RewardType.syndicateCoins, pRarity: RewardRarity.common, pAmt: 200),
      _TierDef(4, '200 IP', RewardType.influencePoints, RewardRarity.common, amt: 200,
        pName: 'Card Style: Midnight', pType: RewardType.cardStyle, pRarity: RewardRarity.rare),
      _TierDef(5, 'Card Style: Dawn', RewardType.cardStyle, RewardRarity.common,
        pName: 'Elim FX: Shatter', pType: RewardType.eliminationFX, pRarity: RewardRarity.epic),
      _TierDef(6, '250 IP', RewardType.influencePoints, RewardRarity.common, amt: 250,
        pName: '1h 2X XP Token', pType: RewardType.xpBoostToken, pRarity: RewardRarity.common),
      _TierDef(7, 'Pop Gift: Rose', RewardType.popularityGift, RewardRarity.common,
        pName: 'Avatar: Phantom', pType: RewardType.avatar, pRarity: RewardRarity.rare),
      _TierDef(8, '300 IP', RewardType.influencePoints, RewardRarity.common, amt: 300,
        pName: 'Nameplate: Enforcer', pType: RewardType.nameplate, pRarity: RewardRarity.rare),
      _TierDef(9, '150 SC', RewardType.syndicateCoins, RewardRarity.common, amt: 150,
        pName: 'Family Crest Glow', pType: RewardType.familyCrestFX, pRarity: RewardRarity.epic),
      _TierDef(10, 'Card Style: Blaze', RewardType.cardStyle, RewardRarity.rare,
        pName: 'Elim FX: Inferno', pType: RewardType.eliminationFX, pRarity: RewardRarity.epic),
    ];

    // Generate remaining tiers by cycling patterns
    final allTiers = <BattlePassTier>[];
    for (int i = 0; i < 50; i++) {
      final def = i < rewardTable.length
          ? rewardTable[i]
          : _generateTierDef(i + 1);
      allTiers.add(BattlePassTier(
        tier: i + 1,
        freeReward: BattlePassReward(
          id: 'free_$i', name: def.fName,
          description: '${def.fType.displayName} reward',
          type: def.fType, rarity: def.fRarity,
          currencyAmount: def.fAmt,
        ),
        premiumReward: def.pName != null ? BattlePassReward(
          id: 'prem_$i', name: def.pName!,
          description: '${def.pType!.displayName} — Premium exclusive',
          type: def.pType!, rarity: def.pRarity ?? RewardRarity.rare,
          isPremiumExclusive: true,
          currencyAmount: def.pAmt,
        ) : null,
        isUnlocked: (i + 1) <= currentTier, // Unlocked if tier <= currentTier
        isFreeClaimed: false, // Default unclaimed
        isPremiumClaimed: false, // Default unclaimed
      ));
    }

    return BattlePassModel(
      seasonName: 'Season 1: City of Lies',
      seasonEndDate: seasonEnd,
      currentTier: currentTier,
      maxTier: 50,
      currentXP: 0, // Default 0
      xpToNextTier: 1000,
      isPremium: false, // Default false
      tiers: allTiers,
    );
  }

  static _TierDef _generateTierDef(int tier) {
    final isMilestone = tier % 5 == 0;
    final isLegendary = tier >= 45;
    final freeTypes = [RewardType.influencePoints, RewardType.syndicateCoins,
      RewardType.nameplate, RewardType.popularityGift, RewardType.cardStyle];
    final premTypes = [RewardType.animatedBorder, RewardType.eliminationFX,
      RewardType.voicePack, RewardType.avatar, RewardType.profileBackground,
      RewardType.title, RewardType.familyCrestFX, RewardType.xpBoostToken];

    final ft = freeTypes[tier % freeTypes.length];
    final pt = premTypes[tier % premTypes.length];

    RewardRarity fR, pR;
    if (isLegendary) { fR = RewardRarity.epic; pR = RewardRarity.legendary; }
    else if (isMilestone) { fR = RewardRarity.rare; pR = RewardRarity.epic; }
    else { fR = RewardRarity.common; pR = RewardRarity.rare; }

    final fAmt = ft == RewardType.influencePoints ? (tier * 50) : ft == RewardType.syndicateCoins ? (tier * 20) : null;
    final pAmt = pt == RewardType.syndicateCoins ? (tier * 30) : null;

    return _TierDef(tier,
      ft == RewardType.influencePoints ? '$fAmt IP'
          : ft == RewardType.syndicateCoins ? '$fAmt SC'
          : '${ft.displayName} $tier',
      ft, fR, amt: fAmt,
      pName: pt == RewardType.syndicateCoins ? '$pAmt SC' : '${pt.displayName} $tier',
      pType: pt, pRarity: pR, pAmt: pAmt,
    );
  }
}

class _TierDef {
  final int tier;
  final String fName;
  final RewardType fType;
  final RewardRarity fRarity;
  final int? fAmt;
  final String? pName;
  final RewardType? pType;
  final RewardRarity? pRarity;
  final int? pAmt;
  _TierDef(this.tier, this.fName, this.fType, this.fRarity,
      {int? amt, this.pName, this.pType, this.pRarity, this.pAmt})
      : fAmt = amt;
}

final battlePassProvider =
    NotifierProvider<BattlePassNotifier, BattlePassModel>(BattlePassNotifier.new);

final claimableCountProvider = Provider<int>((ref) {
  final bp = ref.watch(battlePassProvider);
  return bp.claimableCount(bp.isPremium);
});
