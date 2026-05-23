import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/battle_pass_model.dart';

/// Individual reward node for the horizontal track
class RewardNodeWidget extends StatefulWidget {
  final BattlePassReward reward;
  final int tier;
  final ClaimState claimState;
  final bool isPremiumTrack;
  final VoidCallback? onTap;
  final VoidCallback? onClaim;

  const RewardNodeWidget({
    super.key, required this.reward, required this.tier,
    required this.claimState, this.isPremiumTrack = false,
    this.onTap, this.onClaim,
  });

  @override
  State<RewardNodeWidget> createState() => _RewardNodeWidgetState();
}

class _RewardNodeWidgetState extends State<RewardNodeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);
    if (widget.claimState == ClaimState.unlockable) _pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(RewardNodeWidget old) {
    super.didUpdateWidget(old);
    if (widget.claimState == ClaimState.unlockable && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (widget.claimState != ClaimState.unlockable && _pulse.isAnimating) {
      _pulse.stop();
    }
  }

  @override
  void dispose() { _pulse.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final rarity = widget.reward.rarity;
    final isLocked = widget.claimState == ClaimState.locked || widget.claimState == ClaimState.premiumLocked;
    final isClaimed = widget.claimState == ClaimState.claimed;
    final isClaimable = widget.claimState == ClaimState.unlockable;

    return AnimatedBuilder(animation: _pulse, builder: (_, _) {
      final p = isClaimable ? _pulse.value : 0.0;
      return Container(
        width: 72, height: 84,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isLocked
              ? AppColors.white05
              : isClaimed
                  ? rarity.color.withValues(alpha: 0.06)
                  : rarity.color.withValues(alpha: 0.06 + p * 0.06),
          border: Border.all(
            color: isLocked
                ? AppColors.glassBorder
                : isClaimed
                    ? rarity.color.withValues(alpha: 0.15)
                    : rarity.color.withValues(alpha: 0.3 + p * 0.3),
            width: isClaimable ? 1.5 : 1,
          ),
          boxShadow: isClaimable ? [
            BoxShadow(color: rarity.glowColor.withValues(alpha: 0.15 + p * 0.15), blurRadius: 10 + p * 6)
          ] : widget.isPremiumTrack && !isLocked ? [
            BoxShadow(color: AppColors.gold.withValues(alpha: 0.08), blurRadius: 8)
          ] : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: isClaimable ? widget.onClaim : widget.onTap,
            splashColor: rarity.color.withValues(alpha: 0.3),
            highlightColor: rarity.color.withValues(alpha: 0.1),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            // Tier number
            Text('${widget.tier}', style: TextStyle(
              color: isLocked ? AppColors.white10 : rarity.color,
              fontSize: 8, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            // Reward icon
            Stack(alignment: Alignment.center, children: [
              Icon(widget.reward.type.icon,
                color: isLocked ? AppColors.white10 : isClaimed ? rarity.color.withValues(alpha: 0.5) : rarity.color,
                size: 26),
              if (isLocked) Icon(widget.claimState == ClaimState.premiumLocked
                  ? Icons.star : Icons.lock, color: AppColors.white10, size: 14),
              if (isClaimed) const Positioned(right: 0, bottom: 0,
                child: Icon(Icons.check_circle, color: AppColors.online, size: 12)),
              if (isClaimable) Positioned(bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(4),
                    color: rarity.color, boxShadow: [BoxShadow(color: rarity.color.withValues(alpha: 0.4), blurRadius: 4)]),
                  child: const Text('CLAIM', style: TextStyle(color: Colors.white, fontSize: 6, fontWeight: FontWeight.w800)))),
            ]),
            const SizedBox(height: 4),
            // Rarity indicator
            Container(width: 20, height: 2, decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1),
              color: isLocked ? AppColors.white05 : rarity.color.withValues(alpha: 0.5))),
            ]),
          ),
        ),
      );
    });
  }
}
