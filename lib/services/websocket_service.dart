import 'dart:async';
import 'dart:convert';
import 'dart:math';
import '../models/game_state_model.dart';
import '../models/player_model.dart';

/// WebSocket event types
class WsEvent {
  static const String lobbyUpdate = 'lobby_update';
  static const String matchFound = 'match_found';
  static const String roleAssigned = 'role_assigned';
  static const String phaseChange = 'phase_change';
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
    // In production, this would send via WebSocket
    // For mock, we handle it locally
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
        _startGame();
      }
    });
    _emit(WsEvent.matchFound, {'countdown': 3});
  }

  /// ─── Game Simulation ───
  void _startGame() {
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
      );
    });

    _currentState = GameStateModel(
      gameId: 'game_${DateTime.now().millisecondsSinceEpoch}',
      phase: GamePhase.roleAssignment,
      players: players,
      localPlayerId: 'player_0',
      roundNumber: 1,
      timeRemaining: 5,
    );

    _emit(WsEvent.roleAssigned, {
      'role': players[0].role!.name,
      'players': players.map((p) => p.toJson()).toList(),
      'localPlayerId': 'player_0',
    });

    // After role reveal, start night phase
    Future.delayed(const Duration(seconds: 5), () {
      _startPhase(GamePhase.night);
    });

    // Simulate random voice activity
    _startVoiceSimulation();
  }

  void _startPhase(GamePhase phase) {
    int duration;
    switch (phase) {
      case GamePhase.night:
        duration = 15; // shortened for demo
        break;
      case GamePhase.day:
        duration = 30;
        break;
      case GamePhase.voting:
        duration = 15;
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
      case GamePhase.night:
        _resolveNight();
        break;
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

  void _resolveNight() {
    final rng = Random();
    final alive = _currentState.alivePlayers;
    final civilians =
        alive.where((p) => p.role != GameRole.mafia).toList();

    if (civilians.isEmpty) {
      _endGame(WinningSide.mafia);
      return;
    }

    // Pick random victim (simulate mafia choice)
    final victim = civilians[rng.nextInt(civilians.length)];

    // 30% chance doctor saves
    final saved = rng.nextDouble() < 0.3;

    if (saved) {
      _emit(WsEvent.phaseChange, {
        'phase': 'day',
        'message': 'No one was eliminated last night!',
      });
    } else {
      // Eliminate
      final updatedPlayers = _currentState.players.map((p) {
        if (p.id == victim.id) {
          return p.copyWith(status: PlayerStatus.eliminated);
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
    }

    // Check win condition
    if (_checkWinCondition()) return;

    // Start day after delay
    Future.delayed(const Duration(seconds: 3), () {
      _startPhase(GamePhase.day);
    });
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
      _emit(WsEvent.phaseChange, {
        'detectiveResult': target.isMafia,
        'targetId': targetId,
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
        _startPhase(GamePhase.night);
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
        return p.copyWith(status: PlayerStatus.eliminated);
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
      _currentState = _currentState.copyWith(
        roundNumber: _currentState.roundNumber + 1,
      );
      _startPhase(GamePhase.night);
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
    _currentState = _currentState.copyWith(
      phase: GamePhase.result,
      winner: winner,
    );
    _emit(WsEvent.gameResult, {
      'winner': winner.name,
    });
  }

  void _startVoiceSimulation() {
    final rng = Random();
    _voiceSimTimer?.cancel();
    _voiceSimTimer = Timer.periodic(const Duration(milliseconds: 800), (_) {
      if (_currentState.phase == GamePhase.day ||
          _currentState.phase == GamePhase.voting) {
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
