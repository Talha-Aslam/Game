import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state_model.dart';
import '../models/player_model.dart';
import '../services/websocket_service.dart';
import '../services/audio/audio_service.dart';
import '../services/voice_service.dart';
import 'matchmaking_provider.dart';

/// Voice service provider
final voiceServiceProvider = Provider<VoiceService>((ref) {
  final service = VoiceService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Game state notifier using Riverpod 3.x Notifier
class GameNotifier extends Notifier<GameStateModel> {
  StreamSubscription? _sub;
  StreamSubscription? _statusSub;
  StreamSubscription? _speakerSub;

  /// Quick accessor to the singleton AudioService
  AudioService get _audio => AudioService.instance;

  @override
  GameStateModel build() {
    final ws = ref.watch(webSocketServiceProvider);
    _listen(ws);
    _listenToVoice();

    ref.onDispose(() {
      _sub?.cancel();
      _statusSub?.cancel();
      _speakerSub?.cancel();
    });
    return const GameStateModel(gameId: '');
  }

  void _listenToVoice() {
    _speakerSub?.cancel();
    final voice = ref.read(voiceServiceProvider);
    
    _speakerSub = voice.activeSpeakers.listen((uids) {
      final uidMap = voice.uidMap;
      final speakingAccounts = uids.map((id) => uidMap[id]).whereType<String>().toSet();
      
      // Update local state for who is speaking
      final updatedPlayers = state.players.map((p) {
        final isSpeaking = speakingAccounts.contains(p.id);
        
        // If someone just started speaking, or just stopped
        if (isSpeaking && p.voiceState != VoiceState.speaking) {
          return p.copyWith(voiceState: VoiceState.speaking);
        } else if (!isSpeaking && p.voiceState == VoiceState.speaking) {
          // Revert to idle (or muted if they were already muted, but Agora volume info 
          // usually doesn't include muted users anyway)
          return p.copyWith(voiceState: VoiceState.idle);
        }
        return p;
      }).toList();
      
      state = state.copyWith(players: updatedPlayers);
    });
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
        case WsEvent.lobbyCountdown:
          _handleLobbyCountdown(msg.data);
          break;
        case WsEvent.showBegins:
          _handleShowBegins();
          break;
        case WsEvent.nightSubPhase:
          _handleNightSubPhase(msg.data);
          break;
        case WsEvent.investigationResult:
          _handleInvestigationResult(msg.data);
          break;
        case WsEvent.dawnAnnounce:
          _handleDawnAnnounce(msg.data);
          break;
        case WsEvent.mafiaChannel:
          _handleMafiaChannel(msg.data);
          break;
        case 'join_main_voice':
        case 'join_mafia_voice':
        case 'join_graveyard_voice':
          _handleVoiceSwitch(msg);
          break;
      }
    });

    _statusSub?.cancel();
    _statusSub = ws.connectionStatusStream.listen((connected) {
      if (connected && state.gameId.isNotEmpty) {
        // Re-request state if we reconnect during a game
        ws.send('sync_state');
      }
    });
  }

  void _handleVoiceSwitch(WsMessage msg) async {
    final channel = msg.data['channel'] as String?;
    final token = msg.data['token'] as String?;
    final userId = msg.data['userId'] as String? ?? state.localPlayerId;
    
    if (channel != null && token != null && userId != null) {
      final voice = ref.read(voiceServiceProvider);
      await voice.switchChannel(token, channel, userId);
      
      // Keep state updated on which room we're actually in
      if (msg.event == 'join_mafia_voice') {
        state = state.copyWith(mafiaChannelOpen: true);
      } else {
        state = state.copyWith(mafiaChannelOpen: false);
      }
      _evaluateHardwareMute();
    }
  }

  void _evaluateHardwareMute() {
    final phase = state.phase;
    final lp = state.localPlayer;
    if (lp == null) return;

    final isForcedMuted = (phase == GamePhase.night &&
        !(lp.isMafia && state.mafiaChannelOpen));
        
    final isManuallyMuted = lp.voiceState == VoiceState.muted;
    
    final shouldBeMuted = isForcedMuted || isManuallyMuted || lp.status == PlayerStatus.eliminated;
    
    ref.read(voiceServiceProvider).muteMicrophone(shouldBeMuted);
  }

  // ══════════════════════════════════════════════════════════════════════
  // LOBBY PHASE
  // ══════════════════════════════════════════════════════════════════════

  void _handleLobbyUpdate(Map<String, dynamic> data) {
    if (data.containsKey('readyPlayers')) {
      final ready = Set<String>.from(data['readyPlayers'] as List? ?? []);
      state = state.copyWith(readyPlayers: ready);
    }
    if (data.containsKey('players')) {
      final players = (data['players'] as List)
          .map((p) => PlayerModel.fromJson(p as Map<String, dynamic>))
          .toList();
          
      GamePhase? newPhase;
      if (data.containsKey('phase')) {
         try {
           final phaseStr = data['phase'] as String;
           // Map backend states to frontend GamePhase if needed, simple match here
           newPhase = GamePhase.values.firstWhere(
             (e) => e.name == phaseStr,
             orElse: () => GamePhase.lobby,
           );
         } catch (_) {}
      }
      
      state = state.copyWith(
        players: players,
        phase: newPhase ?? state.phase, // keep current phase if not provided
      );
    }
    if (data.containsKey('localPlayerId')) {
      state = state.copyWith(
        localPlayerId: data['localPlayerId'] as String?,
      );
    }
  }

  void _handleLobbyCountdown(Map<String, dynamic> data) {
    final remaining = data['remaining'] as int? ?? 0;
    final ticking = data['tickingActive'] as bool? ?? false;

    state = state.copyWith(
      lobbyCountdown: remaining,
      lobbyTickingActive: ticking,
      timeRemaining: remaining,
    );

    // ── AUDIO: Trigger "Trust no one..." when countdown starts at 10
    if (remaining == 10) {
      _audio.playLobbyIntro();
    }
  }

  void _handleShowBegins() {
    state = state.copyWith(showBeginsCinematic: true);

    // ── AUDIO: play "The show begins." cinematic VO
    _audio.playGameStart();

    // Reset cinematic flag after animation
    Future.delayed(const Duration(seconds: 2), () {
      state = state.copyWith(showBeginsCinematic: false);
    });
  }

  // ══════════════════════════════════════════════════════════════════════
  // ROLE ASSIGNMENT
  // ══════════════════════════════════════════════════════════════════════

  void _handleRoleAssigned(Map<String, dynamic> data) {
    final players = (data['players'] as List)
        .map((p) => PlayerModel.fromJson(p as Map<String, dynamic>))
        .toList();
    state = state.copyWith(
      phase: GamePhase.roleAssignment,
      players: players,
      localPlayerId: data['localPlayerId'] as String?,
      timeRemaining: 10,
      lobbyTickingActive: false,
      showBeginsCinematic: false,
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // PHASE CHANGES
  // ══════════════════════════════════════════════════════════════════════

  void _handlePhaseChange(Map<String, dynamic> data) {
    final phaseName = data['phase'] as String?;
    if (phaseName != null) {
      final phase = GamePhase.values.byName(phaseName);
      state = state.copyWith(
        phase: phase,
        timeRemaining: data['duration'] as int? ?? state.timeRemaining,
        morningMessage: data['morningMessage'] as String?,
      );

      // ── AUDIO: Phase-specific narration triggers
      switch (phase) {
        case GamePhase.night:
          // Narrator: "The shadows..."
          _audio.playNightStart();
          break;
        case GamePhase.morningReveal:
          // Narrator plays morning results (handled in _handleDawnAnnounce)
          break;
        case GamePhase.day:
          break;
        case GamePhase.voting:
          // Narrator: "Cast your votes"
          _audio.playVotingStart();
          break;
        default:
          break;
      }
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // NIGHT SUB-PHASES (Sequential: Mafia → Doctor → Detective)
  // ══════════════════════════════════════════════════════════════════════

  void _handleNightSubPhase(Map<String, dynamic> data) {
    final subPhaseName = data['subPhase'] as String?;
    final duration = data['duration'] as int?;
    if (subPhaseName != null) {
      final subPhase = NightSubPhase.values.byName(subPhaseName);
      state = state.copyWith(
        nightSubPhase: subPhase,
        timeRemaining: duration ?? state.timeRemaining,
      );

      // ── AUDIO: Sub-phase narration
      switch (subPhase) {
        case NightSubPhase.mafiaActing:
          // Narrator: "Mafia, choose your prey..."
          _audio.playMafiaTurn();
          break;
        case NightSubPhase.doctorActing:
          // Narrator: "Doctor, listen... save a life"
          _audio.playDoctorTurn();
          break;
        case NightSubPhase.detectiveActing:
          // Narrator: "Detective, the streets are lying..."
          _audio.playDetectiveTurn();
          break;
      }
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // INVESTIGATION RESULT (Private — detective only)
  // ══════════════════════════════════════════════════════════════════════

  void _handleInvestigationResult(Map<String, dynamic> data) {
    final targetId = data['targetId'] as String?;
    final isMafia = data['isMafia'] as bool? ?? false;

    // PRIVATE — only update state if local player is detective
    final lp = state.localPlayer;
    if (lp?.role == GameRole.detective) {
      state = state.copyWith(
        detectiveTargetId: targetId,
        detectiveResult: isMafia,
        detectiveResultRevealed: true,
      );

      // ── AUDIO: "Investigation complete."
      _audio.playDetectiveLocked();
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // DAWN ANNOUNCE
  // ══════════════════════════════════════════════════════════════════════

  void _handleDawnAnnounce(Map<String, dynamic> data) {
    final message = data['message'] as String?;
    final saved = data['saved'] as bool? ?? false;

    state = state.copyWith(
      dawnMessage: message,
      morningMessage: message,
      phase: GamePhase.morningReveal,
    );

    // ── AUDIO: "Everyone open your eyes" → then death/save result
    _audio.playMorningResults(someoneDied: !saved);
  }

  void _handleMafiaChannel(Map<String, dynamic> data) {
    final open = data['open'] as bool? ?? false;
    state = state.copyWith(mafiaChannelOpen: open);
  }

  void _handleTimerTick(Map<String, dynamic> data) {
    state = state.copyWith(
      timeRemaining: data['remaining'] as int? ?? state.timeRemaining,
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // ELIMINATION
  // ══════════════════════════════════════════════════════════════════════

  void _handleElimination(Map<String, dynamic> data) {
    final playerId = data['playerId'] as String;
    final updatedPlayers = state.players.map((p) {
      if (p.id == playerId) {
        return p.copyWith(
          status: PlayerStatus.eliminated,
          voiceState: VoiceState.muted,
          isEliminating: true,
        );
      }
      return p;
    }).toList();
    state = state.copyWith(
      players: updatedPlayers,
      eliminatedPlayerId: playerId,
      phase: GamePhase.elimination,
    );

    // ── AUDIO: "A citizen has been eliminated" VO
    _audio.playVotingResult(resultType: 'exile');

    // Reset isEliminating after animation
    Future.delayed(const Duration(seconds: 2), () {
      final reset = state.players.map((p) {
        if (p.id == playerId) return p.copyWith(isEliminating: false);
        return p;
      }).toList();
      state = state.copyWith(players: reset);
    });
  }

  void _handleVotesRevealed(Map<String, dynamic> data) {
    final votes = Map<String, String>.from(
      (data['votes'] as Map?) ?? {},
    );
    state = state.copyWith(votes: votes);
  }

  // ══════════════════════════════════════════════════════════════════════
  // RUNOFF
  // ══════════════════════════════════════════════════════════════════════

  void _handleRunoff(Map<String, dynamic> data) {
    final tied = List<String>.from(data['tiedPlayers'] as List? ?? []);
    state = state.copyWith(tiedPlayerIds: tied);

    // ── AUDIO: "No one is eliminated" — tied vote VO
    _audio.playVotingResult(resultType: 'tie');
  }

  // ══════════════════════════════════════════════════════════════════════
  // GAME RESULT
  // ══════════════════════════════════════════════════════════════════════

  void _handleResult(Map<String, dynamic> data) {
    final winner = WinningSide.values.byName(data['winner'] as String);
    final mafiaWon = winner == WinningSide.mafia;

    // ── AUDIO: Stop everything, play game over narration
    _audio.stopAll();
    _audio.playGameOver(mafiaWon: mafiaWon);

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

  // ══════════════════════════════════════════════════════════════════════
  // PLAYER ACTIONS
  // ══════════════════════════════════════════════════════════════════════

  /// Toggle ready in lobby
  void toggleReady() {
    final pid = state.localPlayerId ?? '';
    final ready = Set<String>.from(state.readyPlayers);
    ready.contains(pid) ? ready.remove(pid) : ready.add(pid);
    state = state.copyWith(readyPlayers: ready);
    ref.read(webSocketServiceProvider).send('toggle_ready', {'playerId': pid});
  }

  /// Leave lobby
  void leaveLobby() {
    _audio.stopAll();
    ref.read(webSocketServiceProvider).send('leave_lobby');
    ref.read(webSocketServiceProvider).disconnect();
    ref.read(voiceServiceProvider).leaveChannel();
    resetGame();
  }

  /// Submit vote
  void submitVote(String targetId) {
    state = state.copyWith(
      votes: {...state.votes, state.localPlayerId ?? '': targetId},
    );
    ref.read(webSocketServiceProvider).send('submit_vote', {'targetId': targetId});
  }

  /// Clear vote (change mind before timer)
  void clearVote() {
    final votes = Map<String, String>.from(state.votes);
    votes.remove(state.localPlayerId ?? '');
    state = state.copyWith(votes: votes);
    ref.read(webSocketServiceProvider).send('clear_vote');
  }

  /// Mafia action — select target
  void submitMafiaAction(String targetId) {
    state = state.copyWith(mafiaTargetId: targetId);
    ref.read(webSocketServiceProvider).send('mafia_action', {'targetId': targetId});

    // ── AUDIO: "Prey locked."
    _audio.playMafiaLocked();
  }

  /// Doctor action — select target
  void submitDoctorAction(String targetId) {
    state = state.copyWith(doctorTargetId: targetId);
    ref.read(webSocketServiceProvider).send('doctor_action', {'targetId': targetId});

    // ── AUDIO: "A life locked."
    _audio.playDoctorLocked();
  }

  /// Detective action — select target
  void submitDetectiveAction(String targetId) {
    state = state.copyWith(detectiveTargetId: targetId);
    ref.read(webSocketServiceProvider).send('detective_action', {'targetId': targetId});
    // Note: audio for detective confirm is played in _handleInvestigationResult
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

  /// Connect to the actual game websocket
  void connectToGame(String roomId) {
    final ws = ref.read(webSocketServiceProvider);
    ws.connectGame(roomId).then((_) {
      state = state.copyWith(phase: GamePhase.lobby, gameId: roomId);
    });
  }

  /// Toggle mic mute (local state only)
  void toggleMute() {
    final lp = state.localPlayer;
    if (lp == null) return;
    
    final isCurrentlyMuted = lp.voiceState == VoiceState.muted;
    final newVoice = isCurrentlyMuted ? VoiceState.idle : VoiceState.muted;
    
    // 1. Update UI state
    final updated = state.players.map((p) {
      if (p.id == lp.id) return p.copyWith(voiceState: newVoice);
      return p;
    }).toList();
    state = state.copyWith(players: updated);

    // 2. Actually mute/unmute the hardware via Agora
    ref.read(voiceServiceProvider).muteMicrophone(!isCurrentlyMuted);
  }

  /// Send emoji (broadcast to other players)
  void sendEmoji(String emoji) {
    ref.read(webSocketServiceProvider).send('send_emoji', {
      'playerId': state.localPlayerId, 'emoji': emoji,
    });
  }

  /// Send commendation to a player
  void sendCommendation(String targetPlayerId) {
    ref.read(webSocketServiceProvider).send('send_commendation', {
      'targetPlayerId': targetPlayerId,
    });
    // Optimistic: increment target's commendations locally
    final updated = state.players.map((p) {
      if (p.id == targetPlayerId) {
        return p.copyWith(commendations: p.commendations + 1);
      }
      return p;
    }).toList();
    state = state.copyWith(players: updated);
  }

  /// Add friend request
  void addFriend(String targetPlayerId) {
    ref.read(webSocketServiceProvider).send('add_friend', {
      'targetPlayerId': targetPlayerId,
    });
  }

  /// Invite friend (stub — would open friend list)
  void inviteFriend() {
    // In production: opens friend picker dialog
  }

  /// Invite family members (stub)
  void inviteFamily() {
    // In production: sends invite to family members
  }

  /// Reset game
  void resetGame() {
    _audio.stopAll();
    ref.read(webSocketServiceProvider).disconnect();
    ref.read(voiceServiceProvider).leaveChannel();
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

final nightSubPhaseProvider = Provider<NightSubPhase?>((ref) {
  return ref.watch(gameProvider).nightSubPhase;
});

final deadPlayersProvider = Provider<List<PlayerModel>>((ref) {
  return ref.watch(gameProvider).deadPlayers;
});
