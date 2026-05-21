import 'dart:async';
import 'dart:math';
import '../models/social/friend_model.dart';

/// Mock presence service simulating real-time presence updates
class PresenceService {
  final _rng = Random();
  final _presenceController = StreamController<FriendModel>.broadcast();
  Timer? _simulationTimer;

  Stream<FriendModel> get presenceStream => _presenceController.stream;

  /// Start simulating presence changes
  void startSimulation(List<FriendModel> friends) {
    _simulationTimer?.cancel();
    _simulationTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (friends.isEmpty) return;
      final idx = _rng.nextInt(friends.length);
      final friend = friends[idx];

      // Toggle status randomly
      final wasOnline = friend.isOnline;
      final newStatus = wasOnline
          ? (_rng.nextDouble() < 0.3 ? OnlineStatus.offline : friend.onlineStatus)
          : (_rng.nextDouble() < 0.3 ? OnlineStatus.online : OnlineStatus.offline);

      final activities = PlayerActivity.values;
      final updated = friend.copyWith(
        onlineStatus: newStatus,
        currentActivity: newStatus != OnlineStatus.offline
            ? activities[_rng.nextInt(activities.length)]
            : PlayerActivity.idle,
        lastSeen: newStatus == OnlineStatus.offline ? DateTime.now() : null,
      );

      friends[idx] = updated;
      if (!_presenceController.isClosed) {
        _presenceController.add(updated);
      }
    });
  }

  /// Set own status
  Future<void> setStatus(OnlineStatus status) async {
    // In production, this would update via WebSocket
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Set own activity
  Future<void> setActivity(PlayerActivity activity) async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  void dispose() {
    _simulationTimer?.cancel();
    if (!_presenceController.isClosed) {
      _presenceController.close();
    }
  }
}
