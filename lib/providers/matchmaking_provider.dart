import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/matchmaking_service.dart';
import '../services/websocket_service.dart';

final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService();
  ref.onDispose(() => service.dispose());
  return service;
});

final matchmakingServiceProvider = Provider<MatchmakingService>((ref) {
  final wsService = ref.watch(webSocketServiceProvider);
  final service = MatchmakingService(wsService);
  ref.onDispose(() => service.dispose());
  return service;
});

final matchmakingStateProvider =
    StreamProvider<MatchmakingState>((ref) {
  return ref.watch(matchmakingServiceProvider).stateStream;
});
