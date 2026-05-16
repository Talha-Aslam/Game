import 'dart:async';

enum MatchmakingStatus { idle, searching, found, accepted, failed }

class MatchmakingState {
  final MatchmakingStatus status;
  final int estimatedWaitSeconds;
  final int elapsedSeconds;
  final int playersFound;
  final int playersNeeded;

  const MatchmakingState({
    this.status = MatchmakingStatus.idle,
    this.estimatedWaitSeconds = 30,
    this.elapsedSeconds = 0,
    this.playersFound = 0,
    this.playersNeeded = 8,
  });

  MatchmakingState copyWith({
    MatchmakingStatus? status,
    int? estimatedWaitSeconds,
    int? elapsedSeconds,
    int? playersFound,
    int? playersNeeded,
  }) {
    return MatchmakingState(
      status: status ?? this.status,
      estimatedWaitSeconds: estimatedWaitSeconds ?? this.estimatedWaitSeconds,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      playersFound: playersFound ?? this.playersFound,
      playersNeeded: playersNeeded ?? this.playersNeeded,
    );
  }
}

class MatchmakingService {
  final _stateController = StreamController<MatchmakingState>.broadcast();
  Stream<MatchmakingState> get stateStream => _stateController.stream;
  Timer? _timer;
  MatchmakingState _state = const MatchmakingState();
  MatchmakingState get currentState => _state;

  void startSearching({bool ranked = false}) {
    _state = const MatchmakingState(status: MatchmakingStatus.searching);
    _stateController.add(_state);
    int elapsed = 0;
    int playersFound = 1;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      elapsed++;
      if (elapsed % 2 == 0 && playersFound < 8) playersFound++;
      _state = _state.copyWith(elapsedSeconds: elapsed, playersFound: playersFound);
      _stateController.add(_state);
      if (playersFound >= 8) {
        t.cancel();
        _state = _state.copyWith(status: MatchmakingStatus.found);
        _stateController.add(_state);
      }
    });
  }

  void acceptMatch() {
    _state = _state.copyWith(status: MatchmakingStatus.accepted);
    _stateController.add(_state);
  }

  void cancelSearching() {
    _timer?.cancel();
    _state = const MatchmakingState(status: MatchmakingStatus.idle);
    _stateController.add(_state);
  }

  void dispose() {
    _timer?.cancel();
    _stateController.close();
  }
}
