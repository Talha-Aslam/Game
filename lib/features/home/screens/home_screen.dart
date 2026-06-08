import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mafia_wars/providers/custom_room_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/glass_button.dart';
import '../../../providers/family_provider.dart';
import '../../../widgets/particle_field.dart';
import '../widgets/bottom_nav_bar_glass.dart';
import '../widgets/battle_pass_mini_widget.dart';
import '../widgets/matchmaking_button.dart';
import '../widgets/daily_bounty_panel.dart';
import '../widgets/avatar_showcase_widget.dart';
import '../widgets/event_carousel_widget.dart';

import 'package:mafia_wars/providers/matchmaking_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedMode = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ws = ref.read(webSocketServiceProvider);
      if (!ws.isConnected) {
        ws.connectLobby();
      }
      ws.eventStream.listen((msg) {
        if (!mounted) return;

        switch (msg.event) {
          case 'friend_request_accepted':
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
            break;

          case 'family_invite_received':
            _showFamilyInviteDialog(msg.data);
            break;

          case 'gift_received':
            _showGiftReceivedSnackBar(msg.data);
            break;

          case 'family_role_updated':
            if (msg.data['new_role'] == 'boss') {
              _showCongratulatoryDialog();
            }
            break;
            
          case 'custom_room_invite':
            _showCustomRoomInviteDialog(msg.data);
            break;
        }
      });
    });
  }

  void _showCustomRoomInviteDialog(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: Colors.black.withValues(alpha: 0.85),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: AppColors.cyan.withValues(alpha: 0.3))),
          title: const Text('CUSTOM ROOM INVITE', style: TextStyle(color: AppColors.cyan, letterSpacing: 2, fontSize: 18, fontWeight: FontWeight.w900)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.sports_esports, color: AppColors.cyan, size: 48),
              const SizedBox(height: 16),
              Text('${data['sender_name']} has invited you to a custom match.', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.white70, fontSize: 14)),
              const SizedBox(height: 4),
              Text('Room: ${data['room_id']?.split('_').last ?? "Unknown"}', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('DECLINE', style: TextStyle(color: AppColors.white30))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.cyan),
              onPressed: () {
                Navigator.pop(ctx);
                ref.read(customRoomProvider.notifier).joinRoom(data['room_id']);
                context.push('/game/custom');
              },
              child: const Text('JOIN ROOM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePlay() {
    switch (_selectedMode) {
      case 0: // Ranked
      case 1: // Casual
        context.push('/matchmaking');
        break;
      case 2: // Family War
        context.push('/family/war');
        break;
      case 3: // Custom
        _showCustomRoomEntrySheet();
        break;
    }
  }

  void _showCustomRoomEntrySheet() {
    final codeController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.85),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
              border: Border.all(color: AppColors.white10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.white10,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'CUSTOM MATCH',
                  style: TextStyle(
                    color: AppColors.purpleGlow,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 32),

                // Create Button
                SizedBox(
                  width: double.infinity,
                  child: GlassButton(
                    label: 'CREATE NEW ROOM',
                    glowColor: AppColors.purpleNeon,
                    onPressed: () {
                      Navigator.pop(context);
                      ref.read(customRoomProvider.notifier).createRoom();
                      context.push('/game/custom');
                    },
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Row(
                    children: [
                      Expanded(child: Divider(color: AppColors.white10)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: AppColors.white30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: AppColors.white10)),
                    ],
                  ),
                ),

                // Join Field & Button
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white05,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: codeController,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                            hintText: 'ENTER ROOM CODE',
                            hintStyle: TextStyle(
                              color: AppColors.white30,
                              letterSpacing: 1,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final code = codeController.text.trim();
                          if (code.isNotEmpty) {
                            final success = await ref
                                .read(customRoomProvider.notifier)
                                .joinRoom('custom_$code');
                            if (context.mounted) {
                              if (success) {
                                Navigator.pop(context);
                                context.push('/game/custom');
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Room not found or is full.'),
                                    backgroundColor: AppColors.crimsonRed,
                                  ),
                                );
                              }
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.cyan,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text(
                            'JOIN',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFamilyInviteDialog(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: Colors.black.withValues(alpha: 0.85),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: AppColors.purpleNeon.withValues(alpha: 0.3),
            ),
          ),
          title: const Text(
            'FAMILY INVITATION',
            style: TextStyle(
              color: AppColors.purpleGlow,
              letterSpacing: 2,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shield, color: AppColors.purpleGlow, size: 48),
              const SizedBox(height: 16),
              Text(
                '${data['sender_name']} has invited you to join',
                style: const TextStyle(color: AppColors.white70, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                data['family_name'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'DECLINE',
                style: TextStyle(color: AppColors.white30),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purpleNeon,
              ),
              onPressed: () {
                ref
                    .read(familyProvider.notifier)
                    .applyToFamily(data['family_id'], isInvite: true);
                Navigator.pop(ctx);
              },
              child: const Text(
                'ACCEPT & JOIN',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGiftReceivedSnackBar(Map<String, dynamic> data) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.card_giftcard, color: AppColors.gold, size: 20),
            const SizedBox(width: 12),
            Text(
              '${data['sender_name']} sent you ${data['amount']} Syndicate Coins!',
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showCongratulatoryDialog() {
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: AlertDialog(
          backgroundColor: Colors.black.withValues(alpha: 0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: AppColors.gold.withValues(alpha: 0.5)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.workspace_premium,
                color: AppColors.gold,
                size: 64,
              ),
              const SizedBox(height: 20),
              const Text(
                'CONGRATULATIONS!',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'You have been promoted to the rank of BOSS. The future of the family is in your hands.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.white70, fontSize: 14),
              ),
              const SizedBox(height: 32),
              GlassButton(
                label: 'I ACCEPT THE THRONE',
                glowColor: AppColors.gold,
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    );
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
                    onPlay: _handlePlay,
                    onModeChange: (i) => setState(() => _selectedMode = i),
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
