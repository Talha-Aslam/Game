import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/game_state_model.dart';
import '../../../models/player_model.dart';
import '../../../widgets/neon_text.dart';

/// Cinematic night overlay — shows role-specific UI based on nightSubPhase
class NightOverlayPanel extends StatefulWidget {
  final NightSubPhase? subPhase;
  final PlayerModel? localPlayer;
  final bool? detectiveResult;
  final String? detectiveTargetId;
  final bool detectiveResultRevealed;
  final bool mafiaChannelOpen;
  final List<PlayerModel> players;

  const NightOverlayPanel({
    super.key,
    this.subPhase,
    this.localPlayer,
    this.detectiveResult,
    this.detectiveTargetId,
    this.detectiveResultRevealed = false,
    this.mafiaChannelOpen = false,
    this.players = const [],
  });

  @override
  State<NightOverlayPanel> createState() => _NightOverlayPanelState();
}

class _NightOverlayPanelState extends State<NightOverlayPanel>
    with TickerProviderStateMixin {
  late AnimationController _pulse;
  late AnimationController _heartbeat;
  late AnimationController _scanLine;
  late AnimationController _glitch;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      duration: const Duration(milliseconds: 1200), vsync: this)
      ..repeat(reverse: true);
    _heartbeat = AnimationController(
      duration: const Duration(milliseconds: 800), vsync: this)
      ..repeat(reverse: true);
    _scanLine = AnimationController(
      duration: const Duration(seconds: 3), vsync: this)
      ..repeat();
    _glitch = AnimationController(
      duration: const Duration(milliseconds: 200), vsync: this);
  }

  @override
  void didUpdateWidget(NightOverlayPanel old) {
    super.didUpdateWidget(old);
    if (widget.detectiveResultRevealed && !old.detectiveResultRevealed) {
      _glitch.forward(from: 0).then((_) => _glitch.reverse());
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    _heartbeat.dispose();
    _scanLine.dispose();
    _glitch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lp = widget.localPlayer;
    if (lp == null || !lp.isAlive) return _civilianOverlay();

    final subPhase = widget.subPhase;
    if (subPhase == null) return _civilianOverlay();

    final isMyTurn = lp.role == subPhase.activeRole;

    // Detective result display (after investigation)
    if (widget.detectiveResultRevealed &&
        lp.role == GameRole.detective &&
        subPhase == NightSubPhase.detectiveActing) {
      return _detectiveResultOverlay();
    }

    if (isMyTurn) {
      switch (lp.role!) {
        case GameRole.mafia:
          return _mafiaActiveOverlay();
        case GameRole.doctor:
          return _doctorActiveOverlay();
        case GameRole.detective:
          return _detectiveActiveOverlay();
        case GameRole.civilian:
          return _civilianOverlay();
      }
    }

    // Not my turn — waiting overlay
    if (lp.isMafia && subPhase == NightSubPhase.mafiaActing) {
      return _mafiaActiveOverlay(); // all mafia see the targeting UI
    }

    return _waitingOverlay(subPhase);
  }

  /// ── Mafia Active: targeting UI ──
  Widget _mafiaActiveOverlay() {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) => IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Colors.transparent,
                AppColors.crimsonRed.withValues(alpha: 0.04 + _pulse.value * 0.03),
              ],
              radius: 1.2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Mafia channel indicator
              if (widget.mafiaChannelOpen)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: AppColors.crimsonRed.withValues(alpha: 0.08),
                    border: Border.all(
                      color: AppColors.crimsonRed.withValues(alpha: 0.2 + _pulse.value * 0.1)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.mic, color: AppColors.crimsonRed.withValues(alpha: 0.7), size: 14),
                    const SizedBox(width: 6),
                    Text('PRIVATE CHANNEL',
                      style: TextStyle(
                        color: AppColors.crimsonRed.withValues(alpha: 0.7),
                        fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                  ]),
                ),
              const SizedBox(height: 16),
              Icon(Icons.dangerous,
                color: AppColors.crimsonRed.withValues(alpha: 0.5 + _pulse.value * 0.3),
                size: 36),
              const SizedBox(height: 8),
              NeonText(
                text: 'YOUR SYNDICATE IS PLANNING...',
                fontSize: 14,
                color: AppColors.crimsonRed,
                glowRadius: 8 + _pulse.value * 6),
              const SizedBox(height: 4),
              Text('Select a target to eliminate',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.crimsonRed.withValues(alpha: 0.5))),
            ],
          ),
        ),
      ),
    );
  }

  /// ── Doctor Active: heartbeat animation ──
  Widget _doctorActiveOverlay() {
    return AnimatedBuilder(
      animation: _heartbeat,
      builder: (_, __) {
        final scale = 1.0 + _heartbeat.value * 0.1;
        return IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.transparent,
                  AppColors.mintGreen.withValues(alpha: 0.03 + _heartbeat.value * 0.02),
                ],
                radius: 1.2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.scale(
                  scale: scale,
                  child: Icon(Icons.favorite,
                    color: AppColors.mintGreen.withValues(alpha: 0.5 + _heartbeat.value * 0.3),
                    size: 36),
                ),
                const SizedBox(height: 10),
                NeonText(
                  text: 'CHOOSE WHO TO SAVE',
                  fontSize: 14,
                  color: AppColors.mintGreen,
                  glowRadius: 6 + _heartbeat.value * 5),
                const SizedBox(height: 4),
                Text('Select a player to protect tonight',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.mintGreen.withValues(alpha: 0.5))),
              ],
            ),
          ),
        );
      },
    );
  }

  /// ── Detective Active: scanning animation ──
  Widget _detectiveActiveOverlay() {
    return AnimatedBuilder(
      animation: _scanLine,
      builder: (_, __) => IgnorePointer(
        child: Stack(children: [
          // Scanning line effect
          Positioned(
            top: _scanLine.value * MediaQuery.of(context).size.height,
            left: 0, right: 0,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.transparent,
                  AppColors.purpleNeon.withValues(alpha: 0.4),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          // Content
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.transparent,
                  AppColors.purpleNeon.withValues(alpha: 0.03),
                ],
                radius: 1.2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search,
                  color: AppColors.purpleNeon.withValues(alpha: 0.6),
                  size: 36),
                const SizedBox(height: 10),
                NeonText(
                  text: 'INVESTIGATE A SUSPECT',
                  fontSize: 14,
                  color: AppColors.purpleNeon,
                  glowRadius: 10),
                const SizedBox(height: 4),
                Text('Select a player to uncover their identity',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.purpleNeon.withValues(alpha: 0.5))),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  /// ── Detective Result: PRIVATE reveal ──
  Widget _detectiveResultOverlay() {
    final isMafia = widget.detectiveResult ?? false;
    final targetName = widget.players
        .where((p) => p.id == widget.detectiveTargetId)
        .map((p) => p.name)
        .firstOrNull ?? 'Unknown';
    final color = isMafia ? AppColors.crimsonRed : AppColors.mintGreen;
    final label = isMafia ? 'TARGET IS MAFIA' : 'TARGET IS CIVILIAN';
    final icon = isMafia ? Icons.dangerous : Icons.verified_user;

    return AnimatedBuilder(
      animation: _glitch,
      builder: (_, __) {
        final glitchOffset = _glitch.value * 4 * (Random().nextDouble() - 0.5);
        return IgnorePointer(
          child: Container(
            color: Colors.black.withValues(alpha: 0.5),
            child: Center(
              child: Transform.translate(
                offset: Offset(glitchOffset, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: color.withValues(alpha: 0.08),
                        border: Border.all(color: color.withValues(alpha: 0.3)),
                        boxShadow: [
                          BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 24),
                        ],
                      ),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text('INVESTIGATION RESULT',
                          style: TextStyle(
                            color: AppColors.white30, fontSize: 9,
                            fontWeight: FontWeight.w700, letterSpacing: 2)),
                        const SizedBox(height: 10),
                        Icon(icon, color: color, size: 40),
                        const SizedBox(height: 8),
                        Text(targetName,
                          style: TextStyle(
                            color: AppColors.white70, fontSize: 16,
                            fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        NeonText(
                          text: label,
                          fontSize: 18,
                          color: color,
                          glowRadius: 14),
                        const SizedBox(height: 8),
                        Text('This information is private',
                          style: TextStyle(
                            color: AppColors.white30, fontSize: 9,
                            fontWeight: FontWeight.w500, fontStyle: FontStyle.italic)),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// ── Waiting overlay (not your turn) ──
  Widget _waitingOverlay(NightSubPhase subPhase) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (_, __) => Container(
          color: Colors.black.withValues(alpha: 0.45),
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.nightlight_round,
                color: AppColors.purpleGlow.withValues(alpha: 0.4 + _pulse.value * 0.2),
                size: 36),
              const SizedBox(height: 10),
              NeonText(
                text: 'NIGHT FALLS',
                fontSize: 16,
                color: AppColors.purpleGlow.withValues(alpha: 0.5)),
              const SizedBox(height: 6),
              Text('${subPhase.displayName} is acting...',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.white30)),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.mic_off,
                  color: AppColors.crimsonRed.withValues(alpha: 0.4), size: 12),
                const SizedBox(width: 4),
                Text('Microphone muted',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.crimsonRed.withValues(alpha: 0.4))),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  /// ── Civilian overlay ──
  Widget _civilianOverlay() {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (_, __) => Container(
          color: Colors.black.withValues(alpha: 0.5),
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.nightlight_round,
                color: AppColors.purpleGlow.withValues(alpha: 0.4 + _pulse.value * 0.15),
                size: 40),
              const SizedBox(height: 10),
              NeonText(
                text: 'NIGHT FALLS',
                fontSize: 18,
                color: AppColors.purpleGlow.withValues(alpha: 0.5)),
              const SizedBox(height: 4),
              Text('Close your eyes... the night hides secrets',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.white30)),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.mic_off,
                  color: AppColors.crimsonRed.withValues(alpha: 0.4), size: 12),
                const SizedBox(width: 4),
                Text('Microphone muted',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.crimsonRed.withValues(alpha: 0.4))),
              ]),
            ]),
          ),
        ),
      ),
    );
  }
}
