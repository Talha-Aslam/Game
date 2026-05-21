import 'dart:async';
import 'dart:convert';
import 'dart:math';
import '../models/game_state_model.dart';
import '../models/player_model.dart';

/// WebSocket event types
class WsEvent {
  static const String lobbyUpdate = 'lobby_update';
  static const String lobbyCountdown = 'lobby_countdown';
  static const String showBegins = 'show_begins';
  static const String matchFound = 'match_found';
  static const String roleAssigned = 'role_assigned';
  static const String phaseChange = 'phase_change';
  static const String nightSubPhase = 'night_sub_phase';
  static const String timerTick = 'timer_tick';
  static const String voteSubmitted = 'vote_submitted';
  static const String votesRevealed = 'votes_revealed';
  static const String playerEliminated = 'player_eliminated';
  static const String runoffTriggered = 'runoff_triggered';
  static const String gameResult = 'game_result';
  static const String voiceStateChange = 'voice_state_change';
  static const String playerJoined = 'player_joined';
  static const String playerLeft = 'player_left';
  static const String chatMessage = 'chat_message';
  static const String investigationResult = 'investigation_result';
  static const String dawnAnnounce = 'dawn_announce';
  static const String mafiaChannel = 'mafia_channel';
  static const String error = 'error';
}

/// WebSocket message wrapper
class WsMessage {
  final String event;
  final Map<String, dynamic> data;

  WsMessage({required this.event, this.data = const {}});

  factory WsMessage.fromJson(String jsonStr) {
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    return WsMessage(
      event: map['event'] as String,
      data: map['data'] as Map<String, dynamic>? ?? {},
    );
  }

  String toJson() => jsonEncode({'event': event, 'data': data});
}

/// Mock WebSocket service that simulates full game flow
class WebSocketService {
  final _eventController = StreamController<WsMessage>.broadcast();
  Stream<WsMessage> get eventStream => _eventController.stream;

  Timer? _timer;
  Timer? _voiceSimTimer;
  bool _isConnected = false;
  GameStateModel _currentState = const GameStateModel(gameId: '');

  bool get isConnected => _isConnected;

