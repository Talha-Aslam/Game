import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/rank_model.dart';
import '../../../widgets/rank_badge.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    if (user == null) return const Scaffold(body: Center(child: Text('Not logged in')));
    final rank = RankModel.fromTier(user.rankTier);

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
                    const Spacer(),
                    GestureDetector(
                      onTap: () async {
                        await ref.read(authProvider.notifier).signOut();
                        if (context.mounted) context.go('/login');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.crimsonRed.withValues(alpha: 0.4))),
                        child: const Text('Sign Out', style: TextStyle(color: AppColors.crimsonRed, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Avatar
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: rank.color, width: 3),
                    color: AppColors.surfaceLight,
                    boxShadow: [BoxShadow(color: rank.glowColor, blurRadius: 20)],
                  ),
                  child: Center(child: Text(user.username[0].toUpperCase(), style: TextStyle(color: rank.color, fontSize: 36, fontWeight: FontWeight.w800))),
                ),
                const SizedBox(height: 12),
                Text(user.username, style: AppTextStyles.headlineLarge),
                if (user.familyName != null)
                  Text(user.familyName!, style: AppTextStyles.labelSmall.copyWith(color: AppColors.gold)),
                const SizedBox(height: 8),
                RankBadge(tier: user.rankTier, size: 28),
                const SizedBox(height: 24),

                // Stats grid
                Row(
                  children: [
                    Expanded(child: _StatBox(label: 'Games', value: '${user.totalGames}', color: AppColors.cyan)),
                    const SizedBox(width: 8),
                    Expanded(child: _StatBox(label: 'Wins', value: '${user.wins}', color: AppColors.mintGreen)),
                    const SizedBox(width: 8),
                    Expanded(child: _StatBox(label: 'Win Rate', value: '${user.winRate.toStringAsFixed(1)}%', color: AppColors.gold)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _StatBox(label: 'Rank Points', value: '${user.rankPoints}', color: rank.color)),
                    const SizedBox(width: 8),
                    Expanded(child: _StatBox(label: 'Influence', value: '${user.influencePoints}', color: AppColors.cyan)),
                    const SizedBox(width: 8),
                    Expanded(child: _StatBox(label: 'Syndicate', value: '${user.syndicateCoins}', color: AppColors.gold)),
                  ],
                ),

                const SizedBox(height: 24),
                // Battle pass
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: AppColors.gold.withValues(alpha: 0.06),
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.stars, color: AppColors.gold),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.hasBattlePass ? 'Premium Battle Pass' : 'Free Battle Pass', style: AppTextStyles.labelLarge.copyWith(color: AppColors.gold)),
                            Text('Tier ${user.battlePassTier}', style: AppTextStyles.labelSmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label, value;
  final Color color;
  const _StatBox({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withValues(alpha: 0.06),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }
}
