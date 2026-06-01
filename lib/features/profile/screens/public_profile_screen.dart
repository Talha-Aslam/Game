import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../models/rank_model.dart';
import '../../../models/social/friend_model.dart';

class PublicProfileScreen extends ConsumerWidget {
  final FriendModel friend;

  const PublicProfileScreen({super.key, required this.friend});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rank = RankModel.fromTier(friend.rankTier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppGradients.backgroundGradient,
              ),
            ),
          ),
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: rank.glowColor.withValues(alpha: 0.2),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.glassBackgroundDark,
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text('Player Profile', style: AppTextStyles.headlineSmall),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Avatar and basic info
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.surfaceLight,
                          backgroundImage: friend.avatarUrl.isNotEmpty
                              ? NetworkImage('${AppConstants.apiBaseUrl}${friend.avatarUrl}')
                              : null,
                          child: friend.avatarUrl.isEmpty
                              ? Text(
                                  friend.username.isNotEmpty ? friend.username[0].toUpperCase() : '?',
                                  style: const TextStyle(fontSize: 40, color: AppColors.white50),
                                )
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          friend.username,
                          style: AppTextStyles.headlineMedium,
                        ),
                        if (friend.equippedTitle != null && friend.equippedTitle!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.purpleNeon.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.purpleNeon.withValues(alpha: 0.5)),
                            ),
                            child: Text(
                              friend.equippedTitle!,
                              style: const TextStyle(
                                color: AppColors.purpleNeon,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          'ID: ${friend.id.length >= 8 ? friend.id.substring(0, 8).toUpperCase() : friend.id.toUpperCase()}',
                          style: const TextStyle(
                            color: AppColors.white50,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Rank and Popularity Card
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatBox(
                                title: 'Rank',
                                value: rank.name,
                                color: rank.color,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatBox(
                                title: 'Popularity',
                                value: friend.popularityScore.toString(),
                                color: AppColors.gold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Overall Stats
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'OVERALL STATS',
                            style: TextStyle(
                              color: AppColors.white50,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.glassBackground,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildMiniStat('Games', '${friend.gamesPlayed}'),
                              Container(height: 30, width: 1, color: AppColors.white10),
                              _buildMiniStat('Win Rate', '${friend.winRate.toStringAsFixed(1)}%'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Role Stats (Since FriendModel doesn't have RoleStats, we just show a placeholder or basic info)
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'ROLE STATS',
                            style: TextStyle(
                              color: AppColors.white50,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.glassBackground,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: const Center(
                            child: Text(
                              'Detailed role statistics are private.',
                              style: TextStyle(color: AppColors.white50, fontStyle: FontStyle.italic),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox({required String title, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: AppColors.white50, fontSize: 12)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String title, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(color: AppColors.white50, fontSize: 12)),
      ],
    );
  }
}
