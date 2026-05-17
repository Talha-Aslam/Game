import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state_model.dart';
import '../models/player_model.dart';
import '../services/websocket_service.dart';

/// WebSocket service provider
final wsServiceProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Game state notifier using Riverpod 3.x Notifier
class GameNotifier extends Notifier<GameStateModel> {
  StreamSubscription? _sub;

  @override
  GameStateModel build() {
    final ws = ref.watch(wsServiceProvider);
    _listen(ws);
    ref.onDispose(() => _sub?.cancel());
    return const GameStateModel(gameId: '');
  }

  void _listen(WebSocketService ws) {
    _sub?.cancel();
    _sub = ws.eventStream.listen((msg) {
      switch (msg.event) {
        case WsEvent.roleAssigned:
          _handleRoleAssigned(msg.data);
          break;
        case WsEvent.phaseChange:
          _handlePhaseChange(msg.data);
          break;
        case WsEvent.timerTick:
          _handleTimerTick(msg.data);
          break;
        case WsEvent.playerEliminated:
          _handleElimination(msg.data);
          break;
        case WsEvent.votesRevealed:
          _handleVotesRevealed(msg.data);
          break;
        case WsEvent.runoffTriggered:
          _handleRunoff(msg.data);
          break;
        case WsEvent.gameResult:
          _handleResult(msg.data);
          break;
        case WsEvent.voiceStateChange:
          _syncVoiceStates(msg.data);
          break;
        case WsEvent.lobbyUpdate:
          _handleLobbyUpdate(msg.data);
          break;
      }
    });
  }

  void _handleLobbyUpdate(Map<String, dynamic> data) {
    if (data.containsKey('readyPlayers')) {
      final ready = Set<String>.from(data['readyPlayers'] as List? ?? []);
      state = state.copyWith(readyPlayers: ready);
    }
    if (data.containsKey('players')) {
      final players = (data['players'] as List)
          .map((p) => PlayerModel.fromJson(p as Map<String, dynamic>))
          .toList();
      state = state.copyWith(players: players);
    }
  }

  void _handleRoleAssigned(Map<String, dynamic> data) {
    final players = (data['players'] as List)
        .map((p) => PlayerModel.fromJson(p as Map<String, dynamic>))
        .toList();
    state = state.copyWith(
      phase: GamePhase.roleAssignment,
      players: players,
      localPlayerId: data['localPlayerId'] as String?,
      timeRemaining: 10,
    );
  }

  void _handlePhaseChange(Map<String, dynamic> data) {
    final phaseName = data['phase'] as String?;
    if (phaseName != null) {
      final phase = GamePhase.values.byName(phaseName);
      state = state.copyWith(
        phase: phase,
        timeRemaining: data['duration'] as int? ?? state.timeRemaining,
        morningMessage: data['morningMessage'] as String?,
      );
    }
  }

  void _handleTimerTick(Map<String, dynamic> data) {
    state = state.copyWith(
      timeRemaining: data['remaining'] as int? ?? state.timeRemaining,
    );
  }

  void _handleElimination(Map<String, dynamic> data) {
    final playerId = data['playerId'] as String;
    final updatedPlayers = state.players.map((p) {
      if (p.id == playerId) {
        return p.copyWith(status: PlayerStatus.eliminated, voiceState: VoiceState.muted);
      }
      return p;
    }).toList();
    state = state.copyWith(
      players: updatedPlayers,
      eliminatedPlayerId: playerId,
      phase: GamePhase.elimination,
    );
  }

  void _handleVotesRevealed(Map<String, dynamic> data) {
    final votes = Map<String, String>.from(
      (data['votes'] as Map?) ?? {},
    );
    state = state.copyWith(votes: votes);
  }

  void _handleRunoff(Map<String, dynamic> data) {
    final tied = List<String>.from(data['tiedPlayers'] as List? ?? []);
    state = state.copyWith(tiedPlayerIds: tied);
  }

  void _handleResult(Map<String, dynamic> data) {
    final winner = WinningSide.values.byName(data['winner'] as String);
    state = state.copyWith(
      phase: GamePhase.result,
      winner: winner,
      resultData: MatchResultData(
        xpGained: data['xpGained'] as int? ?? 150,
        rankDelta: data['rankDelta'] as int? ?? 12,
        bpXpGained: data['bpXpGained'] as int? ?? 80,
        influenceGained: data['influenceGained'] as int? ?? 25,
        popularityGained: data['popularityGained'] as int? ?? 5,
        mvpPlayerId: data['mvpPlayerId'] as String?,
      ),
    );
  }

