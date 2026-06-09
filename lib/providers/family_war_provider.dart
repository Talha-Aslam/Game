import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/family/family_war_model.dart';
import '../models/player_model.dart';
import '../services/websocket_service.dart';
import 'matchmaking_provider.dart';

class FamilyWarState {
  final String? roomId;
  final String? creatorId;
  final String? challengerFamilyId;
  final String? defenderFamilyId;
  final List<PlayerModel> challengerRoster;
  final List<PlayerModel> defenderRoster;
  final bool isStarted;

  FamilyWarState({
    this.roomId,
    this.creatorId,
    this.challengerFamilyId,
    this.defenderFamilyId,
    this.challengerRoster = const [],
    this.defenderRoster = const [],
    this.isStarted = false,
  });

  FamilyWarState copyWith({
    String? roomId,
    String? creatorId,
    String? challengerFamilyId,
    String? defenderFamilyId,
    List<PlayerModel>? challengerRoster,
    List<PlayerModel>? defenderRoster,
    bool? isStarted,
  }) {
    return FamilyWarState(
      roomId: roomId ?? this.roomId,
      creatorId: creatorId ?? this.creatorId,
      challengerFamilyId: challengerFamilyId ?? this.challengerFamilyId,
      defenderFamilyId: defenderFamilyId ?? this.defenderFamilyId,
      challengerRoster: challengerRoster ?? this.challengerRoster,
      defenderRoster: defenderRoster ?? this.defenderRoster,
      isStarted: isStarted ?? this.isStarted,
    );
  }
}

class FamilyWarNotifier extends Notifier<FamilyWarState> {
  StreamSubscription? _sub;

  @override
  FamilyWarState build() {
    final ws = ref.watch(webSocketServiceProvider);
    
    _sub?.cancel();
    _sub = ws.eventStream.listen((msg) {
      if (msg.event == 'family_war_update') {
        final data = msg.data;
        
        List<PlayerModel> parseRoster(List<dynamic>? ids) {
            if (ids == null) return [];
            return ids.map((pMap) => PlayerModel(
                id: pMap['id'].toString(),
                name: pMap['name'].toString(),
                avatarUrl: pMap['avatarUrl']?.toString() ?? '',
                rankTier: pMap['rankTier'] ?? 1,
                equippedCosmetics: pMap['equippedCosmetics'] ?? {},
            )).toList();
        }

        state = state.copyWith(
          roomId: data['room_id'],
          creatorId: data['creator_id'],
          challengerFamilyId: data['challenger_family_id'],
          defenderFamilyId: data['defender_family_id'],
          challengerRoster: parseRoster(data['challenger_roster']),
          defenderRoster: parseRoster(data['defender_roster']),
          isStarted: data['is_started'] ?? false,
        );
      }
    });

    ref.onDispose(() {
      _sub?.cancel();
    });

    return FamilyWarState();
  }

  void createWarLobby(String? defenderFamilyId) {
    ref.read(webSocketServiceProvider).send('create_war_lobby', {
      if (defenderFamilyId != null) 'defender_family_id': defenderFamilyId
    });
  }

  void joinWarLobby(String roomId, bool isDefender) {
    ref.read(webSocketServiceProvider).send('join_war_lobby', {
      'room_id': roomId,
      'is_defender': isDefender
    });
  }

  void inviteClan() {
    if (state.roomId != null) {
      ref.read(webSocketServiceProvider).send('invite_family_to_war', {
        'room_id': state.roomId
      });
    }
  }

  void startWar() {
    if (state.roomId != null) {
      ref.read(webSocketServiceProvider).send('start_family_war', {
        'room_id': state.roomId
      });
    }
  }
}

final familyWarProvider = NotifierProvider<FamilyWarNotifier, FamilyWarState>(FamilyWarNotifier.new);
