import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/rank_model.dart';
import '../../../widgets/neon_text.dart';
import '../../../widgets/rank_badge.dart';

class RankingsScreen extends ConsumerWidget {
  const RankingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final rank = RankModel.fromTier(user?.rankTier ?? 0);
    final progress = rank.progressToNext(user?.rankPoints ?? 0);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(onTap: () => context.pop(), child: const Icon(Icons.arrow_back, color: AppColors.white70)),
                    const SizedBox(width: 16),
                    const Expanded(child: NeonText(text: 'RANKINGS', fontSize: 22, color: AppColors.cyan)),
                  ],
                ),
                const SizedBox(height: 32),

                // Current rank display
                RankBadge(tier: user?.rankTier ?? 0, size: 64),
                const SizedBox(height: 12),
                Text('${user?.rankPoints ?? 0} RP', style: AppTextStyles.headlineLarge.copyWith(color: rank.color)),
                const SizedBox(height: 16),

                // Progress bar
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AppColors.white05,
                    border: Border.all(color: rank.color.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(rank.name, style: TextStyle(color: rank.color, fontWeight: FontWeight.w600)),
                          if (rank.tier < 4)
                            Text(RankModel.fromTier(rank.tier + 1).name, style: TextStyle(color: RankModel.fromTier(rank.tier + 1).color, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(value: progress, backgroundColor: AppColors.white10, valueColor: AlwaysStoppedAnimation(rank.color), minHeight: 8),
                      ),
                      const SizedBox(height: 4),
                      Text('${(progress * 100).toInt()}% to next rank', style: AppTextStyles.labelSmall),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // All ranks
                ...RankModel.allRanks.map((r) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: r.tier == (user?.rankTier ?? 0) ? r.color.withValues(alpha: 0.08) : AppColors.white05,
                    border: Border.all(color: r.tier == (user?.rankTier ?? 0) ? r.color.withValues(alpha: 0.4) : AppColors.glassBorder),
                  ),
                  child: Row(
                    children: [
                      RankBadge(tier: r.tier, size: 28, showLabel: false),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.name, style: TextStyle(color: r.color, fontWeight: FontWeight.w600, fontSize: 14)),
                            Text('${r.minPoints} - ${r.maxPoints} RP', style: AppTextStyles.labelSmall),
                          ],
                        ),
                      ),
                      if (r.tier == (user?.rankTier ?? 0))
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: r.color.withValues(alpha: 0.2)),
                          child: Text('CURRENT', style: TextStyle(color: r.color, fontSize: 9, fontWeight: FontWeight.w700)),
                        ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
