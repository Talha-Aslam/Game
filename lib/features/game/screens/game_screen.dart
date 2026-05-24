import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mafia_wars/providers/matchmaking_provider.dart';
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
import '../widgets/night_overlay_panel.dart';
import '../widgets/lobby_countdown_overlay.dart';
import '../widgets/graveyard_panel.dart';
import '../widgets/elimination_animation.dart';

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

    // Reset selections on phase change
    ref.listen(gameProvider.select((state) => state.phase), (prev, next) {
      if (prev != next && prev != null) {
        setState(() {
          _selectedVoteTarget = null;
          _nightActionTarget = null;
        });
      }
    });

    // Navigate to result screen when game ends
    ref.listen(gameProvider.select((state) => state.phase), (prev, next) {
      if (next == GamePhase.result && prev != GamePhase.result) {
        Future.microtask(() {
          if (!mounted) return;
          if (!context.mounted) return;
          context.go('/game/result');
        });
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;

        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text(
              'Leave Game?',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Are you sure you want to leave the game in progress?',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.white50),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Leave',
                  style: TextStyle(color: AppColors.crimsonRed),
                ),
              ),
            ],
          ),
        );

        if (confirm == true && context.mounted) {
          ref.read(gameProvider.notifier).leaveLobby();
          context.go('/home');
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // ── Phase-reactive background ──
            AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              decoration: BoxDecoration(
                gradient: phase.isNight || phase.isMorning
                    ? AppGradients.nightOverlay
                    : AppGradients.backgroundGradient,
              ),
            ),

            // ── Ambient particles ──
            RepaintBoundary(
              child: ParticleField(
                particleCount: phase.isNight ? 10 : 18,
                particleColor: phase.isNight
                    ? AppColors.purpleDeep
                    : AppColors.purpleNeon,
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 6),

                  // ═══ HEADER PILL ═══
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: LobbyHeaderPill(
                      phase: phase,
                      roundNumber: gameState.roundNumber,
                      aliveCount: gameState.alivePlayers.length,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // ═══ PLAYER CIRCLE + TIMER + OVERLAYS ═══
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // Circular player layout
                            _buildPlayerCircle(
                              gameState,
                              constraints.maxWidth,
                              constraints.maxHeight,
                            ),

                            // Center timer (not during lobby countdown, result, or morning)
                            if (gameState.timeRemaining > 0 &&
                                phase != GamePhase.result &&
                                phase != GamePhase.morningReveal &&
                                phase != GamePhase.lobby)
                              LobbyTimerWidget(
                                seconds: gameState.timeRemaining,
                                maxSeconds: _maxSecondsForPhase(
                                  phase,
                                  gameState,
                                ),
                                phase: phase,
                              ),

                            // ── LOBBY COUNTDOWN OVERLAY ──
                            if (phase == GamePhase.lobby)
                              Positioned.fill(
                                child: LobbyCountdownOverlay(
                                  countdown: gameState.lobbyCountdown,
                                  tickingActive: gameState.lobbyTickingActive,
                                  showBeginsCinematic:
                                      gameState.showBeginsCinematic,
                                ),
                              ),

                            // ── NIGHT PHASE OVERLAY ──
                            if (phase.isNight)
                              Positioned.fill(
                                child: NightOverlayPanel(
                                  subPhase: gameState.nightSubPhase,
                                  localPlayer: localPlayer,
                                  detectiveResult: gameState.detectiveResult,
                                  detectiveTargetId:
                                      gameState.detectiveTargetId,
                                  detectiveResultRevealed:
                                      gameState.detectiveResultRevealed,
                                  mafiaChannelOpen: gameState.mafiaChannelOpen,
                                  players: gameState.players,
                                ),
                              ),

                            // ── MORNING / DAWN REVEAL ──
                            if (phase.isMorning)
                              Positioned.fill(
                                child: _buildDawnOverlay(gameState),
                              ),

                            // ── RUNOFF OVERLAY ──
                            if (phase.isRunoff &&
                                gameState.tiedPlayerIds.isNotEmpty)
                              Positioned.fill(
                                child: _buildRunoffOverlay(gameState),
                              ),

                            if (_showMicControls(phase))
                              Builder(
                                builder: (context) {
                                  final isForcedMuted =
                                      phase == GamePhase.roleAssignment ||
                                      (phase.isNight &&
                                          !(localPlayer?.isMafia == true &&
                                              gameState.mafiaChannelOpen) &&
                                          !(localPlayer?.role ==
                                                  GameRole.detective &&
                                              gameState.nightSubPhase ==
                                                  NightSubPhase
                                                      .detectiveActing));
                                  final effectivelyMuted =
                                      localPlayer?.voiceState ==
                                          VoiceState.muted ||
                                      isForcedMuted;

                                  return Positioned(
                                    bottom: 4,
                                    right: 12,
                                    child: MicEmojiControls(
                                      isMuted: effectivelyMuted,
                                      isSpeaking:
                                          localPlayer?.isSpeaking ?? false,
                                      onToggleMic: isForcedMuted
                                          ? null
                                          : () => ref
                                                .read(gameProvider.notifier)
                                                .toggleMute(),
                                      onEmojiSend: (emoji) => _sendEmoji(
                                        gameState.localPlayerId,
                                        emoji,
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        );
                      },
                    ),
                  ),

                  // ═══ GRAVEYARD PANEL ═══
                  if (gameState.deadPlayers.isNotEmpty &&
                      phase != GamePhase.lobby &&
                      phase != GamePhase.matchmaking &&
                      phase != GamePhase.result)
                    GraveyardPanel(deadPlayers: gameState.deadPlayers),

                  // ═══ ROLE REVEAL (during role assignment) ═══
                  if (phase == GamePhase.roleAssignment &&
                      localPlayer?.role != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 2,
                      ),
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
                            ref
                                .read(gameProvider.notifier)
                                .submitVote(_selectedVoteTarget!);
                          }
                        : null,
                    onSkipVote: () =>
                        setState(() => _selectedVoteTarget = null),
                    onConfirmNightAction: _nightActionTarget != null
                        ? () => _submitNightAction(localPlayer)
                        : null,
                    onQueueAgain: () {
                      ref.read(gameProvider.notifier).resetGame();
                      ref.read(matchmakingServiceProvider).startSearching();
                      context.go('/matchmaking');
                    },
                    onReturnHome: () {
                      ref.read(gameProvider.notifier).resetGame();
                      context.go('/home');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────
  // DYNAMIC CIRCULAR LAYOUT
  // ────────────────────────────────────────────────────────────────────────

  Widget _buildPlayerCircle(GameStateModel gs, double areaW, double areaH) {
    final players = gs.players;
    if (players.isEmpty) return const SizedBox.shrink();

    final minDim = min(areaW, areaH);
    final cardSize = _cardSizeForCount(players.length);
    final safeMargin = cardSize / 2 + 10;

    double baseRadiusFactor;
    if (players.length <= 6) {
      baseRadiusFactor = 0.32;
    } else if (players.length <= 10) {
      baseRadiusFactor = 0.36;
    } else {
      baseRadiusFactor = 0.40;
    }

    final maxRadius = (minDim / 2) - safeMargin;
    final radius = min(minDim * baseRadiusFactor, maxRadius);

    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.center,
        children: List.generate(players.length, (i) {
          final angle = (2 * pi * i / players.length) - (pi / 2);
          final x = cos(angle) * radius;
          final y = sin(angle) * radius;
          final player = players[i];
          final isSelected =
              _selectedVoteTarget == player.id ||
              _nightActionTarget == player.id;
          final isTied =
              gs.phase.isRunoff && gs.tiedPlayerIds.contains(player.id);
          final isFaded =
              gs.phase.isRunoff &&
              gs.tiedPlayerIds.isNotEmpty &&
              !gs.tiedPlayerIds.contains(player.id) &&
              player.isAlive;

          return Transform.translate(
            offset: Offset(x, y),
            child: RepaintBoundary(
              child: EliminationAnimation(
                isEliminating: player.isEliminating,
                size: cardSize,
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
            ),
          );
        }),
      ),
    );
  }

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
      // Only allow selection during local player's turn
      if (gs.isLocalPlayerNightTurn) {
        setState(() => _nightActionTarget = player.id);
      }
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

  int _maxSecondsForPhase(GamePhase phase, GameStateModel gs) {
    switch (phase) {
      case GamePhase.roleAssignment:
        return 10;
      case GamePhase.night:
        // Max depends on sub-phase
        final sub = gs.nightSubPhase;
        if (sub == NightSubPhase.mafiaActing) return 20;
        if (sub == NightSubPhase.doctorActing) return 10;
        if (sub == NightSubPhase.detectiveActing) return 10;
        return 40;
      case GamePhase.day:
        return 60;
      case GamePhase.voting:
        return 10;
      case GamePhase.runoff:
        return 10;
      case GamePhase.elimination:
        return 5;
      case GamePhase.morningReveal:
        return 5;
      default:
        return 60;
    }
  }

  // ────────────────────────────────────────────────────────────────────────
  // OVERLAYS
  // ────────────────────────────────────────────────────────────────────────

  /// ── Dawn / Morning Reveal — cinematic Game Master text ──
  Widget _buildDawnOverlay(GameStateModel gs) {
    final msg = gs.morningMessage ?? gs.dawnMessage ?? 'The city awakens...';
    final isDeath = msg.contains('eliminated') || msg.contains('tragedy');

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (_, t, _) {
        return Container(
          color: Colors.black.withValues(alpha: 0.5 * t),
          child: Center(
            child: Opacity(
              opacity: t.clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - t)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Sun/skull icon
                    Icon(
                      isDeath ? Icons.dangerous : Icons.wb_sunny,
                      color: (isDeath ? AppColors.crimsonRed : AppColors.gold)
                          .withValues(alpha: 0.6),
                      size: 44,
                    ),
                    const SizedBox(height: 12),
                    // Label
                    NeonText(
                      text: isDeath ? 'A TRAGEDY' : 'ALL SURVIVED',
                      fontSize: 22,
                      color: isDeath
                          ? AppColors.crimsonRed
                          : AppColors.mintGreen,
                      glowRadius: 16,
                    ),
                    const SizedBox(height: 10),
                    // Game Master message
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        msg,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.white50,
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRunoffOverlay(GameStateModel gs) {
    return IgnorePointer(
      child: Container(
        color: Colors.black.withValues(alpha: 0.25),
        padding: const EdgeInsets.only(bottom: 130),
        alignment: Alignment.bottomCenter,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NeonText(
              text: 'SUDDEN DEATH',
              fontSize: 20,
              color: AppColors.crimsonRed,
            ),
            const SizedBox(height: 4),
            Text(
              '${gs.tiedPlayerIds.length} players tied — vote again',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.crimsonRed.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
