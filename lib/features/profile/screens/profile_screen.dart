import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/rank_model.dart';
// Note: We avoid importing neon_text.dart since we just use it if it exists or use fallback.
// Actually neon_text.dart was imported in the old version, so it's around.
import '../../../widgets/neon_text.dart';

import '../widgets/profile_header.dart';
import '../widgets/profile_stats.dart';
import '../widgets/user_id_card.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Mock User ID
  final String _mockUserId = "MWR-48291";
  bool _isOpeningEditInfo = false;

  Future<void> _openEditInfo() async {
    if (_isOpeningEditInfo) return;
    setState(() => _isOpeningEditInfo = true);

    // Prevent stale snackbars from lingering during route transition.
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    final didUpdate = await context.push<bool>('/profile/edit');

    if (!mounted) return;
    setState(() => _isOpeningEditInfo = false);

    if (didUpdate == true) {
      final messenger = ScaffoldMessenger.of(context);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Profile info updated.'),
            duration: Duration(milliseconds: 1400),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Not logged in', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    final rank = RankModel.fromTier(user.rankTier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Animated / Glowing Background Layer
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
                // Top App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.share, color: Colors.white),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            tooltip: 'Edit Info',
                            onPressed: _isOpeningEditInfo
                                ? null
                                : _openEditInfo,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.settings,
                              color: Colors.white,
                            ),
                            onPressed: () => context.push('/settings'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // Avatar Header
                        AnimatedProfileHeader(user: user),
                        const SizedBox(height: 16),

                        // Username & Bio
                        NeonText(
                          text: user.username,
                          fontSize: 28,
                          color: Colors.white,
                          glowRadius: 4,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          (user.bio != null && user.bio!.trim().isNotEmpty)
                              ? user.bio!
                              : '"Trust nobody in the City of Lies."',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.white70,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ID & Sharing
                        UserIdCardWidget(userId: _mockUserId),
                        const SizedBox(height: 24),

                        // Rank Emblems
                        _buildRankBadge(rank),

                        const SizedBox(height: 24),
                        // Popularity Section
                        _buildPopularitySection(user),

                        const SizedBox(height: 32),
                        const ReputationBadgeWidget(),

                        const SizedBox(height: 32),
                        OverallStatsWidget(user: user),

                        const SizedBox(height: 32),
                        const RoleStatsWidget(),

                        const SizedBox(height: 32),
                        _buildMatchHistory(),

                        const SizedBox(height: 100), // Padding
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

  Widget _buildRankBadge(RankModel rank) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: rank.color.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: rank.glowColor.withValues(alpha: 0.1),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield, color: rank.color, size: 40),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rank.name.toUpperCase(),
                style: TextStyle(
                  color: rank.color,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: 2,
                ),
              ),
              const Text(
                'Competitive Rank',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPopularitySection(dynamic user) {
    final popRank = user.popularityRank;
    final popScore = user.popularityScore;
    final popColor = popScore >= 5000
        ? AppColors.crimsonRed
        : popScore >= 2000
            ? AppColors.gold
            : popScore >= 500
                ? AppColors.purpleNeon
                : popScore >= 100
                    ? AppColors.cyan
                    : const Color(0xFFC0C0C0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppColors.glassBackground,
        border: Border.all(color: popColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: popColor.withValues(alpha: 0.08),
            blurRadius: 20,
          ),
        ],
      ),
      child: Row(
        children: [
          // Popularity icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [popColor, popColor.withValues(alpha: 0.5)],
              ),
              boxShadow: [
                BoxShadow(
                  color: popColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                ),
              ],
            ),
            child: const Icon(Icons.star, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 16),
          // Score + rank
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'POPULARITY',
                  style: TextStyle(
                    color: AppColors.white30,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$popScore',
                  style: TextStyle(
                    color: popColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  popRank,
                  style: TextStyle(
                    color: popColor.withValues(alpha: 0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Send popularity button (visible when viewing other profiles)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: popColor.withValues(alpha: 0.12),
              border: Border.all(color: popColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.card_giftcard, color: popColor, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Gift',
                  style: TextStyle(
                    color: popColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Operations'),
            const Text(
              'View All',
              style: TextStyle(
                color: AppColors.cyan,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _historyTile(
          'Victory',
          'Mafia',
          '+24 Rank Points',
          AppColors.mafiaColor,
        ),
        const SizedBox(height: 8),
        _historyTile(
          'Defeat',
          'Doctor',
          '-12 Rank Points',
          AppColors.doctorColor,
        ),
      ],
    );
  }

  Widget _historyTile(
    String result,
    String role,
    String desc,
    Color roleColor,
  ) {
    bool isWin = result == 'Victory';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: isWin ? AppColors.gold : AppColors.charcoal,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result,
                  style: TextStyle(
                    color: isWin ? AppColors.gold : Colors.white54,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  role,
                  style: TextStyle(
                    color: roleColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            desc,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
