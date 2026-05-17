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
import '../../../widgets/neon_text.dart';
import '../../../widgets/particle_field.dart';
import '../widgets/lobby_player_card.dart';
import '../widgets/lobby_timer_widget.dart';
import '../widgets/lobby_header_pill.dart';
import '../widgets/role_reveal_panel.dart';
import '../widgets/mic_emoji_controls.dart';
import '../widgets/lobby_action_bar.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});
  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with TickerProviderStateMixin {
  String? _selectedVoteTarget;
  String? _nightActionTarget;
  final Map<String, String?> _playerEmojis = {};

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final phase = gameState.phase;
    final localPlayer = gameState.localPlayer;

    return Scaffold(
      body: Stack(children: [
        // ── Phase-reactive background ──
        AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          decoration: BoxDecoration(
            gradient: phase.isNight || phase.isMorning
                ? AppGradients.nightOverlay
                : AppGradients.backgroundGradient),
        ),

        // ── Ambient particles ──
        RepaintBoundary(child: ParticleField(
          particleCount: phase.isNight ? 10 : 18,
          particleColor: phase.isNight
              ? AppColors.purpleDeep
              : AppColors.purpleNeon,
        )),

        SafeArea(child: Column(children: [
          const SizedBox(height: 6),

          // ═══ HEADER PILL ═══
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LobbyHeaderPill(
              phase: phase,
              roundNumber: gameState.roundNumber,
              aliveCount: gameState.alivePlayers.length),
          ),

          const SizedBox(height: 4),

          // ═══ PLAYER CIRCLE + TIMER + OVERLAYS ═══
          Expanded(child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(alignment: Alignment.center, children: [
                // Circular player layout — uses LayoutBuilder for responsive sizing
                _buildPlayerCircle(
                  gameState, constraints.maxWidth, constraints.maxHeight),

                // Center timer
                if (gameState.timeRemaining > 0 &&
                    phase != GamePhase.result &&
                    phase != GamePhase.morningReveal)
                  LobbyTimerWidget(
                    seconds: gameState.timeRemaining,
                    maxSeconds: _maxSecondsForPhase(phase),
                    phase: phase),

                // Morning reveal cinematic
                if (phase.isMorning)
                  _buildMorningOverlay(gameState),

                // Night civilian overlay
                if (phase.isNight && localPlayer != null &&
                    !localPlayer.isMafia &&
                    localPlayer.role == GameRole.civilian)
                  _buildNightOverlay(),

                // Runoff overlay
                if (phase.isRunoff && gameState.tiedPlayerIds.isNotEmpty)
                  _buildRunoffOverlay(gameState),

                // Result overlay
                if (phase == GamePhase.result)
                  _buildResultOverlay(gameState),

                // Mic + Emoji (bottom-right, outside overlays)
                if (_showMicControls(phase))
                  Positioned(
                    bottom: 4, right: 12,
                    child: MicEmojiControls(
                      isMuted: localPlayer?.voiceState == VoiceState.muted,
                      isSpeaking: localPlayer?.isSpeaking ?? false,
                      onToggleMic: () =>
                          ref.read(gameProvider.notifier).toggleMute(),
                      onEmojiSend: (emoji) =>
                          _sendEmoji(gameState.localPlayerId, emoji),
                    ),
                  ),
              ]);
            },
          )),

          // ═══ ROLE REVEAL (during role assignment) ═══
          if (phase == GamePhase.roleAssignment && localPlayer?.role != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
              child: RoleRevealPanel(role: localPlayer!.role),
            ),

          // ═══ ACTION BAR ═══
          LobbyActionBar(
            phase: phase,
            gameState: gameState,
            localPlayer: localPlayer,
            selectedVoteTarget: _selectedVoteTarget,
            nightActionTarget: _nightActionTarget,
            onReady: () =>
                ref.read(gameProvider.notifier).toggleReady(),
            onLeaveLobby: () {
              ref.read(gameProvider.notifier).leaveLobby();
              context.go('/home');
            },
            onConfirmVote: _selectedVoteTarget != null
                ? () {
                    ref.read(gameProvider.notifier)
                        .submitVote(_selectedVoteTarget!);
                    setState(() => _selectedVoteTarget = null);
                  }
                : null,
            onSkipVote: () =>
                setState(() => _selectedVoteTarget = null),
            onConfirmNightAction: _nightActionTarget != null
                ? () => _submitNightAction(localPlayer)
                : null,
            onQueueAgain: () {
              ref.read(gameProvider.notifier).resetGame();
              ref.read(gameProvider.notifier).startMatchmaking();
            },
            onReturnHome: () {
              ref.read(gameProvider.notifier).resetGame();
              context.go('/home');
            },
          ),
        ])),
      ]),
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  // DYNAMIC CIRCULAR LAYOUT — responsive, edge-aligned, adaptive radius
  // ────────────────────────────────────────────────────────────────────────

  Widget _buildPlayerCircle(
      GameStateModel gs, double areaW, double areaH) {
    final players = gs.players;
    if (players.isEmpty) return const SizedBox.shrink();

    // Dynamic radius based on player count and available space
    final minDim = min(areaW, areaH);
    final cardSize = _cardSizeForCount(players.length);
    final safeMargin = cardSize / 2 + 10; // prevent edge clipping

    // Scale radius: more players → larger radius (closer to edges)
    double baseRadiusFactor;
    if (players.length <= 6) {
      baseRadiusFactor = 0.32;
    } else if (players.length <= 10) {
      baseRadiusFactor = 0.36;
    } else {
      baseRadiusFactor = 0.40;
    }

    // Ensure radius fits within safe margins
    final maxRadius = (minDim / 2) - safeMargin;
    final radius = min(minDim * baseRadiusFactor, maxRadius);

    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.center,
        children: List.generate(players.length, (i) {
          final angle =
              (2 * pi * i / players.length) - (pi / 2);
          final x = cos(angle) * radius;
          final y = sin(angle) * radius;
          final player = players[i];
          final isSelected = _selectedVoteTarget == player.id ||
              _nightActionTarget == player.id;
          final isTied = gs.phase.isRunoff &&
              gs.tiedPlayerIds.contains(player.id);
          // In runoff, fade non-tied alive players
          final isFaded = gs.phase.isRunoff &&
              gs.tiedPlayerIds.isNotEmpty &&
              !gs.tiedPlayerIds.contains(player.id) &&
              player.isAlive;

          return Transform.translate(
            offset: Offset(x, y),
            child: RepaintBoundary(
              child: LobbyPlayerCard(
                player: player,
                isSelected: isSelected,
                isLocalPlayer: player.id == gs.localPlayerId,
                isTied: isTied,
                isFaded: isFaded,
                floatingEmoji: _playerEmojis[player.id],
                size: cardSize,
                onTap: () => _onPlayerTap(player, gs),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Smaller cards when more players to avoid overlap
  double _cardSizeForCount(int count) {
    if (count <= 6) return 52;
    if (count <= 10) return 46;
    return 40;
  }

  // ────────────────────────────────────────────────────────────────────────
  // INTERACTIONS
  // ────────────────────────────────────────────────────────────────────────

  void _onPlayerTap(PlayerModel player, GameStateModel gs) {
    if (!player.isAlive || player.id == gs.localPlayerId) return;
    final lp = gs.localPlayer;
    if (lp == null || !lp.isAlive) return;

    if (gs.phase == GamePhase.voting || gs.phase == GamePhase.runoff) {
      setState(() => _selectedVoteTarget = player.id);
    } else if (gs.phase == GamePhase.night) {
      setState(() => _nightActionTarget = player.id);
    }
  }

  void _submitNightAction(PlayerModel? lp) {
    if (lp == null || _nightActionTarget == null) return;
    final notifier = ref.read(gameProvider.notifier);
    if (lp.isMafia) {
      notifier.submitMafiaAction(_nightActionTarget!);
    } else if (lp.role == GameRole.doctor) {
      notifier.submitDoctorAction(_nightActionTarget!);
    } else if (lp.role == GameRole.detective) {
      notifier.submitDetectiveAction(_nightActionTarget!);
    }
    setState(() => _nightActionTarget = null);
  }

  void _sendEmoji(String? playerId, String emoji) {
    if (playerId == null) return;
    ref.read(gameProvider.notifier).sendEmoji(emoji);
    setState(() => _playerEmojis[playerId] = emoji);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _playerEmojis[playerId] = null);
    });
  }

  bool _showMicControls(GamePhase phase) {
    return phase == GamePhase.day ||
        phase == GamePhase.voting ||
        phase == GamePhase.runoff ||
        phase == GamePhase.night ||
        phase == GamePhase.lobby;
  }

  int _maxSecondsForPhase(GamePhase phase) {
    switch (phase) {
      case GamePhase.roleAssignment:
        return 10;
      case GamePhase.night:
        return 15;
      case GamePhase.day:
        return 30;
      case GamePhase.voting:
        return 15;
      case GamePhase.runoff:
        return 10;
      case GamePhase.elimination:
        return 5;
      case GamePhase.morningReveal:
        return 4;
      default:
        return 60;
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // OVERLAYS
  // ────────────────────────────────────────────────────────────────────────

  Widget _buildMorningOverlay(GameStateModel gs) {
    final msg = gs.morningMessage ?? 'The city awakens...';
    final isDeath = msg.contains('dead');
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(
            isDeath ? Icons.dangerous : Icons.wb_sunny,
            color: (isDeath ? AppColors.crimsonRed : AppColors.gold)
                .withValues(alpha: 0.5),
            size: 40),
          const SizedBox(height: 10),
          NeonText(
            text: isDeath ? 'SOMEONE FELL' : 'ALL SURVIVED',
            fontSize: 20,
            color: isDeath ? AppColors.crimsonRed : AppColors.mintGreen,
            glowRadius: 15),
          const SizedBox(height: 6),
          Text(msg, style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.white50)),
        ]),
      ),
    );
  }

  Widget _buildNightOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.nightlight_round,
            color: AppColors.purpleGlow.withValues(alpha: 0.5), size: 40),
          const SizedBox(height: 8),
          NeonText(text: 'NIGHT FALLS', fontSize: 18,
            color: AppColors.purpleGlow.withValues(alpha: 0.6)),
          const SizedBox(height: 4),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.mic_off,
              color: AppColors.crimsonRed.withValues(alpha: 0.5), size: 12),
            const SizedBox(width: 4),
            Text('Microphone muted',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.crimsonRed.withValues(alpha: 0.5))),
          ]),
        ]),
      ),
    );
  }

  Widget _buildRunoffOverlay(GameStateModel gs) {
    return IgnorePointer(
      child: Container(
        color: Colors.black.withValues(alpha: 0.25),
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            NeonText(text: 'SUDDEN DEATH', fontSize: 20,
              color: AppColors.crimsonRed),
            const SizedBox(height: 4),
            Text(
              '${gs.tiedPlayerIds.length} players tied — vote again',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.crimsonRed.withValues(alpha: 0.6))),
          ]),
        ),
      ),
    );
  }

  Widget _buildResultOverlay(GameStateModel gs) {
    final isWinner = gs.winner == WinningSide.civilians
        ? !(gs.localPlayer?.isMafia ?? false)
        : (gs.localPlayer?.isMafia ?? false);
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          NeonText(
            text: gs.winner == WinningSide.mafia
                ? 'MAFIA WINS'
                : 'CIVILIANS WIN',
            fontSize: 28,
            color: gs.winner == WinningSide.mafia
                ? AppColors.crimsonRed
                : AppColors.mintGreen,
            glowRadius: 28),
          const SizedBox(height: 12),
          Text(
            isWinner ? '🎉 VICTORY!' : '💀 DEFEAT',
            style: AppTextStyles.headlineLarge.copyWith(
              color: isWinner ? AppColors.gold : AppColors.white50)),
        ]),
      ),
    );
  }
}