  /// Connect to WebSocket server (mock)
  Future<void> connect() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _isConnected = true;
    _emit(WsEvent.lobbyUpdate, {'status': 'connected'});
  }

  /// Disconnect
  void disconnect() {
    _isConnected = false;
    _timer?.cancel();
    _voiceSimTimer?.cancel();
    _eventController.close();
  }

  /// Send event to server (mock)
  void send(String event, [Map<String, dynamic>? data]) {
    switch (event) {
      case 'join_matchmaking':
        _simulateMatchmaking();
        break;
      case 'submit_vote':
        _handleVote(data ?? {});
        break;
      case 'mafia_action':
        _handleMafiaAction(data ?? {});
        break;
      case 'doctor_action':
        _handleDoctorAction(data ?? {});
        break;
      case 'detective_action':
        _handleDetectiveAction(data ?? {});
        break;
      case 'send_commendation':
        // stub — in production, server handles this
        break;
      case 'add_friend':
        // stub — in production, server handles this
        break;
    }
  }

  void _emit(String event, Map<String, dynamic> data) {
    if (!_eventController.isClosed) {
      _eventController.add(WsMessage(event: event, data: data));
    }
  }

  /// ─── Matchmaking Simulation ───
  void _simulateMatchmaking() {
    int countdown = 3;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      countdown--;
      if (countdown <= 0) {
        t.cancel();
        _startLobbyPhase();
      }
    });
    _emit(WsEvent.matchFound, {'countdown': 3});
  }

  /// ─── Lobby Phase with 10s countdown ───
  void _startLobbyPhase() {
    final rng = Random();
    final names = [
      'ShadowKing', 'NightViper', 'IronFist', 'GhostWalker',
      'RedPhantom', 'DarkOracle', 'SilverBlade', 'CrimsonEye',
    ];

    final roles = <GameRole>[
      GameRole.mafia,
      GameRole.mafia,
      GameRole.doctor,
      GameRole.detective,
      GameRole.civilian,
      GameRole.civilian,
      GameRole.civilian,
      GameRole.civilian,
    ]..shuffle(rng);

    final players = List.generate(8, (i) {
      return PlayerModel(
        id: 'player_$i',
        name: names[i],
        role: roles[i],
        rankTier: rng.nextInt(5),
        familyTag: i % 3 == 0 ? '[COBRA]' : (i % 3 == 1 ? '[VENOM]' : null),
        avatarIndex: i,
      );
    });

    _currentState = GameStateModel(
      gameId: 'game_${DateTime.now().millisecondsSinceEpoch}',
      phase: GamePhase.lobby,
      players: players,
      localPlayerId: 'player_0',
      roundNumber: 1,
      timeRemaining: 10,
      lobbyCountdown: 10,
    );

    _emit(WsEvent.lobbyUpdate, {
      'players': players.map((p) => p.toJson()).toList(),
      'localPlayerId': 'player_0',
    });

    // Lobby open-mic countdown: 10 → 0
    int lobbyTime = 10;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      lobbyTime--;

      _emit(WsEvent.lobbyCountdown, {
        'remaining': lobbyTime,
        'tickingActive': lobbyTime <= 5 && lobbyTime > 0,
      });

      if (lobbyTime <= 0) {
        t.cancel();
        // "The Show Begins." cinematic
        _emit(WsEvent.showBegins, {});
        // After 2s cinematic, transition to role assignment
        Future.delayed(const Duration(seconds: 2), () {
          _startRoleAssignment();
        });
      }
    });

    // Start voice simulation during lobby
    _startVoiceSimulation();
  }

  void _startRoleAssignment() {
    final players = _currentState.players;

    _currentState = _currentState.copyWith(
      phase: GamePhase.roleAssignment,
      timeRemaining: 10,
    );

    _emit(WsEvent.roleAssigned, {
      'role': players[0].role!.name,
      'players': players.map((p) => p.toJson()).toList(),
      'localPlayerId': 'player_0',
    });

    // Countdown the 10-second role reveal timer
    int roleTimer = 10;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      roleTimer--;
      _emit(WsEvent.timerTick, {'remaining': roleTimer});
      if (roleTimer <= 0) {
        t.cancel();
        _startNightPhase();
      }
    });
  }

  /// ─── Night Phase — Sequential Role Turns ───
  void _startNightPhase() {
    _currentState = _currentState.copyWith(
      phase: GamePhase.night,
      votes: {},
      mafiaTargetId: null,
      doctorTargetId: null,
      detectiveTargetId: null,
      detectiveResult: null,
    );

    _emit(WsEvent.phaseChange, {
      'phase': 'night',
      'duration': 40, // total night = 20 + 10 + 10
    });

    // Sequential: Mafia (20s) → Doctor (10s) → Detective (10s)
    _startNightSubPhase(NightSubPhase.mafiaActing, 20);
  }

  void _startNightSubPhase(NightSubPhase subPhase, int duration) {
    _currentState = _currentState.copyWith(
      nightSubPhase: subPhase,
      timeRemaining: duration,
    );

    // Open mafia channel during mafia turn
    if (subPhase == NightSubPhase.mafiaActing) {
      _emit(WsEvent.mafiaChannel, {'open': true});
    } else {
      _emit(WsEvent.mafiaChannel, {'open': false});
    }

    _emit(WsEvent.nightSubPhase, {
      'subPhase': subPhase.name,
      'duration': duration,
      'activeRole': subPhase.activeRole.name,
    });

    _timer?.cancel();
    int remaining = duration;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      remaining--;
      _currentState = _currentState.copyWith(timeRemaining: remaining);
      _emit(WsEvent.timerTick, {'remaining': remaining});

      if (remaining <= 0) {
        t.cancel();
        _onNightSubPhaseEnd(subPhase);
      }
    });
  }

  void _onNightSubPhaseEnd(NightSubPhase subPhase) {
    switch (subPhase) {
      case NightSubPhase.mafiaActing:
        // If mafia didn't pick, auto-pick
        if (_currentState.mafiaTargetId == null) {
          final rng = Random();
          final civilians = _currentState.alivePlayers
              .where((p) => !p.isMafia).toList();
          if (civilians.isNotEmpty) {
            _currentState = _currentState.copyWith(
              mafiaTargetId: civilians[rng.nextInt(civilians.length)].id,
            );
          }
        }
        _startNightSubPhase(NightSubPhase.doctorActing, 10);
        break;
      case NightSubPhase.doctorActing:
        // If doctor didn't pick, no protection
        _startNightSubPhase(NightSubPhase.detectiveActing, 10);
        break;
      case NightSubPhase.detectiveActing:
        // If detective didn't pick, auto-pick for investigation
        if (_currentState.detectiveTargetId == null) {
          final rng = Random();
          final alive = _currentState.alivePlayers
              .where((p) => p.role != GameRole.detective).toList();
          if (alive.isNotEmpty) {
            final target = alive[rng.nextInt(alive.length)];
            _currentState = _currentState.copyWith(
              detectiveTargetId: target.id,
              detectiveResult: target.isMafia,
            );
            _emit(WsEvent.investigationResult, {
              'targetId': target.id,
              'targetName': target.name,
              'isMafia': target.isMafia,
            });
          }
        }
        // All night actions done → resolve night
        _resolveNight();
        break;
    }
  }

  void _resolveNight() {
    final mafiaTarget = _currentState.mafiaTargetId;
    final doctorTarget = _currentState.doctorTargetId;

    if (mafiaTarget == null) {
      // No target — nobody dies
      _emitDawn(saved: true, victimName: null);
      return;
    }

    final saved = mafiaTarget == doctorTarget;
    final victim = _currentState.players.firstWhere(
      (p) => p.id == mafiaTarget,
      orElse: () => _currentState.players.first,
    );

    _emitDawn(saved: saved, victimName: saved ? null : victim.name);

    if (!saved) {
      // Eliminate after short reveal delay
      Future.delayed(const Duration(seconds: 2), () {
        final updatedPlayers = _currentState.players.map((p) {
          if (p.id == victim.id) {
            return p.copyWith(
              status: PlayerStatus.eliminated,
              voiceState: VoiceState.muted,
              isEliminating: true,
            );
          }
          return p;
        }).toList();

        _currentState = _currentState.copyWith(
          players: updatedPlayers,
          eliminatedPlayerId: victim.id,
        );

        _emit(WsEvent.playerEliminated, {
          'playerId': victim.id,
          'playerName': victim.name,
        });

        // Reset isEliminating flag after animation
        Future.delayed(const Duration(seconds: 1), () {
          final reset = _currentState.players.map((p) {
            if (p.id == victim.id) return p.copyWith(isEliminating: false);
            return p;
          }).toList();
          _currentState = _currentState.copyWith(players: reset);
        });
      });
    }

    // After dawn phase, check win or start day
    Future.delayed(const Duration(seconds: 5), () {
      if (_checkWinCondition()) return;
      _startPhase(GamePhase.day);
    });
  }

  void _emitDawn({required bool saved, String? victimName}) {
    final dawnMsg = saved
        ? 'The Syndicate attempted a hit, but no one died last night.'
        : 'The city wakes up to a tragedy. $victimName was eliminated.';

    _currentState = _currentState.copyWith(
      phase: GamePhase.morningReveal,
      timeRemaining: 5,
      nightSubPhase: null,
    );

    _emit(WsEvent.dawnAnnounce, {
      'message': dawnMsg,
      'saved': saved,
      'victimName': victimName,
    });

    _emit(WsEvent.phaseChange, {
      'phase': 'morningReveal',
      'duration': 5,
      'morningMessage': dawnMsg,
    });
  }

  void _startPhase(GamePhase phase) {
    int duration;
    switch (phase) {
      case GamePhase.day:
        duration = 60;
        break;
      case GamePhase.voting:
        duration = 10;
        break;
      case GamePhase.runoff:
        duration = 10;
        break;
      default:
        duration = 10;
    }

    _currentState = _currentState.copyWith(
      phase: phase,
      timeRemaining: duration,
      votes: {},
      nightSubPhase: null,
    );

    _emit(WsEvent.phaseChange, {
      'phase': phase.name,
      'duration': duration,
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      _currentState = _currentState.copyWith(
        timeRemaining: _currentState.timeRemaining - 1,
      );

      _emit(WsEvent.timerTick, {
        'remaining': _currentState.timeRemaining,
      });

      if (_currentState.timeRemaining <= 0) {
        t.cancel();
        _onPhaseEnd(phase);
      }
    });
  }

  void _onPhaseEnd(GamePhase phase) {
    switch (phase) {
      case GamePhase.day:
        _startPhase(GamePhase.voting);
        break;
      case GamePhase.voting:
        _resolveVotes();
        break;
      case GamePhase.runoff:
        _resolveRunoff();
        break;
      default:
        break;
    }
  }

  void _handleVote(Map<String, dynamic> data) {
    final targetId = data['targetId'] as String?;
    if (targetId != null) {
      final votes = Map<String, String>.from(_currentState.votes);
      votes[_currentState.localPlayerId ?? ''] = targetId;
      _currentState = _currentState.copyWith(votes: votes);
    }
  }

  void _handleMafiaAction(Map<String, dynamic> data) {
    _currentState = _currentState.copyWith(
      mafiaTargetId: data['targetId'] as String?,
    );
  }

  void _handleDoctorAction(Map<String, dynamic> data) {
    _currentState = _currentState.copyWith(
      doctorTargetId: data['targetId'] as String?,
    );
  }

  void _handleDetectiveAction(Map<String, dynamic> data) {
    final targetId = data['targetId'] as String?;
    if (targetId != null) {
      final target = _currentState.players.firstWhere((p) => p.id == targetId);
      _currentState = _currentState.copyWith(
        detectiveTargetId: targetId,
        detectiveResult: target.isMafia,
      );
      // Private result — only sent to detective's client
      _emit(WsEvent.investigationResult, {
        'targetId': targetId,
        'targetName': target.name,
        'isMafia': target.isMafia,
      });
    }
  }

  void _resolveVotes() {
    final rng = Random();
    final alive = _currentState.alivePlayers;

    // Simulate AI votes
    final allVotes = <String, String>{};
    for (final p in alive) {
      if (p.id == _currentState.localPlayerId &&
          _currentState.votes.containsKey(p.id)) {
        allVotes[p.id] = _currentState.votes[p.id]!;
      } else {
        final targets = alive.where((t) => t.id != p.id).toList();
        if (targets.isNotEmpty) {
          allVotes[p.id] = targets[rng.nextInt(targets.length)].id;
        }
      }
    }

    // Count votes
    final voteCounts = <String, int>{};
    for (final targetId in allVotes.values) {
      voteCounts[targetId] = (voteCounts[targetId] ?? 0) + 1;
    }

    _emit(WsEvent.votesRevealed, {'votes': allVotes});

    if (voteCounts.isEmpty) {
      Future.delayed(const Duration(seconds: 2), () {
        _startNightPhase();
      });
      return;
    }

    final maxVotes = voteCounts.values.reduce(max);
    final topVoted =
        voteCounts.entries.where((e) => e.value == maxVotes).toList();

    if (topVoted.length > 1) {
      // Tie → runoff
      _currentState = _currentState.copyWith(
        tiedPlayerIds: topVoted.map((e) => e.key).toList(),
      );
      _emit(WsEvent.runoffTriggered, {
        'tiedPlayers': topVoted.map((e) => e.key).toList(),
      });
      Future.delayed(const Duration(seconds: 2), () {
        _startPhase(GamePhase.runoff);
      });
    } else {
      // Eliminate the voted player
      _eliminatePlayer(topVoted.first.key);
    }
  }

  void _resolveRunoff() {
    final rng = Random();
    final tied = _currentState.tiedPlayerIds;
    if (tied.isEmpty) return;

    // Random elimination from tied
    final eliminatedId = tied[rng.nextInt(tied.length)];
    _eliminatePlayer(eliminatedId);
  }

  void _eliminatePlayer(String playerId) {
    final updatedPlayers = _currentState.players.map((p) {
      if (p.id == playerId) {
        return p.copyWith(
          status: PlayerStatus.eliminated,
          isEliminating: true,
        );
      }
      return p;
    }).toList();

    _currentState = _currentState.copyWith(
      players: updatedPlayers,
      eliminatedPlayerId: playerId,
      phase: GamePhase.elimination,
    );

    final player = _currentState.players.firstWhere((p) => p.id == playerId);

    _emit(WsEvent.playerEliminated, {
      'playerId': playerId,
      'playerName': player.name,
      'role': player.role?.name,
    });

    if (_checkWinCondition()) return;

    // After elimination animation, go to next night
    Future.delayed(const Duration(seconds: 3), () {
      // Reset isEliminating
      final reset = _currentState.players.map((p) {
        if (p.id == playerId) return p.copyWith(isEliminating: false);
        return p;
      }).toList();
      _currentState = _currentState.copyWith(
        players: reset,
        roundNumber: _currentState.roundNumber + 1,
      );
      _startNightPhase();
    });
  }

  bool _checkWinCondition() {
    final alive = _currentState.alivePlayers;
    final mafiaAlive = alive.where((p) => p.isMafia).length;
    final civAlive = alive.where((p) => !p.isMafia).length;

    if (mafiaAlive == 0) {
      _endGame(WinningSide.civilians);
      return true;
    }
    if (mafiaAlive >= civAlive) {
      _endGame(WinningSide.mafia);
      return true;
    }
    return false;
  }

  void _endGame(WinningSide winner) {
    _timer?.cancel();
    _voiceSimTimer?.cancel();

    // Determine MVP (most active player, simplified: random alive player)
    final rng = Random();
    final alive = _currentState.alivePlayers;
    final mvpId = alive.isNotEmpty
        ? alive[rng.nextInt(alive.length)].id
        : _currentState.localPlayerId;

    _currentState = _currentState.copyWith(
      phase: GamePhase.result,
      winner: winner,
    );
    _emit(WsEvent.gameResult, {
      'winner': winner.name,
      'xpGained': 150,
      'rankDelta': winner == WinningSide.civilians ? 12 : -8,
      'bpXpGained': 80,
      'influenceGained': 25,
      'popularityGained': 5,
      'mvpPlayerId': mvpId,
      'players': _currentState.players.map((p) => p.toJson()).toList(),
    });
  }

  void _startVoiceSimulation() {
    final rng = Random();
    _voiceSimTimer?.cancel();
    _voiceSimTimer = Timer.periodic(const Duration(milliseconds: 800), (_) {
      if (_currentState.phase == GamePhase.day ||
          _currentState.phase == GamePhase.lobby ||
          _currentState.phase == GamePhase.runoff) {
        final alive = _currentState.alivePlayers;
        if (alive.isEmpty) return;

        final updatedPlayers = _currentState.players.map((p) {
          if (p.isAlive) {
            final shouldSpeak = rng.nextDouble() < 0.15;
            return p.copyWith(
              voiceState: shouldSpeak ? VoiceState.speaking : VoiceState.idle,
            );
          }
          return p;
        }).toList();

        _currentState = _currentState.copyWith(players: updatedPlayers);
        _emit(WsEvent.voiceStateChange, {});
      }
    });
  }

  /// Dispose
  void dispose() {
    _timer?.cancel();
    _voiceSimTimer?.cancel();
    if (!_eventController.isClosed) {
      _eventController.close();
    }
  }
}
