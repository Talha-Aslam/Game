import 'player_model.dart';

/// Game phases — full match flow
enum GamePhase {
  lobby,
  matchmaking,
  roleAssignment,
  night,
  morningReveal,
  day,
  voting,
  runoff,
  elimination,
  result;

  String get displayName {
    switch (this) {
      case GamePhase.lobby:
        return 'LOBBY';
      case GamePhase.matchmaking:
        return 'SEARCHING';
      case GamePhase.roleAssignment:
        return 'ROLE ASSIGNMENT';
      case GamePhase.night:
        return 'NIGHT';
      case GamePhase.morningReveal:
        return 'MORNING';
      case GamePhase.day:
        return 'DISCUSSION';
      case GamePhase.voting:
        return 'VOTING';
      case GamePhase.runoff:
        return 'RUNOFF';
      case GamePhase.elimination:
        return 'ELIMINATION';
      case GamePhase.result:
        return 'GAME OVER';
    }
  }

  bool get isNight => this == GamePhase.night;
  bool get isDay => this == GamePhase.day;
  bool get isVoting => this == GamePhase.voting;
  bool get isRunoff => this == GamePhase.runoff;
  bool get isMorning => this == GamePhase.morningReveal;
}

/// Winning side
enum WinningSide { mafia, civilians, none }

/// Match result stats
class MatchResultData {
  final int xpGained;
  final int rankDelta;
  final int bpXpGained;
  final int influenceGained;
  final int popularityGained;
  final String? mvpPlayerId;

  const MatchResultData({
    this.xpGained = 0,
    this.rankDelta = 0,
    this.bpXpGained = 0,
    this.influenceGained = 0,
    this.popularityGained = 0,
    this.mvpPlayerId,
  });
}

/// Game state model
class GameStateModel {
  final String gameId;
  final GamePhase phase;
  final List<PlayerModel> players;
  final int timeRemaining; // seconds
  final int roundNumber;
  final String? localPlayerId; // current user's player ID
  final String? eliminatedPlayerId; // most recently eliminated
  final List<String> tiedPlayerIds; // for runoff
  final Map<String, String> votes; // voterId -> targetId
  final WinningSide? winner;
  final String? mafiaTargetId; // who mafia chose to eliminate
  final String? doctorTargetId; // who doctor chose to save
  final String? detectiveTargetId; // who detective investigated
  final bool? detectiveResult; // true = mafia, false = not mafia
  final Set<String> readyPlayers; // lobby ready states
  final String? morningMessage; // "No one died" or victim name
  final MatchResultData? resultData;

  const GameStateModel({
    required this.gameId,
    this.phase = GamePhase.lobby,
    this.players = const [],
    this.timeRemaining = 0,
    this.roundNumber = 1,
    this.localPlayerId,
    this.eliminatedPlayerId,
    this.tiedPlayerIds = const [],
    this.votes = const {},
    this.winner,
    this.mafiaTargetId,
    this.doctorTargetId,
    this.detectiveTargetId,
    this.detectiveResult,
    this.readyPlayers = const {},
    this.morningMessage,
    this.resultData,
  });

  GameStateModel copyWith({
    String? gameId,
    GamePhase? phase,
    List<PlayerModel>? players,
    int? timeRemaining,
    int? roundNumber,
    String? localPlayerId,
    String? eliminatedPlayerId,
    List<String>? tiedPlayerIds,
    Map<String, String>? votes,
    WinningSide? winner,
    String? mafiaTargetId,
    String? doctorTargetId,
    String? detectiveTargetId,
    bool? detectiveResult,
    Set<String>? readyPlayers,
    String? morningMessage,
    MatchResultData? resultData,
  }) {
    return GameStateModel(
      gameId: gameId ?? this.gameId,
      phase: phase ?? this.phase,
      players: players ?? this.players,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      roundNumber: roundNumber ?? this.roundNumber,
      localPlayerId: localPlayerId ?? this.localPlayerId,
      eliminatedPlayerId: eliminatedPlayerId ?? this.eliminatedPlayerId,
      tiedPlayerIds: tiedPlayerIds ?? this.tiedPlayerIds,
      votes: votes ?? this.votes,
      winner: winner ?? this.winner,
      mafiaTargetId: mafiaTargetId ?? this.mafiaTargetId,
      doctorTargetId: doctorTargetId ?? this.doctorTargetId,
      detectiveTargetId: detectiveTargetId ?? this.detectiveTargetId,
      detectiveResult: detectiveResult ?? this.detectiveResult,
      readyPlayers: readyPlayers ?? this.readyPlayers,
      morningMessage: morningMessage ?? this.morningMessage,
      resultData: resultData ?? this.resultData,
    );
  }

  /// Get local player
  PlayerModel? get localPlayer {
    if (localPlayerId == null) return null;
    try {
      return players.firstWhere((p) => p.id == localPlayerId);
    } catch (_) {
      return null;
    }
  }

  /// Get alive players
  List<PlayerModel> get alivePlayers =>
      players.where((p) => p.isAlive).toList();

  /// Get eliminated players (graveyard)
  List<PlayerModel> get deadPlayers =>
      players.where((p) => !p.isAlive).toList();

  /// Check if local player is alive
  bool get isLocalPlayerAlive => localPlayer?.isAlive ?? false;

  /// Check if local player is mafia
  bool get isLocalPlayerMafia => localPlayer?.isMafia ?? false;

  /// Is local player ready
  bool get isLocalPlayerReady =>
      readyPlayers.contains(localPlayerId ?? '');
}
