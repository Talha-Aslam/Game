import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as flutter_secure_storage;
import '../core/constants/app_constants.dart';

enum MatchmakingStatus { idle, searching, found, accepted, roomJoined, failed }

class MatchmakingState {
  final MatchmakingStatus status;
  final int estimatedWaitSeconds;
  final int elapsedSeconds;
  final int playersFound;
  final int playersNeeded;
  final String? lobbyId;

  const MatchmakingState({
    this.status = MatchmakingStatus.idle,
    this.estimatedWaitSeconds = 15,
    this.elapsedSeconds = 0,
    this.playersFound = 0,
    this.playersNeeded = 15,
    this.lobbyId,
  });

  MatchmakingState copyWith({
    MatchmakingStatus? status,
    int? estimatedWaitSeconds,
    int? elapsedSeconds,
    int? playersFound,
    int? playersNeeded,
    String? lobbyId,
  }) {
    return MatchmakingState(
      status: status ?? this.status,
      estimatedWaitSeconds: estimatedWaitSeconds ?? this.estimatedWaitSeconds,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      playersFound: playersFound ?? this.playersFound,
      playersNeeded: playersNeeded ?? this.playersNeeded,
      lobbyId: lobbyId ?? this.lobbyId,
    );
  }
}

class MatchmakingService {
  final _stateController = StreamController<MatchmakingState>.broadcast();
  Stream<MatchmakingState> get stateStream => _stateController.stream;

  MatchmakingState _state = const MatchmakingState();
  MatchmakingState get currentState => _state;

  WebSocketChannel? _channel;
  StreamSubscription? _wsSubscription;

  void startSearching({bool ranked = false}) async {
    _state = const MatchmakingState(status: MatchmakingStatus.searching);
    _stateController.add(_state);
    
    final token = await const flutter_secure_storage.FlutterSecureStorage().read(key: 'jwt_token');
    if (token != null) {
      _connectWs(token, ranked ? "ranked" : "casual");
    } else {
      _state = const MatchmakingState(status: MatchmakingStatus.failed);
      _stateController.add(_state);
    }
  }

  void _connectWs(String token, String mode) {
    try {
      final _wsUrl = AppConstants.wsUrl.replaceAll('http', 'ws');
      _channel = WebSocketChannel.connect(
        Uri.parse('$_wsUrl/lobby?token=$token'),
      );

      _channel!.sink.add(jsonEncode({"action": "join_queue", "mode": mode}));

      _wsSubscription = _channel!.stream.listen(
        (message) {
          final data = jsonDecode(message);
          final event = data['event'];

          if (event == "queue_update") {
            _state = _state.copyWith(
              elapsedSeconds: data['elapsed'] ?? 0,
              estimatedWaitSeconds: data['estimated_wait'] ?? 15,
              playersFound: data['players_in_queue'] ?? 0,
            );
            _stateController.add(_state);
          } else if (event == "match_found") {
            _state = _state.copyWith(
              status: MatchmakingStatus.found,
              lobbyId: data['lobby_id'],
            );
            _stateController.add(_state);
          } else if (event == "room_joined") {
            _state = _state.copyWith(
              status: MatchmakingStatus.roomJoined,
              lobbyId: data['room_id'],
            );
            _stateController.add(_state);
          }
        },
        onDone: () {
          if (_state.status == MatchmakingStatus.searching) {
            _state = const MatchmakingState(status: MatchmakingStatus.failed);
            _stateController.add(_state);
          }
        },
      );
    } catch (e) {
      _state = const MatchmakingState(status: MatchmakingStatus.failed);
      _stateController.add(_state);
    }
  }

  void acceptMatch() {
    _state = _state.copyWith(status: MatchmakingStatus.accepted);
    _stateController.add(_state);

    // In MVP, backend auto-accepts after 3s, but we could send an action here
    _channel?.sink.add(jsonEncode({"action": "accept_match"}));
  }

  void cancelSearching() {
    _channel?.sink.add(jsonEncode({"action": "leave_queue"}));
    _wsSubscription?.cancel();
    _channel?.sink.close();
    _channel = null;

    _state = const MatchmakingState(status: MatchmakingStatus.idle);
    _stateController.add(_state);
  }

  void dispose() {
    cancelSearching();
    _stateController.close();
  }
}
