import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../providers/ranking_provider.dart';
import '../../../widgets/neon_text.dart';
import '../../../widgets/particle_field.dart';
import '../../../widgets/rank_badge.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rankingsAsync = ref.watch(rankingsProvider);

    return Scaffold(
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(gradient: AppGradients.backgroundGradient)),
          const ParticleField(particleCount: 15, particleColor: AppColors.gold),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: const Icon(Icons.arrow_back, color: AppColors.white70),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: NeonText(
                          text: 'GLOBAL RANKINGS',
                          fontSize: 22,
                          color: AppColors.gold,
                          glowRadius: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: rankingsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator(color: AppColors.gold)),
                    error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))),
                    data: (rankings) => ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: rankings.length,
                      itemBuilder: (context, index) {
                        final player = rankings[index];
                        return _RankingCard(player: player);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // My Rank Footer
          if (rankingsAsync.hasValue)
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: _MyRankFooter(rankings: rankingsAsync.value!),
            ),
        ],
      ),
    );
  }
}

class _RankingCard extends StatelessWidget {
  final RankingModel player;
  const _RankingCard({required this.player});

  @override
  Widget build(BuildContext context) {
    final isTop3 = player.rank <= 3;
    final medalColor = player.rank == 1 ? AppColors.gold : (player.rank == 2 ? const Color(0xFFC0C0C0) : const Color(0xFFCD7F32));

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: player.isMe ? player.rankInfo.color.withValues(alpha: 0.1) : AppColors.white05,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: player.isMe ? player.rankInfo.color.withValues(alpha: 0.4) : AppColors.glassBorder,
          width: player.isMe ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 40,
            child: isTop3 
              ? Icon(Icons.workspace_premium, color: medalColor, size: 24)
              : Text('#${player.rank}', style: AppTextStyles.labelMedium.copyWith(color: AppColors.white50)),
          ),
          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: player.rankInfo.color.withValues(alpha: 0.1),
                backgroundImage: player.avatarUrl.isNotEmpty 
                  ? NetworkImage(player.avatarUrl.startsWith('http') ? player.avatarUrl : '${AppConstants.apiBaseUrl}${player.avatarUrl}') 
                  : null,
                child: player.avatarUrl.isEmpty ? Icon(Icons.person, color: player.rankInfo.color, size: 20) : null,
              ),
              Positioned(
                bottom: -2, right: -2,
                child: RankBadge(tier: player.rankInfo.tier, size: 14, showLabel: false),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Name & Level
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(player.username, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w700, color: player.isMe ? player.rankInfo.color : Colors.white)),
                Text('Level ${player.level} • ${player.rankInfo.name}', style: AppTextStyles.labelSmall.copyWith(color: AppColors.white30)),
              ],
            ),
          ),
          // MMR
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${player.mmr}', style: TextStyle(color: player.rankInfo.color, fontWeight: FontWeight.bold, fontSize: 16)),
              const Text('POINTS', style: TextStyle(color: AppColors.white30, fontSize: 8, letterSpacing: 1)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MyRankFooter extends StatelessWidget {
  final List<RankingModel> rankings;
  const _MyRankFooter({required this.rankings});

  @override
  Widget build(BuildContext context) {
    final myRank = rankings.where((r) => r.isMe).firstOrNull;
    if (myRank == null) return const SizedBox.shrink();
    if (myRank.rank <= 8) return const SizedBox.shrink(); // Don't show if already visible at top

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.gold.withValues(alpha: 0.3))),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: _RankingCard(player: myRank),
    );
  }
}