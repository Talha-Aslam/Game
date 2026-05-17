import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/battle_pass_model.dart';
import 'reward_node_widget.dart';

/// Horizontal dual-lane reward track (Free top, Premium bottom)
class RewardTrackWidget extends StatefulWidget {
  final BattlePassModel bp;
  final void Function(BattlePassTier tier, bool isPremium)? onTapReward;
  final void Function(int tier, bool isPremium)? onClaimReward;

  const RewardTrackWidget({super.key, required this.bp, this.onTapReward, this.onClaimReward});

  @override
  State<RewardTrackWidget> createState() => _RewardTrackWidgetState();
}

class _RewardTrackWidgetState extends State<RewardTrackWidget> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // Auto-scroll to current tier
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final offset = ((widget.bp.currentTier - 1) * 80.0 - 100).clamp(0.0, double.infinity);
      if (_scrollController.hasClients) {
        _scrollController.animateTo(offset, duration: const Duration(milliseconds: 600), curve: Curves.easeOut);
      }
    });
  }

  @override
  void dispose() { _scrollController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Track labels
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [
        Container(width: 6, height: 6, decoration: const BoxDecoration(
          shape: BoxShape.circle, color: AppColors.cyan)),
        const SizedBox(width: 6),
        const Text('FREE', style: TextStyle(color: AppColors.white30, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1)),
        const SizedBox(width: 20),
        Container(width: 6, height: 6, decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(colors: [AppColors.gold, Color(0xFFFF8F00)]))),
        const SizedBox(width: 6),
        const Text('PREMIUM', style: TextStyle(color: AppColors.gold, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1)),
      ])),
      const SizedBox(height: 8),
      // Tracks
      SizedBox(
        height: 200,
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: widget.bp.tiers.length,
          itemBuilder: (_, i) {
            final tier = widget.bp.tiers[i];
            final isCurrentTier = tier.tier == widget.bp.currentTier;
            return SizedBox(
              width: 80,
              child: Column(children: [
                // Free track (top)
                RewardNodeWidget(
                  reward: tier.freeReward, tier: tier.tier,
                  claimState: tier.freeClaimState(),
                  onTap: () => widget.onTapReward?.call(tier, false),
                  onClaim: () => widget.onClaimReward?.call(tier.tier, false),
                ),
                // Progress connector
                _ProgressLine(
                  isCompleted: tier.isUnlocked,
                  isCurrent: isCurrentTier,
                  progress: isCurrentTier ? widget.bp.progress : 0,
                ),
                // Premium track (bottom)
                if (tier.premiumReward != null)
                  RewardNodeWidget(
                    reward: tier.premiumReward!, tier: tier.tier,
                    claimState: tier.premiumClaimState(widget.bp.isPremium),
                    isPremiumTrack: true,
                    onTap: () => widget.onTapReward?.call(tier, true),
                    onClaim: () => widget.onClaimReward?.call(tier.tier, true),
                  )
                else
                  const SizedBox(height: 84),
              ]),
            );
          },
        ),
      ),
    ]);
  }
}

class _ProgressLine extends StatelessWidget {
  final bool isCompleted;
  final bool isCurrent;
  final double progress;
  const _ProgressLine({this.isCompleted = false, this.isCurrent = false, this.progress = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(children: [
        Expanded(child: Container(height: 2, decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(1),
          color: isCompleted ? AppColors.gold.withValues(alpha: 0.4) : AppColors.white05,
          boxShadow: isCompleted ? [BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.2), blurRadius: 4)] : null))),
        // Current tier marker
        if (isCurrent) Container(
          width: 10, height: 10,
          decoration: BoxDecoration(shape: BoxShape.circle,
            color: AppColors.gold,
            boxShadow: [BoxShadow(color: AppColors.gold.withValues(alpha: 0.4), blurRadius: 6)]),
        ) else Container(
          width: 6, height: 6,
          decoration: BoxDecoration(shape: BoxShape.circle,
            color: isCompleted ? AppColors.gold.withValues(alpha: 0.3) : AppColors.white05),
        ),
        Expanded(child: Container(height: 2, color: AppColors.white05)),
      ]),
    );
  }
}
