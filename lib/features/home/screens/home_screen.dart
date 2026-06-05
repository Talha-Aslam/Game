import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/notification_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/particle_field.dart';
import '../widgets/bottom_nav_bar_glass.dart';
import '../widgets/battle_pass_mini_widget.dart';
import '../widgets/matchmaking_button.dart';
import '../widgets/daily_bounty_panel.dart';
import '../widgets/avatar_showcase_widget.dart';
import '../widgets/event_carousel_widget.dart';

import '../../../providers/game_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ws = ref.read(wsServiceProvider);
      if (!ws.isConnected) {
        ws.connectLobby();
      }
      ws.eventStream.listen((msg) {
        if (msg.event == 'friend_request_accepted') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  (msg.data['message'] as String?) ??
                      'Friend request accepted!',
                ),
                backgroundColor: AppColors.purpleNeon,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final notifications = ref.watch(notificationProvider);
    final unreadMessages = notifications.unreadMessages.values.fold(
      0,
      (sum, count) => sum + count,
    );

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: SafeArea(
        child: BottomNavBarGlass(
          currentIndex: -1,
          friendsNotificationCount: unreadMessages > 0 ? unreadMessages : 0,
          onTap: (index) {
            if (index == 0) {
              context.push('/friends');
            } else if (index == 1) {
              context.push('/family');
            } else if (index == 2) {
              context.push('/store');
            } else if (index == 3) {
              context.push('/rankings');
            }
          },
        ),
      ),
      body: Stack(
        children: [
          // ── Background gradient ──
          Container(
            decoration: const BoxDecoration(
              gradient: AppGradients.backgroundGradient,
            ),
          ),

          // ── Ambient particles ──
          const ParticleField(particleCount: 30),

          // ── City neon haze overlay ──
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.9,
                    colors: [
                      AppColors.purpleNeon.withValues(alpha: 0.02),
                      Colors.transparent,
                      AppColors.cyan.withValues(alpha: 0.01),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Main content column ──
          SafeArea(
            child: Column(
              children: [
                // ══════════════════════════════════════════
                //  TOP BAR — currencies left, gear far right
                // ══════════════════════════════════════════
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ── Currency pills (left-aligned) ──
                      _CurrencyPill(
                        icon: Icons.toll,
                        value: '${user?.influencePoints ?? 0}',
                        color: AppColors.cyan,
                      ),
                      const SizedBox(width: 6),
                      _CurrencyPill(
                        icon: Icons.diamond,
                        value: '${user?.syndicateCoins ?? 0}',
                        color: AppColors.gold,
                      ),

                      const Spacer(),

                      // ── Battle Pass mini (center-right) ──
                      const BattlePassMiniWidget(),

                      const SizedBox(width: 8),

                      // ── Settings gear (far right) ──
                      GestureDetector(
                        onTap: () => context.push('/settings'),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: AppColors.white05,
                                border: Border.all(
                                  color: AppColors.glassBorder,
                                  width: 0.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.settings,
                                color: AppColors.white50,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ══════════════════════════════════════════
                //  CENTER — Profile Showcase Deck
                // ══════════════════════════════════════════
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Avatar card — centered with top padding to leave
                      // room for the avatar ring overflow above the card.
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: GestureDetector(
                          onTap: () => context.push('/profile'),
                          child: const AvatarShowcaseWidget(),
                        ),
                      ),

                      // Daily bounty panel — floating on the left
                      const Positioned(
                        left: 10,
                        top: 16,
                        child: DailyBountyPanel(),
                      ),
                    ],
                  ),
                ),

                // ══════════════════════════════════════════
                //  EVENT CAROUSEL
                // ══════════════════════════════════════════
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: EventCarouselWidget(),
                ),

                const SizedBox(height: 10),

                // ══════════════════════════════════════════
                //  MATCHMAKING BUTTON + MODE TOGGLE
                // ══════════════════════════════════════════
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: MatchmakingButton(
                    onPlay: () => context.push('/matchmaking'),
                  ),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Compact glassmorphic currency pill ────────────────────────────────────────
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: color.withValues(alpha: 0.07),
            border: Border.all(
              color: color.withValues(alpha: 0.22),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 13),
              const SizedBox(width: 4),
              // Overflow-safe value display
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 60),
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
