import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/battle_pass_model.dart';
import 'reward_rarity_badge.dart';

/// Glassmorphic reward preview modal
class RewardPreviewModal extends StatelessWidget {
  final BattlePassReward reward;
  final int tier;
  final ClaimState claimState;
  final bool isPremiumTrack;
  final bool hasPremium;
  final int premiumCost;
  final VoidCallback? onClaim;
  final VoidCallback? onBuyPremium;

  const RewardPreviewModal({
    super.key, required this.reward, required this.tier,
    required this.claimState, this.isPremiumTrack = false,
    this.hasPremium = false, this.premiumCost = 999,
    this.onClaim, this.onBuyPremium,
  });

  static void show(BuildContext context, {
    required BattlePassReward reward, required int tier,
    required ClaimState claimState, bool isPremiumTrack = false,
    bool hasPremium = false, int premiumCost = 999,
    VoidCallback? onClaim, VoidCallback? onBuyPremium,
  }) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => RewardPreviewModal(
        reward: reward, tier: tier, claimState: claimState,
        isPremiumTrack: isPremiumTrack, hasPremium: hasPremium,
        premiumCost: premiumCost, onClaim: onClaim, onBuyPremium: onBuyPremium,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rarity = reward.rarity;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: AppColors.surface.withValues(alpha: 0.95),
        border: Border.all(color: rarity.color.withValues(alpha: 0.25)),
        boxShadow: [BoxShadow(color: rarity.glowColor.withValues(alpha: 0.15), blurRadius: 30)],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2), color: AppColors.white30)),
        const SizedBox(height: 20),
        // Reward icon large
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: rarity.color.withValues(alpha: 0.08),
            border: Border.all(color: rarity.color.withValues(alpha: 0.3), width: 2),
            boxShadow: [BoxShadow(color: rarity.glowColor.withValues(alpha: 0.2), blurRadius: 20)],
          ),
          child: Icon(reward.type.icon, color: rarity.color, size: 36),
        ),
        const SizedBox(height: 16),
        // Rarity badge
        RewardRarityBadge(rarity: rarity),
        const SizedBox(height: 8),
        // Name
        Text(reward.name, style: AppTextStyles.headlineSmall.copyWith(color: rarity.color),
          textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text('Tier $tier • ${reward.type.displayName}', style: AppTextStyles.labelSmall),
        if (reward.description.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(reward.description, style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
        ],
        if (reward.type.previewHint.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(reward.type.previewHint, style: TextStyle(
            color: rarity.color.withValues(alpha: 0.5), fontSize: 10, fontStyle: FontStyle.italic)),
        ],
        // Season exclusive label
        if (isPremiumTrack) ...[
          const SizedBox(height: 12),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8),
              color: AppColors.gold.withValues(alpha: 0.08),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.2))),
            child: const Text('⏰ Season Exclusive', style: TextStyle(
              color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.w600))),
        ],
        const SizedBox(height: 20),
        // Action button
        _buildAction(context),
        const SizedBox(height: 8),
      ]),
    );
  }

  Widget _buildAction(BuildContext context) {
    switch (claimState) {
      case ClaimState.unlockable:
        return _ClaimButton(rarity: reward.rarity, onTap: () {
          onClaim?.call(); Navigator.of(context).pop();
        });
      case ClaimState.claimed:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
            color: AppColors.online.withValues(alpha: 0.1)),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.check_circle, color: AppColors.online, size: 18),
            SizedBox(width: 6),
            Text('CLAIMED', style: TextStyle(color: AppColors.online, fontWeight: FontWeight.w700, fontSize: 13)),
          ]));
      case ClaimState.premiumLocked:
        return _PremiumUpsellButton(cost: premiumCost, onTap: () {
          onBuyPremium?.call(); Navigator.of(context).pop();
        });
      case ClaimState.locked:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: AppColors.white05),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.lock, color: AppColors.white30, size: 16),
            SizedBox(width: 6),
            Text('LOCKED — Reach tier to unlock', style: TextStyle(
              color: AppColors.white30, fontWeight: FontWeight.w600, fontSize: 11)),
          ]));
    }
  }
}

class _ClaimButton extends StatefulWidget {
  final RewardRarity rarity; final VoidCallback? onTap;
  const _ClaimButton({required this.rarity, this.onTap});
  @override
  State<_ClaimButton> createState() => _ClaimButtonState();
}

class _ClaimButtonState extends State<_ClaimButton> with SingleTickerProviderStateMixin {
  late AnimationController _glow;
  @override
  void initState() { super.initState(); _glow = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this)..repeat(reverse: true); }
  @override
  void dispose() { _glow.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: widget.onTap, child: AnimatedBuilder(animation: _glow, builder: (_, __) {
      final g = _glow.value;
      return Container(
        width: double.infinity, height: 48,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(colors: [widget.rarity.color, widget.rarity.glowColor]),
          boxShadow: [BoxShadow(color: widget.rarity.color.withValues(alpha: 0.3 + g * 0.2), blurRadius: 14 + g * 6)]),
        child: const Center(child: Text('CLAIM REWARD',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 1))));
    }));
  }
}

class _PremiumUpsellButton extends StatefulWidget {
  final int cost; final VoidCallback? onTap;
  const _PremiumUpsellButton({required this.cost, this.onTap});
  @override
  State<_PremiumUpsellButton> createState() => _PremiumUpsellButtonState();
}

class _PremiumUpsellButtonState extends State<_PremiumUpsellButton> with SingleTickerProviderStateMixin {
  late AnimationController _shimmer;
  @override
  void initState() { super.initState(); _shimmer = AnimationController(duration: const Duration(seconds: 2), vsync: this)..repeat(); }
  @override
  void dispose() { _shimmer.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: widget.onTap, child: AnimatedBuilder(animation: _shimmer, builder: (_, __) {
      return Container(
        width: double.infinity, height: 48,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(colors: [AppColors.gold, Color(0xFFFF8F00), AppColors.gold]),
          boxShadow: [BoxShadow(color: AppColors.gold.withValues(alpha: 0.25 + _shimmer.value * 0.15), blurRadius: 16)]),
        child: Center(child: Text('⭐ UNLOCK PREMIUM PASS — ${widget.cost} SC',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5))));
    }));
  }
}
