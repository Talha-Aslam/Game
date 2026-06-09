import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player_model.dart';
import 'matchmaking_provider.dart';

class CustomRoomState {
  final String? roomId;
  final String? creatorId;
  final List<PlayerModel> players;
  final bool isStarted;
  final bool wasKicked;

  CustomRoomState({
    this.roomId,
    this.creatorId,
    this.players = const [],
    this.isStarted = false,
    this.wasKicked = false,
  });

  CustomRoomState copyWith({
    String? roomId,
    String? creatorId,
    List<PlayerModel>? players,
    bool? isStarted,
    bool? wasKicked,
  }) {
    return CustomRoomState(
      roomId: roomId ?? this.roomId,
      creatorId: creatorId ?? this.creatorId,
      players: players ?? this.players,
      isStarted: isStarted ?? this.isStarted,
      wasKicked: wasKicked ?? this.wasKicked,
    );
  }
}

class CustomRoomNotifier extends Notifier<CustomRoomState> {
  StreamSubscription? _sub;

  @override
  CustomRoomState build() {
    final ws = ref.watch(webSocketServiceProvider);
    
    // Listen for events and update state
    _sub?.cancel();
    _sub = ws.eventStream.listen((msg) {
      if (msg.event == 'custom_room_update') {
        final data = msg.data;
        final List<dynamic> pList = data['players'] ?? [];
        
        final List<PlayerModel> players = pList.map((pMap) {
            return PlayerModel(
                id: pMap['id'].toString(),
                name: pMap['name'].toString(),
                avatarUrl: pMap['avatarUrl']?.toString() ?? '',
                rankTier: pMap['rankTier'] ?? 1,
                equippedCosmetics: pMap['equippedCosmetics'] ?? {},
            );
        }).toList();

        state = state.copyWith(
          roomId: data['room_id'],
          creatorId: data['creator_id'],
          players: players,
          isStarted: data['is_started'] ?? false,
          wasKicked: false,
        );
      } else if (msg.event == 'kicked_from_custom') {
        state = CustomRoomState(wasKicked: true); // Reset room state and set kicked flag
      }
    });

    ref.onDispose(() {
      _sub?.cancel();
    });

    return CustomRoomState();
  }

  void createRoom() {
    ref.read(webSocketServiceProvider).send('create_custom');
  }

  Future<bool> joinRoom(String roomId) async {
    final completer = Completer<bool>();
    
    final ws = ref.read(webSocketServiceProvider);
    StreamSubscription? tempSub;
    tempSub = ws.eventStream.listen((msg) {
      if (msg.event == 'custom_room_update' && msg.data['room_id'] == roomId) {
        tempSub?.cancel();
        if (!completer.isCompleted) completer.complete(true);
      } else if (msg.event == 'error' && msg.data['message'] == 'Failed to join room') {
        tempSub?.cancel();
        if (!completer.isCompleted) completer.complete(false);
      }
    });

    ws.send('join_custom', {'room_id': roomId});
    
    Future.delayed(const Duration(seconds: 5), () {
      tempSub?.cancel();
      if (!completer.isCompleted) completer.complete(false);
    });

    return completer.future;
  }

  void startMatch() {
    if (state.roomId != null) {
      ref.read(webSocketServiceProvider).send('start_custom', {'room_id': state.roomId});
    }
  }
}

final customRoomProvider = NotifierProvider<CustomRoomNotifier, CustomRoomState>(CustomRoomNotifier.new);
