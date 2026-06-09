import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../providers/family_war_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/game_provider.dart';
import '../../../providers/matchmaking_provider.dart';
import '../../../widgets/neon_text.dart';
import '../../../widgets/glass_button.dart';
import '../../game/widgets/lobby_player_card.dart';

class FamilyWarScreen extends ConsumerWidget {
  const FamilyWarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warState = ref.watch(familyWarProvider);
    final user = ref.watch(authProvider).user;
    final isHost = warState.creatorId == user?.id;

    ref.listen(familyWarProvider, (prev, next) {
      if (next.isStarted && next.roomId != null) {
        ref.read(gameProvider.notifier).connectToGame(next.roomId!);
        context.go('/game');
      }
    });

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          ref.read(webSocketServiceProvider).send('leave_war_lobby');
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppGradients.backgroundGradient),
          child: SafeArea(
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
                          text: 'SYNDICATE WAR',
                          fontSize: 22,
                          color: AppColors.crimsonRed,
                          glowRadius: 15,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.crimsonRed.withValues(alpha: 0.1),
                          border: Border.all(color: AppColors.crimsonRed.withValues(alpha: 0.4)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('7v7', style: TextStyle(color: AppColors.crimsonRed, fontWeight: FontWeight.bold, fontSize: 12)),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Rosters
                Expanded(
                  child: Row(
                    children: [
                      // Challenger Roster (Left)
                      Expanded(
                        child: Column(
                          children: [
                            Text('YOUR CLAN', style: AppTextStyles.labelMedium.copyWith(color: AppColors.cyan)),
                            const SizedBox(height: 16),
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: 7,
                                itemBuilder: (context, index) {
                                  if (index < warState.challengerRoster.length) {
                                    final player = warState.challengerRoster[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 16),
                                      child: LobbyPlayerCard(
                                        player: player,
                                        size: 55,
                                        isLocalPlayer: player.id == user?.id,
                                        isHost: player.id == warState.creatorId,
                                      ),
                                    );
                                  }
                                  return _EmptyWarSlot(index: index + 1);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // VS divider
                      Container(
                        width: 2,
                        height: double.infinity,
                        margin: const EdgeInsets.symmetric(vertical: 24),
                        color: AppColors.white10,
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text('VS', style: AppTextStyles.headlineSmall.copyWith(color: AppColors.white30, fontStyle: FontStyle.italic)),
                        ),
                      ),
                      Container(
                        width: 2,
                        height: double.infinity,
                        margin: const EdgeInsets.symmetric(vertical: 24),
                        color: AppColors.white10,
                      ),

                      // Defender Roster (Right)
                      Expanded(
                        child: Column(
                          children: [
                            Text('ENEMY CLAN', style: AppTextStyles.labelMedium.copyWith(color: AppColors.crimsonRed)),
                            const SizedBox(height: 16),
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: 7,
                                itemBuilder: (context, index) {
                                  if (index < warState.defenderRoster.length) {
                                    final player = warState.defenderRoster[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 16),
                                      child: LobbyPlayerCard(
                                        player: player,
                                        size: 55,
                                        isLocalPlayer: player.id == user?.id,
                                      ),
                                    );
                                  }
                                  return _EmptyWarSlot(index: index + 1, isEnemy: true);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Controls
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Expanded(
                        child: GlassButton(
                          label: 'INVITE CLAN',
                          isOutlined: true,
                          glowColor: AppColors.cyan,
                          onPressed: () {
                            ref.read(familyWarProvider.notifier).inviteClan();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Invitations sent to all online family members.'), backgroundColor: AppColors.cyan),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GlassButton(
                          label: isHost ? 'START WAR' : 'WAITING...',
                          glowColor: isHost ? AppColors.crimsonRed : AppColors.white30,
                          onPressed: isHost && warState.challengerRoster.length >= 1 
                            ? () => ref.read(familyWarProvider.notifier).startWar()
                            : null,
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

class _EmptyWarSlot extends StatelessWidget {
  final int index;
  final bool isEnemy;
  const _EmptyWarSlot({required this.index, this.isEnemy = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white05,
              border: Border.all(color: AppColors.white10, style: BorderStyle.none),
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(color: AppColors.white10, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(isEnemy ? 'WAITING' : 'OPEN SLOT', style: const TextStyle(color: AppColors.white10, fontSize: 8)),
        ],
      ),
    );
  }
}
