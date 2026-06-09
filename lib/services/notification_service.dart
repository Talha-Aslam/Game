import 'dart:async';
import 'dart:math';
import '../models/social/social_notification_model.dart';

/// Mock notification service (FCM stub)
class NotificationService {
  final _rng = Random();
  final _controller = StreamController<SocialNotification>.broadcast();
  final List<SocialNotification> _notifications = [];
  Timer? _simTimer;

  Stream<SocialNotification> get notificationStream => _controller.stream;

  NotificationService() {
    _notifications.addAll(_generateInitialNotifications());
  }

  Future<List<SocialNotification>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_notifications);
  }

  Future<int> getUnreadCount() async {
    return _notifications.where((n) => !n.isRead).length;
  }

  Future<void> markAsRead(String notificationId) async {
    final idx = _notifications.indexWhere((n) => n.id == notificationId);
    if (idx != -1) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
    }
  }

  Future<void> markAllRead() async {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
  }

  void addNotification(SocialNotification notification) {
    _notifications.insert(0, notification);
    if (!_controller.isClosed) {
      _controller.add(notification);
    }
  }

  void startSimulation() {
    _simTimer?.cancel();
    _simTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      final types = [
        SocialNotificationType.friendOnline,
        SocialNotificationType.letsPlay,
        SocialNotificationType.giftReceived,
      ];
      final names = ['ShadowKing', 'NightViper', 'GhostWalker', 'IronFist'];
      final type = types[_rng.nextInt(types.length)];
      final name = names[_rng.nextInt(names.length)];

      String title;
      String body;
      switch (type) {
        case SocialNotificationType.friendOnline:
          title = '$name is online';
          body = 'Join the city now.';
          break;
        case SocialNotificationType.letsPlay:
          title = "$name wants to play!";
          body = 'Your friend invited you to a match.';
          break;
        case SocialNotificationType.giftReceived:
          title = 'Gift from $name';
          body = 'You received a Golden Rose!';
          break;
        default:
          title = 'Notification';
          body = '';
      }

      addNotification(
        SocialNotification(
          id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
          type: type,
          title: title,
          body: body,
          fromUsername: name,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  List<SocialNotification> _generateInitialNotifications() {
    return [
      SocialNotification(
        id: 'notif_1',
        type: SocialNotificationType.friendOnline,
        title: 'ShadowKing is online',
        body: 'Join the city now.',
        fromUsername: 'ShadowKing',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      SocialNotification(
        id: 'notif_3',
        type: SocialNotificationType.familyInvite,
        title: 'Cobra Dynasty needs you',
        body: 'GhostWalker invited you to join [COBRA].',
        fromUsername: 'GhostWalker',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      SocialNotification(
        id: 'notif_4',
        type: SocialNotificationType.letsPlay,
        title: 'Your squad is waiting',
        body: 'IronFist wants to play together.',
        fromUsername: 'IronFist',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
  }

  void dispose() {
    _simTimer?.cancel();
    if (!_controller.isClosed) _controller.close();
  }
}
