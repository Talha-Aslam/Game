import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../providers/battle_pass_provider.dart';
import '../../../models/battle_pass_model.dart';
import '../../../widgets/particle_field.dart';
import '../widgets/bp_header.dart';
import '../widgets/reward_track_widget.dart';
import '../widgets/reward_preview_modal.dart';
import '../widgets/reward_claim_animation.dart';
import '../widgets/tier_purchase_dialog.dart';
import '../widgets/premium_upsell_widget.dart';
import '../widgets/xp_progress_bar.dart';

class BattlePassScreen extends ConsumerWidget {
  const BattlePassScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bp = ref.watch(battlePassProvider);

    return Scaffold(
      body: Stack(children: [
        Container(decoration: const BoxDecoration(gradient: AppGradients.backgroundGradient)),
        const ParticleField(particleCount: 12),
        SafeArea(child: Column(children: [
          // Back button row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, color: AppColors.white05,
                    border: Border.all(color: AppColors.glassBorder)),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 20)),
              ),
              const SizedBox(width: 12),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.gold, Color(0xFFFF8F00)]).createShader(bounds),
                child: const Text('BATTLE PASS', style: TextStyle(
                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 2)),
              ),
            ]),
          ),
          const SizedBox(height: 8),
          // Header
          BPHeader(
            bp: bp,
            onBuyPremium: () => _showPremiumSheet(context, ref, bp),
            onBuyTiers: () => TierPurchaseDialog.show(context,
              currentTier: bp.currentTier, maxTier: bp.maxTier,
              costPerTier: bp.tierSkipCost,
              onPurchase: (count) => ref.read(battlePassProvider.notifier).purchaseTiers(count)),
            onBoost: () => _showBoostSheet(context, ref),
          ),
          const SizedBox(height: 8),
          // Horizontal track
          Expanded(child: RewardTrackWidget(
            bp: bp,
            onTapReward: (tier, isPremium) => _showPreview(context, ref, tier, isPremium, bp),
            onClaimReward: (tierNum, isPremium) => _claimReward(context, ref, tierNum, isPremium, bp),
          )),
          // Bottom XP bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            decoration: BoxDecoration(
              color: AppColors.background.withValues(alpha: 0.9),
              border: Border(top: BorderSide(color: AppColors.glassBorder))),
            child: XPProgressBar(
              currentXP: bp.currentXP, maxXP: bp.xpToNextTier,
              currentTier: bp.currentTier, hasBoost: bp.hasActiveBoost),
          ),
        ])),
      ]),
    );
  }

  void _showPreview(BuildContext context, WidgetRef ref, BattlePassTier tier, bool isPremium, BattlePassModel bp) {
    final reward = isPremium ? tier.premiumReward! : tier.freeReward;
    final claimState = isPremium ? tier.premiumClaimState(bp.isPremium) : tier.freeClaimState();
    RewardPreviewModal.show(context,
      reward: reward, tier: tier.tier,
      claimState: claimState,
      isPremiumTrack: isPremium,
      hasPremium: bp.isPremium,
      premiumCost: bp.premiumCost,
      onClaim: () => _claimReward(context, ref, tier.tier, isPremium, bp),
      onBuyPremium: () => _showPremiumSheet(context, ref, bp),
    );
  }

  void _claimReward(BuildContext context, WidgetRef ref, int tierNum, bool isPremium, BattlePassModel bp) {
    final tier = bp.tiers.firstWhere((t) => t.tier == tierNum);
    final reward = isPremium ? tier.premiumReward! : tier.freeReward;

    if (isPremium) {
      ref.read(battlePassProvider.notifier).claimPremiumReward(tierNum);
    } else {
      ref.read(battlePassProvider.notifier).claimFreeReward(tierNum);
    }
    RewardClaimAnimation.play(context, rarity: reward.rarity);
  }

  void _showPremiumSheet(BuildContext context, WidgetRef ref, BattlePassModel bp) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: AppColors.surface.withValues(alpha: 0.95),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.2))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2), color: AppColors.white30)),
          const SizedBox(height: 16),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.gold, Color(0xFFFF8F00)]).createShader(bounds),
            child: const Text('UPGRADE PASS', style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2)),
          ),
          const SizedBox(height: 16),
          PremiumUpsellWidget(
            premiumCost: bp.premiumCost,
            premiumPlusCost: bp.premiumPlusCost,
            onBuyPremium: () {
              ref.read(battlePassProvider.notifier).purchasePremium();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('⭐ Premium Pass Activated!'), behavior: SnackBarBehavior.floating));
            },
            onBuyPremiumPlus: () {
              ref.read(battlePassProvider.notifier).purchasePremiumPlus();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('⭐ Premium+ Bundle Activated! +20 Tiers!'), behavior: SnackBarBehavior.floating));
            },
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  void _showBoostSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: AppColors.surface.withValues(alpha: 0.95),
          border: Border.all(color: AppColors.mintGreen.withValues(alpha: 0.2))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2), color: AppColors.white30)),
          const SizedBox(height: 16),
          const Text('XP BOOSTS', style: TextStyle(
            color: AppColors.mintGreen, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1)),
          const SizedBox(height: 16),
          ...XPBoostType.values.map((type) => GestureDetector(
            onTap: () {
              ref.read(battlePassProvider.notifier).activateBoost(type);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('⚡ ${type.displayName} activated!'),
                behavior: SnackBarBehavior.floating));
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: AppColors.mintGreen.withValues(alpha: 0.05),
                border: Border.all(color: AppColors.mintGreen.withValues(alpha: 0.2))),
              child: Row(children: [
                Icon(type.icon, color: AppColors.mintGreen, size: 22),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(type.displayName, style: const TextStyle(
                    color: AppColors.mintGreen, fontSize: 13, fontWeight: FontWeight.w700)),
                  Text('Duration: ${type.duration.inHours}h', style: const TextStyle(
                    color: AppColors.white30, fontSize: 10)),
                ])),
                Text('${type.cost} SC', style: const TextStyle(
                  color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w700)),
              ]),
            ),
          )),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}
