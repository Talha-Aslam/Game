import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/particle_field.dart';
import '../widgets/bottom_nav_bar_glass.dart';
import '../widgets/player_identity_card.dart';
import '../widgets/battle_pass_mini_widget.dart';
import '../widgets/matchmaking_button.dart';
import '../widgets/daily_bounty_panel.dart';
import '../widgets/character_showcase_widget.dart';
import '../widgets/event_carousel_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      body: Stack(children: [
        // ── Background ──
        Container(decoration: const BoxDecoration(gradient: AppGradients.backgroundGradient)),

        // ── Ambient particles ──
        const ParticleField(particleCount: 30),

        // ── City environment overlay (neon haze) ──
        Positioned.fill(child: IgnorePointer(child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center, radius: 0.9,
              colors: [
                AppColors.purpleNeon.withValues(alpha: 0.02),
                Colors.transparent,
                AppColors.cyan.withValues(alpha: 0.01),
              ],
            ),
          ),
        ))),

        // ── Main content ──
        SafeArea(child: Column(children: [
          // ═══ TOP BAR ═══
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Player identity (top-left)
              const PlayerIdentityCard(),
              const Spacer(),
              // Currency pills + Settings
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Row(children: [
                  _CurrencyPill(icon: Icons.toll, value: '${user?.influencePoints ?? 0}', color: AppColors.cyan),
                  const SizedBox(width: 6),
                  _CurrencyPill(icon: Icons.diamond, value: '${user?.syndicateCoins ?? 0}', color: AppColors.gold),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => context.push('/settings'),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: AppColors.white05,
                            border: Border.all(color: AppColors.glassBorder, width: 0.5)),
                          child: const Icon(Icons.settings, color: AppColors.white50, size: 16)),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 6),
                // Battle Pass widget (top-right)
                const BattlePassMiniWidget(),
              ]),
            ]),
          ),

          // ═══ CENTER — CHARACTER SHOWCASE ═══
          const Expanded(child: Stack(children: [
            // Character
            Center(child: CharacterShowcaseWidget()),
            // Daily bounty (floating left)
            Positioned(left: 10, top: 50, child: DailyBountyPanel()),
          ])),

          // ═══ EVENT CAROUSEL ═══
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: EventCarouselWidget(),
          ),

          const SizedBox(height: 10),

          // ═══ MATCHMAKING BUTTON + MODE TOGGLE ═══
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: MatchmakingButton(
              onPlay: () => context.push('/matchmaking'),
            ),
          ),

          const SizedBox(height: 10),

          // ═══ BOTTOM NAV BAR ═══
          BottomNavBarGlass(
            currentIndex: -1, // No tab active on home
            onTap: (i) {
              switch (i) {
                case 0: context.push('/friends'); break;
                case 1: context.push('/family'); break;
                case 2: context.push('/store'); break;
                case 3: context.push('/rankings'); break;
              }
            },
          ),
        ])),
      ]),
    );
  }
}

// ── Compact currency pill ──
class _CurrencyPill extends StatelessWidget {
  final IconData icon; final String value; final Color color;
  const _CurrencyPill({required this.icon, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: color.withValues(alpha: 0.06),
            border: Border.all(color: color.withValues(alpha: 0.2), width: 0.5)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: color, size: 12),
            const SizedBox(width: 3),
            Text(value, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
          ]),
        ),
      ),
    );
  }
}
