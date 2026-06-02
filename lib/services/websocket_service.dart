import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants/app_constants.dart';

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

/// Real WebSocket service connecting to FastAPI backend
class WebSocketService {
  final _eventController = StreamController<WsMessage>.broadcast();
  Stream<WsMessage> get eventStream => _eventController.stream;

  WebSocketChannel? _channel;
  bool _isConnected = false;
  final _storage = const FlutterSecureStorage();

  bool get isConnected => _isConnected;

  /// Connect to the matchmaking lobby
  Future<void> connectLobby() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return;
    
    // Replace 'ws://...' based on AppConstants
    final wsUri = Uri.parse('${AppConstants.wsUrl}/lobby?token=$token');
    _connect(wsUri);
  }
  
  /// Connect to an active game room
  Future<void> connectGame(String roomId) async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return;
    
    final wsUri = Uri.parse('${AppConstants.wsUrl}/game/$roomId?token=$token');
    _connect(wsUri);
  }

  void _connect(Uri uri) {
    disconnect(); // Close existing if any
    
    try {
      _channel = WebSocketChannel.connect(uri);
      _isConnected = true;
      
      _channel!.stream.listen(
        (data) {
          try {
            final msg = WsMessage.fromJson(data);
            if (!_eventController.isClosed) {
              _eventController.add(msg);
            }
          } catch (e) {
            // Error parsing message
          }
        },
        onDone: () {
          _isConnected = false;
        },
        onError: (error) {
          _isConnected = false;
        },
      );
    } catch (e) {
      _isConnected = false;
    }
  }

  void disconnect() {
    _isConnected = false;
    _channel?.sink.close();
    _channel = null;
  }

  /// Send action to server
  void send(String action, [Map<String, dynamic>? data]) {
    if (_isConnected && _channel != null) {
      final payload = {'action': action, ...?data};
      _channel!.sink.add(jsonEncode(payload));
    }
  }

  void sendPartyInvite(String targetId) {
    if (!_isConnected || _channel == null) return;
    _channel!.sink.add(jsonEncode({
      'action': 'party_invite',
      'targetId': targetId,
    }));
  }

  void sendFamilyInvite(String targetId, String familyId, String familyName) {
    if (!_isConnected || _channel == null) return;
    _channel!.sink.add(jsonEncode({
      'action': 'family_invite',
      'targetId': targetId,
      'familyId': familyId,
      'familyName': familyName,
    }));
  }

  void dispose() {
    disconnect();
    if (!_eventController.isClosed) {
      _eventController.close();
    }
  }
}
