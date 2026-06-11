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
  late ScrollController _freeScrollController;
  late ScrollController _premiumScrollController;
  bool _isScrollingFree = false;
  bool _isScrollingPremium = false;

  @override
  void initState() {
    super.initState();
    _freeScrollController = ScrollController();
    _premiumScrollController = ScrollController();

    // Synchronize scrolling
    _freeScrollController.addListener(() {
      if (_freeScrollController.position.isScrollingNotifier.value || !_isScrollingPremium) {
        _isScrollingFree = true;
        if (_premiumScrollController.hasClients && _freeScrollController.offset != _premiumScrollController.offset) {
          _premiumScrollController.jumpTo(_freeScrollController.offset);
        }
      }
    });

    _premiumScrollController.addListener(() {
      if (_premiumScrollController.position.isScrollingNotifier.value || !_isScrollingFree) {
        _isScrollingPremium = true;
        if (_freeScrollController.hasClients && _premiumScrollController.offset != _freeScrollController.offset) {
          _freeScrollController.jumpTo(_premiumScrollController.offset);
        }
      }
    });

    // Auto-scroll to current tier and add scrolling notifiers after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_freeScrollController.hasClients) {
        _freeScrollController.position.isScrollingNotifier.addListener(() {
          if (!_freeScrollController.position.isScrollingNotifier.value) _isScrollingFree = false;
        });
      }
      if (_premiumScrollController.hasClients) {
        _premiumScrollController.position.isScrollingNotifier.addListener(() {
          if (!_premiumScrollController.position.isScrollingNotifier.value) _isScrollingPremium = false;
        });
      }

      final offset = ((widget.bp.currentTier - 1) * 80.0 - 50).clamp(0.0, double.infinity);
      if (_freeScrollController.hasClients) {
        _freeScrollController.animateTo(offset, duration: const Duration(milliseconds: 600), curve: Curves.easeOut);
      }
    });
  }

  @override
  void dispose() {
    _freeScrollController.dispose();
    _premiumScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Free Track Header
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(children: [
          Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.cyan)),
          const SizedBox(width: 8),
          const Text('FREE REWARDS', style: TextStyle(color: AppColors.cyan, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2)),
        ]),
      ),
      // Free Track List
      SizedBox(
        height: 120,
        child: ListView.builder(
          controller: _freeScrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: widget.bp.tiers.length,
          itemBuilder: (_, i) {
            final tier = widget.bp.tiers[i];
            final isCurrentTier = tier.tier == widget.bp.currentTier;
            return SizedBox(
              width: 80,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  RewardNodeWidget(
                    reward: tier.freeReward, tier: tier.tier,
                    claimState: tier.freeClaimState(),
                    onTap: () => widget.onTapReward?.call(tier, false),
                    onClaim: () => widget.onClaimReward?.call(tier.tier, false),
                  ),
                  _ProgressLine(
                    isCompleted: tier.isUnlocked,
                    isCurrent: isCurrentTier,
                    progress: isCurrentTier ? widget.bp.progress : 0,
                  ),
                ],
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 16),
      // Premium Track Header
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [AppColors.gold, Color(0xFFFF8F00)]))),
          const SizedBox(width: 8),
          const Text('PREMIUM REWARDS', style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2)),
          if (widget.bp.isPremium) ...[
            const SizedBox(width: 8),
            Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)), child: const Text('UNLOCKED', style: TextStyle(color: AppColors.gold, fontSize: 8, fontWeight: FontWeight.w800)))
          ]
        ]),
      ),
      // Premium Track List
      SizedBox(
        height: 120,
        child: ListView.builder(
          controller: _premiumScrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: widget.bp.tiers.length,
          itemBuilder: (_, i) {
            final tier = widget.bp.tiers[i];
            final isCurrentTier = tier.tier == widget.bp.currentTier;
            return SizedBox(
              width: 80,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _ProgressLine(
                    isCompleted: tier.isUnlocked,
                    isCurrent: isCurrentTier,
                    progress: isCurrentTier ? widget.bp.progress : 0,
                  ),
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
