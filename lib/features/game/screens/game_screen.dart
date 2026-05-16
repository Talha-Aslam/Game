import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../models/game_state_model.dart';
import '../../../models/player_model.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/player_card.dart';
import '../../../widgets/phase_indicator.dart';
import '../../../widgets/game_timer.dart';
import '../../../widgets/glass_button.dart';
import '../../../widgets/neon_text.dart';
import '../../../widgets/particle_field.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});
  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  String? _selectedVoteTarget;
  String? _nightActionTarget;

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final phase = gameState.phase;
    final localPlayer = gameState.localPlayer;
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;

    // Navigate home when game result is shown and user taps
    if (phase == GamePhase.result) {
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          ref.read(gameProvider.notifier).resetGame();
          context.go('/home');
        }
      });
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background based on phase
          AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            decoration: BoxDecoration(
              gradient: phase.isNight
                  ? AppGradients.nightOverlay
                  : phase.isDay
                      ? AppGradients.backgroundGradient
                      : AppGradients.backgroundGradient,
            ),
          ),
          ParticleField(
            particleCount: phase.isNight ? 15 : 25,
            particleColor: phase.isNight ? AppColors.purpleDeep : AppColors.purpleNeon,
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),

                // Top bar: phase + round
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Round ${gameState.roundNumber}', style: AppTextStyles.labelMedium),
                      PhaseIndicator(phase: phase),
                      Text('${gameState.alivePlayers.length} alive', style: AppTextStyles.labelSmall),
                    ],
                  ),
                ),

                // Player circle + timer area
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Players in circular layout
                      _buildPlayerCircle(gameState, screenW, screenH),

                      // Center timer
                      if (gameState.timeRemaining > 0 && phase != GamePhase.result)
                        GameTimer(seconds: gameState.timeRemaining),

                      // Night overlay for civilians
                      if (phase.isNight && localPlayer != null && !localPlayer.isMafia)
                        _buildNightCivilianOverlay(),

                      // Result overlay
                      if (phase == GamePhase.result)
                        _buildResultOverlay(gameState),
                    ],
                  ),
                ),

                // Bottom action bar
                _buildActionBar(gameState, localPlayer),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCircle(GameStateModel gameState, double screenW, double screenH) {
    final players = gameState.players;
    final radius = (screenW < screenH ? screenW : screenH) * 0.30;

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: List.generate(players.length, (i) {
          final angle = (2 * pi * i / players.length) - (pi / 2);
          final x = cos(angle) * radius;
          final y = sin(angle) * radius;
          final player = players[i];

          final isSelected = _selectedVoteTarget == player.id ||
              _nightActionTarget == player.id;

          return Transform.translate(
            offset: Offset(x, y),
            child: PlayerCard(
              player: player,
              isSelected: isSelected,
              isLocalPlayer: player.id == gameState.localPlayerId,
              size: 65,
              onTap: () => _onPlayerTap(player, gameState),
            ),
          );
        }),
      ),
    );
  }

  void _onPlayerTap(PlayerModel player, GameStateModel gameState) {
    if (!player.isAlive) return;
    if (player.id == gameState.localPlayerId) return;

    final localPlayer = gameState.localPlayer;
    if (localPlayer == null || !localPlayer.isAlive) return;

    final phase = gameState.phase;

    if (phase == GamePhase.voting || phase == GamePhase.runoff) {
      setState(() => _selectedVoteTarget = player.id);
    } else if (phase == GamePhase.night) {
      setState(() => _nightActionTarget = player.id);
    }
  }

  Widget _buildNightCivilianOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.nightlight_round, color: AppColors.purpleGlow.withValues(alpha: 0.5), size: 48),
            const SizedBox(height: 12),
            NeonText(text: 'NIGHT FALLS', fontSize: 20, color: AppColors.purpleGlow.withValues(alpha: 0.6)),
            const SizedBox(height: 8),
            Text('Close your eyes...', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white30)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mic_off, color: AppColors.crimsonRed.withValues(alpha: 0.5), size: 16),
                const SizedBox(width: 6),
                Text('Microphone muted', style: AppTextStyles.labelSmall.copyWith(color: AppColors.crimsonRed.withValues(alpha: 0.5))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultOverlay(GameStateModel gameState) {
    final isWinner = gameState.winner == WinningSide.civilians
        ? !(gameState.localPlayer?.isMafia ?? false)
        : (gameState.localPlayer?.isMafia ?? false);

    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NeonText(
              text: gameState.winner == WinningSide.mafia ? 'MAFIA WINS' : 'CIVILIANS WIN',
              fontSize: 32,
              color: gameState.winner == WinningSide.mafia ? AppColors.crimsonRed : AppColors.mintGreen,
              glowRadius: 30,
            ),
            const SizedBox(height: 16),
            Text(
              isWinner ? '🎉 VICTORY!' : '💀 DEFEAT',
              style: AppTextStyles.headlineLarge.copyWith(
                color: isWinner ? AppColors.gold : AppColors.white50,
              ),
            ),
            const SizedBox(height: 24),
            Text('Returning to lobby...', style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBar(GameStateModel gameState, PlayerModel? localPlayer) {
    final phase = gameState.phase;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.8),
        border: Border(top: BorderSide(color: AppColors.glassBorder)),
      ),
      child: SafeArea(
        top: false,
        child: _buildPhaseActions(phase, gameState, localPlayer),
      ),
    );
  }

  Widget _buildPhaseActions(GamePhase phase, GameStateModel gameState, PlayerModel? lp) {
    switch (phase) {
      case GamePhase.roleAssignment:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NeonText(
              text: 'Your role: ${lp?.role?.displayName ?? '???'}',
              fontSize: 18,
              color: _roleColor(lp?.role),
            ),
            const SizedBox(height: 4),
            Text(lp?.role?.description ?? '', style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
          ],
        );

      case GamePhase.night:
        if (lp == null || !lp.isAlive) return _spectatorBar();
        if (lp.isMafia) {
          return Row(
            children: [
              Expanded(
                child: Text('Choose a target to eliminate', style: AppTextStyles.bodySmall),
              ),
              GlassButton(
                label: 'CONFIRM',
                glowColor: AppColors.crimsonRed,
                width: 110,
                height: 40,
                onPressed: _nightActionTarget != null
                    ? () {
                        ref.read(gameProvider.notifier).submitMafiaAction(_nightActionTarget!);
                        setState(() => _nightActionTarget = null);
                      }
                    : null,
              ),
            ],
          );
        } else if (lp.role == GameRole.doctor) {
          return Row(
            children: [
              Expanded(child: Text('Choose a player to protect', style: AppTextStyles.bodySmall)),
              GlassButton(
                label: 'PROTECT',
                glowColor: AppColors.mintGreen,
                width: 110, height: 40,
                onPressed: _nightActionTarget != null
                    ? () {
                        ref.read(gameProvider.notifier).submitDoctorAction(_nightActionTarget!);
                        setState(() => _nightActionTarget = null);
                      }
                    : null,
              ),
            ],
          );
        } else if (lp.role == GameRole.detective) {
          return Row(
            children: [
              Expanded(child: Text('Choose a player to investigate', style: AppTextStyles.bodySmall)),
              GlassButton(
                label: 'INVESTIGATE',
                glowColor: AppColors.purpleNeon,
                width: 120, height: 40,
                onPressed: _nightActionTarget != null
                    ? () {
                        ref.read(gameProvider.notifier).submitDetectiveAction(_nightActionTarget!);
                        setState(() => _nightActionTarget = null);
                      }
                    : null,
              ),
            ],
          );
        }
        return const SizedBox.shrink();

      case GamePhase.day:
        return Row(
          children: [
            Icon(Icons.mic, color: AppColors.online, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text('Discussion phase — speak freely', style: AppTextStyles.bodySmall)),
          ],
        );

      case GamePhase.voting:
      case GamePhase.runoff:
        return Row(
          children: [
            Expanded(
              child: Text(
                _selectedVoteTarget != null ? 'Vote selected' : 'Tap a player to vote',
                style: AppTextStyles.bodySmall,
              ),
            ),
            GlassButton(
              label: 'SKIP',
              isOutlined: true,
              width: 70, height: 38,
              onPressed: () => setState(() => _selectedVoteTarget = null),
            ),
            const SizedBox(width: 8),
            GlassButton(
              label: 'VOTE',
              glowColor: AppColors.gold,
              width: 90, height: 38,
              onPressed: _selectedVoteTarget != null
                  ? () {
                      ref.read(gameProvider.notifier).submitVote(_selectedVoteTarget!);
                    }
                  : null,
            ),
          ],
        );

      case GamePhase.elimination:
        final name = gameState.players
            .where((p) => p.id == gameState.eliminatedPlayerId)
            .map((p) => p.name)
            .firstOrNull ?? 'Unknown';
        return Center(
          child: NeonText(text: '$name has been eliminated', fontSize: 16, color: AppColors.crimsonRed),
        );

      case GamePhase.result:
        return const SizedBox.shrink();

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _spectatorBar() {
    return Row(
      children: [
        Icon(Icons.visibility, color: AppColors.white30, size: 18),
        const SizedBox(width: 8),
        Text('You are spectating', style: AppTextStyles.bodySmall.copyWith(color: AppColors.white30)),
      ],
    );
  }

  Color _roleColor(GameRole? role) {
    switch (role) {
      case GameRole.mafia: return AppColors.crimsonRed;
      case GameRole.doctor: return AppColors.mintGreen;
      case GameRole.detective: return AppColors.purpleNeon;
      case GameRole.civilian: return AppColors.cyan;
      default: return AppColors.white;
    }
  }
}
