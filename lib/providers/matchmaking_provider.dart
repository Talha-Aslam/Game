import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/matchmaking_service.dart';

final matchmakingServiceProvider = Provider<MatchmakingService>((ref) {
  final service = MatchmakingService();
  ref.onDispose(() => service.dispose());
  return service;
});

final matchmakingStateProvider =
    StreamProvider<MatchmakingState>((ref) {
  return ref.watch(matchmakingServiceProvider).stateStream;
});