  void _syncVoiceStates(Map<String, dynamic> data) {
    if (data.containsKey('players')) {
      final voiceMap = Map<String, String>.from(data['players'] as Map? ?? {});
      final updatedPlayers = state.players.map((p) {
        if (voiceMap.containsKey(p.id)) {
          return p.copyWith(voiceState: VoiceState.values.byName(voiceMap[p.id]!));
        }
        return p;
      }).toList();
      state = state.copyWith(players: updatedPlayers);
    } else {
      state = state.copyWith(players: List.from(state.players));
    }
  }

  // ── Player Actions ──

  /// Toggle ready in lobby
  void toggleReady() {
    final pid = state.localPlayerId ?? '';
    final ready = Set<String>.from(state.readyPlayers);
    ready.contains(pid) ? ready.remove(pid) : ready.add(pid);
    state = state.copyWith(readyPlayers: ready);
    ref.read(wsServiceProvider).send('toggle_ready', {'playerId': pid});
  }

  /// Leave lobby
  void leaveLobby() {
    ref.read(wsServiceProvider).send('leave_lobby');
    resetGame();
  }

  /// Submit vote
  void submitVote(String targetId) {
    state = state.copyWith(
      votes: {...state.votes, state.localPlayerId ?? '': targetId},
    );
    ref.read(wsServiceProvider).send('submit_vote', {'targetId': targetId});
  }

  /// Clear vote (change mind before timer)
  void clearVote() {
    final votes = Map<String, String>.from(state.votes);
    votes.remove(state.localPlayerId ?? '');
    state = state.copyWith(votes: votes);
    ref.read(wsServiceProvider).send('clear_vote');
  }

  /// Mafia action
  void submitMafiaAction(String targetId) {
    state = state.copyWith(mafiaTargetId: targetId);
    ref.read(wsServiceProvider).send('mafia_action', {'targetId': targetId});
  }

  /// Doctor action
  void submitDoctorAction(String targetId) {
    state = state.copyWith(doctorTargetId: targetId);
    ref.read(wsServiceProvider).send('doctor_action', {'targetId': targetId});
  }

  /// Detective action
  void submitDetectiveAction(String targetId) {
    state = state.copyWith(detectiveTargetId: targetId);
    ref.read(wsServiceProvider).send('detective_action', {'targetId': targetId});
  }

  /// Change night target before confirmation
  void changeNightTarget(String newTargetId) {
    final lp = state.localPlayer;
    if (lp == null) return;
    if (lp.isMafia) {
      state = state.copyWith(mafiaTargetId: newTargetId);
    } else if (lp.role == GameRole.doctor) {
      state = state.copyWith(doctorTargetId: newTargetId);
    } else if (lp.role == GameRole.detective) {
      state = state.copyWith(detectiveTargetId: newTargetId);
    }
  }

  /// Start matchmaking
  void startMatchmaking() {
    final ws = ref.read(wsServiceProvider);
    ws.connect().then((_) {
      ws.send('join_matchmaking');
      state = state.copyWith(phase: GamePhase.matchmaking);
    });
  }

  /// Toggle mic mute (local state only — audio logic placeholder)
  void toggleMute() {
    final lp = state.localPlayer;
    if (lp == null) return;
    final newVoice = lp.voiceState == VoiceState.muted ? VoiceState.idle : VoiceState.muted;
    final updated = state.players.map((p) {
      if (p.id == lp.id) return p.copyWith(voiceState: newVoice);
      return p;
    }).toList();
    state = state.copyWith(players: updated);
  }

  /// Send emoji (broadcast to other players)
  void sendEmoji(String emoji) {
    ref.read(wsServiceProvider).send('send_emoji', {
      'playerId': state.localPlayerId, 'emoji': emoji,
    });
  }

  /// Reset game
  void resetGame() {
    state = const GameStateModel(gameId: '');
  }
}

/// Game state provider
final gameProvider =
    NotifierProvider<GameNotifier, GameStateModel>(GameNotifier.new);

/// Derived providers
final currentPhaseProvider = Provider<GamePhase>((ref) {
  return ref.watch(gameProvider).phase;
});

final alivePlayersProvider = Provider<List<PlayerModel>>((ref) {
  return ref.watch(gameProvider).alivePlayers;
});

final localPlayerProvider = Provider<PlayerModel?>((ref) {
  return ref.watch(gameProvider).localPlayer;
});

final timeRemainingProvider = Provider<int>((ref) {
  return ref.watch(gameProvider).timeRemaining;
});
