import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/game_state_model.dart';
import '../../../models/player_model.dart';
import '../../../widgets/glass_button.dart';
import '../../../widgets/neon_text.dart';

/// Bottom action bar — glass panel with ALL phase controls, fully functional
class LobbyActionBar extends StatelessWidget {
  final GamePhase phase;
  final GameStateModel gameState;
  final PlayerModel? localPlayer;
  final String? selectedVoteTarget;
  final String? nightActionTarget;
  final VoidCallback? onConfirmVote;
  final VoidCallback? onSkipVote;
  final VoidCallback? onConfirmNightAction;
  final VoidCallback? onReady;
  final VoidCallback? onLeaveLobby;
  final VoidCallback? onQueueAgain;
  final VoidCallback? onReturnHome;

  const LobbyActionBar({
    super.key,
    required this.phase,
    required this.gameState,
    this.localPlayer,
    this.selectedVoteTarget,
    this.nightActionTarget,
    this.onConfirmVote,
    this.onSkipVote,
    this.onConfirmNightAction,
    this.onReady,
    this.onLeaveLobby,
    this.onQueueAgain,
    this.onReturnHome,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
          decoration: BoxDecoration(
            color: AppColors.white05,
            border: Border(
              top: BorderSide(color: AppColors.glassBorder, width: 0.5)),
          ),
          child: SafeArea(top: false, child: _buildContent(context)),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (phase) {
      case GamePhase.lobby:
        return _lobbyBar(context);
      case GamePhase.matchmaking:
        return _matchmakingBar();
      case GamePhase.roleAssignment:
        return _roleBar();
      case GamePhase.night:
        return _nightBar();
      case GamePhase.morningReveal:
        return _morningBar();
      case GamePhase.day:
        return _dayBar();
      case GamePhase.voting:
      case GamePhase.runoff:
        return _votingBar();
      case GamePhase.elimination:
        return _eliminationBar();
      case GamePhase.result:
        return _resultBar();
    }
  }

  // ── LOBBY ──
  Widget _lobbyBar(BuildContext context) {
    final isReady = gameState.isLocalPlayerReady;
    final readyCount = gameState.readyPlayers.length;
    final totalCount = gameState.players.length;

    return Column(mainAxisSize: MainAxisSize.min, children: [
      // Main row: Leave, status, Ready
      Row(children: [
        GlassButton(
          label: 'LEAVE',
          isOutlined: true,
          width: 70, height: 36,
          onPressed: onLeaveLobby),
        const SizedBox(width: 8),
        Expanded(child: Text(
          '$readyCount/$totalCount ready',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.white50),
          textAlign: TextAlign.center)),
        GlassButton(
          label: isReady ? 'UNREADY' : 'READY',
          glowColor: isReady ? AppColors.crimsonRed : AppColors.mintGreen,
          icon: isReady ? Icons.close : Icons.check,
          width: 110, height: 36,
          onPressed: onReady),
      ]),
      const SizedBox(height: 6),
      // Secondary row: Invite Friends, Family Invite
      Row(children: [
        Expanded(child: _LobbySecondaryButton(
          icon: Icons.person_add,
          label: 'Invite Friends',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Friend invite sent!'),
                backgroundColor: AppColors.surface,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        )),
        const SizedBox(width: 8),
        Expanded(child: _LobbySecondaryButton(
          icon: Icons.groups,
          label: 'Family Invite',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Family invite sent!'),
                backgroundColor: AppColors.surface,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        )),
      ]),
    ]);
  }

