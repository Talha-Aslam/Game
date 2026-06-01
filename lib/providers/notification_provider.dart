import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/websocket_service.dart';
import 'game_provider.dart';
import 'auth_provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_gradients.dart';

final globalsnackBarKey = GlobalKey<ScaffoldMessengerState>();

final activeChatFriendIdProvider = StateProvider<String?>((ref) => null);

class NotificationState {
  final Map<String, int> unreadMessages; // Map of friendId to unread count
  final int unseenGifts;
  final int unseenInvites;

  const NotificationState({
    this.unreadMessages = const {},
    this.unseenGifts = 0,
    this.unseenInvites = 0,
  });

  bool get hasUnreadMessages => unreadMessages.values.any((count) => count > 0);

  NotificationState copyWith({
    Map<String, int>? unreadMessages,
    int? unseenGifts,
    int? unseenInvites,
  }) {
    return NotificationState(
      unreadMessages: unreadMessages ?? this.unreadMessages,
      unseenGifts: unseenGifts ?? this.unseenGifts,
      unseenInvites: unseenInvites ?? this.unseenInvites,
    );
  }
}

class NotificationNotifier extends Notifier<NotificationState> {
  StreamSubscription? _sub;

  @override
  NotificationState build() {
    final ws = ref.watch(wsServiceProvider);
    _listen(ws);

    ref.onDispose(() {
      _sub?.cancel();
    });

    return const NotificationState();
  }

  void _listen(WebSocketService ws) {
    _sub?.cancel();
    _sub = ws.eventStream.listen((msg) {
      if (msg.event == 'private_message') {
        final data = msg.data;
        final senderId = data['senderId'] as String?;
        final currentUserId = ref.read(authProvider).user?.id;
        final activeChatId = ref.read(activeChatFriendIdProvider);

        if (senderId != null && senderId != currentUserId) {
          if (activeChatId != senderId) {
            _handleNewMessage(senderId);
            _showTopSnackbar(
              'New message from ${data['senderName'] ?? 'a friend'}',
            );
          }
        }
      } else if (msg.event == 'gift_received') {
        final data = msg.data;
        final senderName = data['senderName'] ?? 'Someone';
        final amount = data['amount'] ?? 100;
        
        _showAmazingSnackbar(
          'Popularity Received! 🪙',
          '$senderName has sent you $amount popularity points!',
        );
        
        // Also refresh profile to update local popularity score
        ref.read(authProvider.notifier).checkAuth();
        
        state = state.copyWith(unseenGifts: state.unseenGifts + 1);
      } else if (msg.event == 'party_invite') {
        final senderName = msg.data['senderName'] ?? 'A friend';
        _showAmazingSnackbar(
          'Party Invite',
          '$senderName has invited you to a party!',
        );
        state = state.copyWith(unseenInvites: state.unseenInvites + 1);
      }
    });
  }

  void _handleNewMessage(String friendId) {
    final updatedMap = Map<String, int>.from(state.unreadMessages);
    updatedMap[friendId] = (updatedMap[friendId] ?? 0) + 1;
    state = state.copyWith(unreadMessages: updatedMap);
  }

  void markMessagesRead(String friendId) {
    final updatedMap = Map<String, int>.from(state.unreadMessages);
    updatedMap[friendId] = 0;
    state = state.copyWith(unreadMessages: updatedMap);
  }

  void syncUnreadCounts(Map<String, int> counts) {
    // Only update if they differ to prevent unnecessary rebuilds
    bool changed = false;
    final updatedMap = Map<String, int>.from(state.unreadMessages);

    for (final entry in counts.entries) {
      if (entry.value > 0 && (updatedMap[entry.key] ?? 0) < entry.value) {
        updatedMap[entry.key] = entry.value;
        changed = true;
      }
    }

    if (changed) {
      state = state.copyWith(unreadMessages: updatedMap);
    }
  }

  void _showTopSnackbar(
    String text, {
    IconData icon = Icons.chat_bubble,
    Color color = AppColors.cyan,
  }) {
    final messenger = globalsnackBarKey.currentState;
    if (messenger == null) return;

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surfaceLight,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(top: 10, left: 20, right: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showAmazingSnackbar(String title, String message) {
    final messenger = globalsnackBarKey.currentState;
    if (messenger == null) return;

    messenger.showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: AppGradients.purpleNeonGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.purpleNeon.withValues(alpha: 0.5),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.group_add, color: Colors.white, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(top: 20, left: 16, right: 16),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

final notificationProvider =
    NotifierProvider<NotificationNotifier, NotificationState>(
      () => NotificationNotifier(),
    );

final hasActiveInvitesProvider = Provider<bool>((ref) {
  return ref.watch(notificationProvider).unseenInvites > 0;
});

final hasUnreadMessagesProvider = Provider<bool>((ref) {
  return ref.watch(notificationProvider).hasUnreadMessages;
});
