import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/social/social_notification_model.dart';
import '../services/notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(),
);

class NotificationState {
  final List<SocialNotification> notifications;
  final int unreadCount;
  final bool isLoading;

  const NotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
  });

  NotificationState copyWith({
    List<SocialNotification>? notifications,
    int? unreadCount,
    bool? isLoading,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class NotificationNotifier extends Notifier<NotificationState> {
  @override
  NotificationState build() {
    _loadNotifications();
    return const NotificationState(isLoading: true);
  }

  NotificationService get _service => ref.read(notificationServiceProvider);

  Future<void> _loadNotifications() async {
    final notifications = await _service.getNotifications();
    final unread = await _service.getUnreadCount();
    state = state.copyWith(
      notifications: notifications,
      unreadCount: unread,
      isLoading: false,
    );
  }

  Future<void> markAsRead(String id) async {
    await _service.markAsRead(id);
    await _loadNotifications();
  }

  Future<void> markAllRead() async {
    await _service.markAllRead();
    await _loadNotifications();
  }

  Future<void> refresh() async => _loadNotifications();
}

final notificationProvider =
    NotifierProvider<NotificationNotifier, NotificationState>(
  NotificationNotifier.new,
);

final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationProvider).unreadCount;
});

final hasActiveInvitesProvider = Provider<bool>((ref) {
  final notifs = ref.watch(notificationProvider).notifications;
  return notifs.any((n) =>
      !n.isRead &&
      (n.type == SocialNotificationType.partyInvite ||
          n.type == SocialNotificationType.familyInvite));
});
