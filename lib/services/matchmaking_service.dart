import 'dart:async';
import 'websocket_service.dart';

enum MatchmakingStatus { idle, searching, found, accepted, roomJoined, failed }

class MatchmakingState {
  final MatchmakingStatus status;
  final int estimatedWaitSeconds;
  final int elapsedSeconds;
  final int playersFound;
  final int playersNeeded;
  final String? lobbyId;
  final int acceptedPlayers;
  final int totalPlayersToAccept;

  const MatchmakingState({
    this.status = MatchmakingStatus.idle,
    this.estimatedWaitSeconds = 15,
    this.elapsedSeconds = 0,
    this.playersFound = 0,
    this.playersNeeded = 15,
    this.lobbyId,
    this.acceptedPlayers = 0,
    this.totalPlayersToAccept = 0,
  });

  MatchmakingState copyWith({
    MatchmakingStatus? status,
    int? estimatedWaitSeconds,
    int? elapsedSeconds,
    int? playersFound,
    int? playersNeeded,
    String? lobbyId,
    int? acceptedPlayers,
    int? totalPlayersToAccept,
  }) {
    return MatchmakingState(
      status: status ?? this.status,
      estimatedWaitSeconds: estimatedWaitSeconds ?? this.estimatedWaitSeconds,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      playersFound: playersFound ?? this.playersFound,
      playersNeeded: playersNeeded ?? this.playersNeeded,
      lobbyId: lobbyId ?? this.lobbyId,
      acceptedPlayers: acceptedPlayers ?? this.acceptedPlayers,
      totalPlayersToAccept: totalPlayersToAccept ?? this.totalPlayersToAccept,
    );
  }
}

class MatchmakingService {
  final _stateController = StreamController<MatchmakingState>.broadcast();
  Stream<MatchmakingState> get stateStream => _stateController.stream;

  MatchmakingState _state = const MatchmakingState();
  MatchmakingState get currentState => _state;

  StreamSubscription? _wsSubscription;
  StreamSubscription? _statusSubscription;
  final WebSocketService _wsService;

  MatchmakingService(this._wsService) {
    _statusSubscription = _wsService.connectionStatusStream.listen((connected) {
      if (connected && _state.status != MatchmakingStatus.idle) {
        // Recover state after reconnection
        _wsService.send('sync_state');
      }
    });
  }

  void startSearching({bool ranked = false}) async {
    _state = const MatchmakingState(status: MatchmakingStatus.searching);
    _stateController.add(_state);
    
    _wsSubscription?.cancel();
    _wsSubscription = _wsService.eventStream.listen((msg) {
      final event = msg.event;
      final data = msg.data;

      if (event == "queue_update") {
        _state = _state.copyWith(
          status: MatchmakingStatus.searching,
          elapsedSeconds: data['elapsed'] ?? 0,
          estimatedWaitSeconds: data['estimated_wait'] ?? 15,
          playersFound: data['players_in_queue'] ?? 0,
        );
        _stateController.add(_state);
      } else if (event == "match_found") {
        _state = _state.copyWith(
          status: MatchmakingStatus.found,
          lobbyId: data['match_id'] ?? data['lobby_id'],
        );
        _stateController.add(_state);
      } else if (event == "match_status") {
        _state = _state.copyWith(
          acceptedPlayers: data['accepted'] ?? 0,
          totalPlayersToAccept: data['total'] ?? 0,
        );
        _stateController.add(_state);
      } else if (event == "room_joined") {
        _state = _state.copyWith(
          status: MatchmakingStatus.roomJoined,
          lobbyId: data['room_id'],
        );
        _stateController.add(_state);
      } else if (event == "match_declined") {
        _state = const MatchmakingState(status: MatchmakingStatus.failed);
        _stateController.add(_state);
        
        _wsSubscription?.cancel();
        _wsSubscription = null;
      } else if (event == "idle") {
        if (_state.status != MatchmakingStatus.idle) {
          _state = const MatchmakingState(status: MatchmakingStatus.idle);
          _stateController.add(_state);
        }
      }
    });

    _wsService.connectLobby().then((_) {
       _wsService.send("join_queue", {"mode": ranked ? "ranked" : "casual"});
    });
  }

  void acceptMatch() {
    _state = _state.copyWith(status: MatchmakingStatus.accepted);
    _stateController.add(_state);

    _wsService.send("accept_match", {"match_id": _state.lobbyId});
  }

  void cancelSearching() {
    if (_state.status == MatchmakingStatus.found || _state.status == MatchmakingStatus.accepted) {
      _wsService.send("decline_match", {"match_id": _state.lobbyId});
    } else {
      _wsService.send("leave_queue");
    }
    
    _wsSubscription?.cancel();
    _wsSubscription = null;

    _state = const MatchmakingState(status: MatchmakingStatus.idle);
    _stateController.add(_state);
  }

  void dispose() {
    _statusSubscription?.cancel();
    _wsSubscription?.cancel();
    _stateController.close();
  }
}
