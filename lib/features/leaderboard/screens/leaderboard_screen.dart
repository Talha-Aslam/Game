import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../providers/ranking_provider.dart';
import '../../../models/rank_model.dart';
import '../../../widgets/neon_text.dart';
import '../../../widgets/rank_badge.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(leaderboardProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(onTap: () => context.pop(), child: const Icon(Icons.arrow_back, color: AppColors.white70)),
                    const SizedBox(width: 16),
                    const Expanded(child: NeonText(text: 'LEADERBOARD', fontSize: 20, color: AppColors.gold, glowRadius: 15)),
                  ],
                ),
              ),

              // Top 3 podium
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (entries.length > 1) _PodiumCard(entry: entries[1], height: 100, medal: '🥈'),
                    if (entries.isNotEmpty) _PodiumCard(entry: entries[0], height: 130, medal: '🥇'),
                    if (entries.length > 2) _PodiumCard(entry: entries[2], height: 80, medal: '🥉'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Rest of leaderboard
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: entries.length > 3 ? entries.length - 3 : 0,
                  itemBuilder: (context, i) {
                    final entry = entries[i + 3];
                    final rank = RankModel.fromTier(entry.rankTier);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.white05,
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 28, child: Text('#${entry.position}', style: TextStyle(color: AppColors.white50, fontWeight: FontWeight.w700, fontSize: 13))),
                          const SizedBox(width: 8),
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.surfaceLight, border: Border.all(color: rank.color, width: 1.5)),
                            child: Center(child: Text(entry.username[0], style: TextStyle(color: rank.color, fontWeight: FontWeight.w700))),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(entry.username, style: AppTextStyles.labelLarge),
                                    if (entry.familyTag != null) ...[
                                      const SizedBox(width: 4),
                                      Text(entry.familyTag!, style: TextStyle(color: AppColors.gold.withValues(alpha: 0.6), fontSize: 10)),
                                    ],
                                  ],
                                ),
                                Text('${entry.points} RP', style: AppTextStyles.labelSmall),
                              ],
                            ),
                          ),
                          RankBadge(tier: entry.rankTier, size: 22, showLabel: false),
                        ],
                      ),
                    );
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

class _PodiumCard extends StatelessWidget {
  final RankingEntry entry;
  final double height;
  final String medal;
  const _PodiumCard({required this.entry, required this.height, required this.medal});

  @override
  Widget build(BuildContext context) {
    final rank = RankModel.fromTier(entry.rankTier);
    return Column(
      children: [
        Text(medal, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.surfaceLight, border: Border.all(color: rank.color, width: 2),
            boxShadow: [BoxShadow(color: rank.glowColor, blurRadius: 10)]),
          child: Center(child: Text(entry.username[0], style: TextStyle(color: rank.color, fontWeight: FontWeight.w800, fontSize: 18))),
        ),
        const SizedBox(height: 4),
        Text(entry.username, style: AppTextStyles.labelSmall, overflow: TextOverflow.ellipsis),
        Text('${entry.points}', style: TextStyle(color: rank.color, fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Container(
          width: 70, height: height,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [rank.color.withValues(alpha: 0.3), rank.color.withValues(alpha: 0.05)]),
            border: Border.all(color: rank.color.withValues(alpha: 0.3)),
          ),
        ),
      ],
    );
  }
}
