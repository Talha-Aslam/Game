import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../providers/battle_pass_provider.dart';
import '../../../models/battle_pass_model.dart';
import '../../../widgets/neon_text.dart';
import '../../../widgets/glass_button.dart';

class BattlePassScreen extends ConsumerWidget {
  const BattlePassScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bp = ref.watch(battlePassProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: const Icon(Icons.arrow_back, color: AppColors.white70),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(child: NeonText(text: 'BATTLE PASS', fontSize: 20, color: AppColors.gold, glowRadius: 15)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: bp.isPremium ? AppColors.gold.withValues(alpha: 0.15) : AppColors.white05,
                        border: Border.all(color: bp.isPremium ? AppColors.gold.withValues(alpha: 0.4) : AppColors.glassBorder),
                      ),
                      child: Text(
                        bp.isPremium ? '⭐ PREMIUM' : 'FREE',
                        style: TextStyle(color: bp.isPremium ? AppColors.gold : AppColors.white50, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),

              // Progress
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tier ${bp.currentTier}', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.gold)),
                        Text('${bp.currentXP} / ${bp.xpToNextTier} XP', style: AppTextStyles.labelSmall),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: bp.progress,
                        backgroundColor: AppColors.white10,
                        valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Tiers list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: bp.tiers.length,
                  itemBuilder: (context, i) {
                    final tier = bp.tiers[i];
                    return _TierRow(tier: tier, isPremium: bp.isPremium, onClaim: () {
                      ref.read(battlePassProvider.notifier).claimReward(tier.tier);
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TierRow extends StatelessWidget {
  final BattlePassTier tier;
  final bool isPremium;
  final VoidCallback onClaim;

  const _TierRow({required this.tier, required this.isPremium, required this.onClaim});

  @override
  Widget build(BuildContext context) {
    final isUnlocked = tier.isUnlocked;
    final isClaimed = tier.isClaimed;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isUnlocked ? AppColors.white05 : AppColors.glassBackgroundDark,
        border: Border.all(
          color: isUnlocked && !isClaimed ? AppColors.gold.withValues(alpha: 0.4) : AppColors.glassBorder,
        ),
      ),
      child: Row(
        children: [
          // Tier number
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUnlocked ? AppColors.gold.withValues(alpha: 0.15) : AppColors.white05,
              border: Border.all(color: isUnlocked ? AppColors.gold.withValues(alpha: 0.3) : AppColors.white10),
            ),
            child: Center(
              child: Text('${tier.tier}', style: TextStyle(
                color: isUnlocked ? AppColors.gold : AppColors.white30,
                fontWeight: FontWeight.w700, fontSize: 13,
              )),
            ),
          ),
          const SizedBox(width: 12),

          // Free reward
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('FREE', style: AppTextStyles.labelSmall.copyWith(color: AppColors.white30)),
                Text(tier.freeReward.name, style: AppTextStyles.labelMedium.copyWith(
                  color: isUnlocked ? AppColors.white : AppColors.white30,
                )),
              ],
            ),
          ),

          // Premium reward
          if (tier.premiumReward != null) ...[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('⭐ PREMIUM', style: AppTextStyles.labelSmall.copyWith(color: AppColors.gold.withValues(alpha: 0.6))),
                  Text(tier.premiumReward!.name, style: AppTextStyles.labelMedium.copyWith(
                    color: isPremium && isUnlocked ? AppColors.gold : AppColors.white30,
                  )),
                ],
              ),
            ),
          ],

          // Claim button
          if (isUnlocked && !isClaimed)
            GlassButton(label: 'CLAIM', glowColor: AppColors.gold, width: 70, height: 32, onPressed: onClaim)
          else if (isClaimed)
            const Icon(Icons.check_circle, color: AppColors.online, size: 22)
          else
            Icon(Icons.lock, color: AppColors.white10, size: 18),
        ],
      ),
    );
  }
}
