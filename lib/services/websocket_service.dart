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
    final event = map['event'] as String;
    
    Map<String, dynamic> data = {};
    if (map.containsKey('data') && map['data'] is Map<String, dynamic>) {
      data = map['data'] as Map<String, dynamic>;
    } else {
      // For flat events like queue_update and match_found
      data = Map<String, dynamic>.from(map)..remove('event');
    }
    
    return WsMessage(
      event: event,
      data: data,
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
  
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  Uri? _lastUri;

  bool get isConnected => _isConnected;

  final _connectionStatusController = StreamController<bool>.broadcast();
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;

  /// Connect to the matchmaking lobby
  Future<void> connectLobby() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return;
    
    // Replace 'ws://...' based on AppConstants
    final wsUri = Uri.parse('${AppConstants.wsUrl}/lobby?token=$token');
    _lastUri = wsUri;
    _connect(wsUri);
  }
  
  /// Connect to an active game room
  Future<void> connectGame(String roomId) async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) return;
    
    final wsUri = Uri.parse('${AppConstants.wsUrl}/game/$roomId?token=$token');
    _lastUri = wsUri;
    _connect(wsUri);
  }

  void _connect(Uri uri) {
    _stopHeartbeat();
    _channel?.sink.close();
    
    try {
      _channel = WebSocketChannel.connect(uri);
      
      _channel!.stream.listen(
        (data) {
          if (!_isConnected) {
            _isConnected = true;
            _reconnectAttempts = 0;
            _connectionStatusController.add(true);
            _startHeartbeat();
          }
          
          try {
            final msg = WsMessage.fromJson(data);
            if (msg.event == 'pong') return; // Swallow heartbeats
            
            if (!_eventController.isClosed) {
              _eventController.add(msg);
            }
          } catch (e) {
            // Error parsing message
          }
        },
        onDone: () {
          _handleDisconnect();
        },
        onError: (error) {
          _handleDisconnect();
        },
      );
    } catch (e) {
      _handleDisconnect();
    }
  }

  void _handleDisconnect() {
    _isConnected = false;
    _connectionStatusController.add(false);
    _stopHeartbeat();
    _channel = null;
    
    // Auto-reconnect logic
    if (_lastUri != null) {
      _reconnectAttempts++;
      final delay = _reconnectAttempts < 5 ? 2 : 5;
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(Duration(seconds: delay), () {
        if (_lastUri != null && !_isConnected) {
          _connect(_lastUri!);
        }
      });
    }
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 20), (timer) {
      send('ping');
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void disconnect() {
    _lastUri = null;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _isConnected = false;
    _connectionStatusController.add(false);
    _stopHeartbeat();
    _channel?.sink.close();
    _channel = null;
  }

  /// Send action to server
  void send(String action, [Map<String, dynamic>? data]) {
    if (_channel != null) {
      final payload = {'action': action, ...?data};
      try {
        _channel!.sink.add(jsonEncode(payload));
      } catch (e) {
        // Sink might be closed
      }
    }
  }

  void sendFamilyInvite(String targetId, String familyId, String familyName) {
    send('family_invite', {
      'targetId': targetId,
      'familyId': familyId,
      'familyName': familyName,
    });
  }

  void dispose() {
    disconnect();
    if (!_eventController.isClosed) {
      _eventController.close();
    }
    if (!_connectionStatusController.isClosed) {
      _connectionStatusController.close();
    }
  }
}