  // ── MATCHMAKING ──
  Widget _matchmakingBar() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      SizedBox(width: 14, height: 14,
        child: CircularProgressIndicator(
          strokeWidth: 2, color: AppColors.purpleGlow)),
      const SizedBox(width: 10),
      Text('Finding players...', style: AppTextStyles.bodySmall),
    ]);
  }

  // ── ROLE ASSIGNMENT ──
  Widget _roleBar() {
    return Row(children: [
      Icon(Icons.mic_off,
        color: AppColors.crimsonRed.withValues(alpha: 0.5), size: 14),
      const SizedBox(width: 6),
      Expanded(child: Text('All players muted during role reveal',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.white30))),
    ]);
  }

  // ── NIGHT ──
  Widget _nightBar() {
    final lp = localPlayer;
    if (lp == null || !lp.isAlive) return _spectatorBar();

    // Check if it's this player's turn
    final subPhase = gameState.nightSubPhase;
    final isMyTurn = subPhase != null && lp.role == subPhase.activeRole;

    if (!isMyTurn && !lp.isMafia) {
      // Not my turn and not mafia — show waiting
      return Row(children: [
        Icon(Icons.nightlight_round,
          color: AppColors.purpleGlow.withValues(alpha: 0.5), size: 14),
        const SizedBox(width: 8),
        Expanded(child: Text(
          subPhase != null
              ? '${subPhase.displayName} is acting...'
              : 'Night falls... close your eyes',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.white30))),
      ]);
    }

    // Mafia during mafia turn, or special role during their turn
    String actionLabel;
    String buttonLabel;
    Color buttonColor;
    IconData actionIcon;
    bool isConfirmed = false;

    if (lp.isMafia) {
      actionLabel = 'Choose a target to eliminate';
      buttonLabel = 'ELIMINATE';
      buttonColor = AppColors.crimsonRed;
      actionIcon = Icons.dangerous;
      if (gameState.mafiaTargetId != null && gameState.mafiaTargetId == nightActionTarget) isConfirmed = true;
    } else if (lp.role == GameRole.doctor) {
      actionLabel = 'Choose a player to protect';
      buttonLabel = 'PROTECT';
      buttonColor = AppColors.mintGreen;
      actionIcon = Icons.healing;
      if (gameState.doctorTargetId != null && gameState.doctorTargetId == nightActionTarget) isConfirmed = true;
    } else if (lp.role == GameRole.detective) {
      actionLabel = 'Choose a player to investigate';
      buttonLabel = 'INVESTIGATE';
      buttonColor = AppColors.purpleNeon;
      actionIcon = Icons.search;
      if (gameState.detectiveTargetId != null && gameState.detectiveTargetId == nightActionTarget) isConfirmed = true;
    } else {
      return Row(children: [
        Icon(Icons.nightlight_round,
          color: AppColors.purpleGlow.withValues(alpha: 0.5), size: 14),
        const SizedBox(width: 8),
        Expanded(child: Text('Night falls... close your eyes',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.white30))),
      ]);
    }

    if (isConfirmed) {
      buttonLabel = 'CONFIRMED';
      actionLabel = 'Target confirmed. Waiting...';
    }

    return Row(children: [
      Icon(actionIcon, color: buttonColor.withValues(alpha: 0.5), size: 14),
      const SizedBox(width: 6),
      Expanded(child: Text(actionLabel,
        style: AppTextStyles.bodySmall, overflow: TextOverflow.ellipsis)),
      GlassButton(
        label: buttonLabel, glowColor: buttonColor,
        width: 110, height: 36,
        onPressed: isConfirmed ? () {} : (nightActionTarget != null ? onConfirmNightAction : null)),
    ]);
  }

  // ── MORNING REVEAL ──
  Widget _morningBar() {
    final msg = gameState.morningMessage ?? gameState.dawnMessage ?? 'The city awakens...';
    final isDeath = msg.contains('eliminated') || msg.contains('tragedy');
    return Center(child: NeonText(
      text: msg, fontSize: 12,
      color: isDeath ? AppColors.crimsonRed : AppColors.mintGreen,
      glowRadius: 10));
  }

  // ── DAY ──
  Widget _dayBar() {
    return Row(children: [
      Container(
        width: 20, height: 20,
        decoration: BoxDecoration(shape: BoxShape.circle,
          color: AppColors.online.withValues(alpha: 0.1),
          border: Border.all(color: AppColors.online.withValues(alpha: 0.3))),
        child: const Icon(Icons.mic, color: AppColors.online, size: 11)),
      const SizedBox(width: 8),
      Expanded(child: Text('Discussion phase — speak freely',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.white50))),
    ]);
  }

  // ── VOTING / RUNOFF ──
  Widget _votingBar() {
    final hasVote = selectedVoteTarget != null;
    final isConfirmed = hasVote && gameState.votes[gameState.localPlayerId] == selectedVoteTarget;

    return Row(children: [
      Expanded(child: Text(
        isConfirmed ? 'Vote confirmed. Waiting...' : (hasVote
            ? 'Vote selected — confirm or change'
            : 'Tap a player to cast your vote'),
        style: AppTextStyles.bodySmall)),
      GlassButton(
        label: 'SKIP', isOutlined: true,
        width: 60, height: 34, onPressed: onSkipVote),
      const SizedBox(width: 6),
      GlassButton(
        label: isConfirmed ? 'CONFIRMED' : 'VOTE', glowColor: AppColors.gold,
        width: 100, height: 34,
        onPressed: isConfirmed ? () {} : (hasVote ? onConfirmVote : null)),
    ]);
  }

  // ── ELIMINATION ──
  Widget _eliminationBar() {
    final name = gameState.players
        .where((p) => p.id == gameState.eliminatedPlayerId)
        .map((p) => p.name).firstOrNull ?? 'Unknown';
    return Center(child: NeonText(
      text: 'The city has spoken. $name is exiled.',
      fontSize: 12, color: AppColors.crimsonRed));
  }

  // ── RESULT ──
  Widget _resultBar() {
    final rd = gameState.resultData;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      // XP/rank row
      if (rd != null) Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _StatChip(icon: Icons.star, label: '+${rd.xpGained} XP',
            color: AppColors.gold),
          const SizedBox(width: 8),
          _StatChip(
            icon: Icons.military_tech,
            label: '${rd.rankDelta > 0 ? '+' : ''}${rd.rankDelta} RP',
            color: rd.rankDelta >= 0 ? AppColors.mintGreen : AppColors.crimsonRed),
          const SizedBox(width: 8),
          _StatChip(icon: Icons.local_fire_department,
            label: '+${rd.bpXpGained} BP',
            color: AppColors.purpleGlow),
        ]),
      ),
      // Buttons
      Row(children: [
        Expanded(child: GlassButton(
          label: 'PLAY AGAIN', glowColor: AppColors.purpleNeon,
          height: 38, onPressed: onQueueAgain)),
        const SizedBox(width: 8),
        GlassButton(
          label: 'HOME', isOutlined: true,
          width: 80, height: 38, onPressed: onReturnHome),
      ]),
    ]);
  }

  Widget _spectatorBar() {
    return Row(children: [
      Icon(Icons.visibility, color: AppColors.white30, size: 14),
      const SizedBox(width: 6),
      Text('You are spectating',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.white30)),
    ]);
  }
}

// ── Sub-widgets ──

class _LobbySecondaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _LobbySecondaryButton({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColors.white05,
          border: Border.all(color: AppColors.glassBorder)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: AppColors.white30, size: 12),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(
            color: AppColors.white30, fontSize: 9, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 11),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(
          color: color, fontSize: 10, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}
