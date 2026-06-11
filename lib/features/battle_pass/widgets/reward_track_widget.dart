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
      // Tracks with side labels
      Expanded(
        child: Row(
          children: [
            // Left fixed labels
            Container(
              width: 50,
              padding: const EdgeInsets.only(left: 8, bottom: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  RotatedBox(
                    quarterTurns: 3,
                    child: const Text('FREE', style: TextStyle(color: AppColors.cyan, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  ),
                  const Spacer(),
                  RotatedBox(
                    quarterTurns: 3,
                    child: const Text('PREMIUM', style: TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
            // Horizontal list
            Expanded(
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
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
