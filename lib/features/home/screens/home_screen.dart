import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/neon_text.dart';
import '../../../widgets/particle_field.dart';
import '../../../widgets/rank_badge.dart';
import '../widgets/animated_play_button.dart';
import '../widgets/home_menu_card.dart';
import '../widgets/friends_menu_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: AppGradients.backgroundGradient,
            ),
          ),
          const ParticleField(particleCount: 35),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Top bar
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar
                      GestureDetector(
                        onTap: () => context.push('/profile'),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.purpleNeon,
                              width: 2,
                            ),
                            color: AppColors.surfaceLight,
                          ),
                          child: Center(
                            child: Text(
                              user?.username.isNotEmpty == true
                                  ? user!.username[0].toUpperCase()
                                  : 'G',
                              style: AppTextStyles.headlineSmall.copyWith(
                                color: AppColors.purpleGlow,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.username ?? 'Guest',
                              style: AppTextStyles.labelLarge,
                            ),
                            Row(
                              children: [
                                RankBadge(
                                  tier: user?.rankTier ?? 0,
                                  size: 16,
                                  showLabel: false,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  user?.rankName ?? 'Bronze',
                                  style: AppTextStyles.labelSmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _CurrencyPill(
                                icon: Icons.toll,
                                value: '${user?.influencePoints ?? 0}',
                                color: AppColors.cyan,
                              ),
                              const SizedBox(height: 8),
                              _CurrencyPill(
                                icon: Icons.diamond,
                                value: '${user?.syndicateCoins ?? 0}',
                                color: AppColors.gold,
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => context.push('/settings'),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.white05,
                                border: Border.all(
                                  color: AppColors.glassBorder,
                                ),
                              ),
                              child: const Icon(
                                Icons.settings,
                                color: AppColors.white50,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Logo
                  const NeonText(
                    text: 'CITY OF LIES',
                    fontSize: 28,
                    color: AppColors.purpleNeon,
                    glowRadius: 25,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'SEASON 1',
                    style: AppTextStyles.labelSmall.copyWith(
                      letterSpacing: 4,
                      color: AppColors.gold,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Play button
                  AnimatedPlayButton(
                    onPressed: () => context.push('/matchmaking'),
                  ),

                  const SizedBox(height: 16),

                  // Game mode buttons
                  Row(
                    children: [
                      Expanded(
                        child: _ModeButton(
                          label: 'RANKED',
                          icon: Icons.military_tech,
                          color: AppColors.gold,
                          onTap: () => context.push('/matchmaking'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ModeButton(
                          label: 'CASUAL',
                          icon: Icons.sports_esports,
                          color: AppColors.cyan,
                          onTap: () => context.push('/matchmaking'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Menu grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: screenWidth > 400 ? 3 : 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.1,
                    children: [
                      HomeMenuCard(
                        title: 'Family',
                        icon: Icons.groups,
                        color: AppColors.purpleNeon,
                        onTap: () => context.push('/family'),
                      ),
                      HomeMenuCard(
                        title: 'Battle Pass',
                        icon: Icons.stars,
                        color: AppColors.gold,
                        onTap: () => context.push('/battle-pass'),
                      ),
                      HomeMenuCard(
                        title: 'Store',
                        icon: Icons.storefront,
                        color: AppColors.cyan,
                        onTap: () => context.push('/store'),
                      ),
                      HomeMenuCard(
                        title: 'Rankings',
                        icon: Icons.leaderboard,
                        color: AppColors.mintGreen,
                        onTap: () => context.push('/rankings'),
                      ),
                      HomeMenuCard(
                        title: 'Leaderboard',
                        icon: Icons.emoji_events,
                        color: AppColors.gold,
                        onTap: () => context.push('/leaderboard'),
                      ),
                      FriendsMenuCard(onTap: () => context.push('/friends')),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrencyPill extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;
  const _CurrencyPill({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  const _ModeButton({
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: color.withValues(alpha: 0.08),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
