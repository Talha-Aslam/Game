import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mafia_wars/providers/auth_provider.dart';
import 'package:mafia_wars/services/user_api_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/social/friend_model.dart';
import '../../../providers/party_provider.dart';
import '../../../providers/social_provider.dart';
import '../../../providers/notification_provider.dart';
import 'friend_card_widget.dart';

class SharedFriendHelper {
  static Widget buildFriendCard(
    BuildContext context,
    WidgetRef ref,
    FriendModel friend,
  ) {
    final unreadCount =
        ref.watch(notificationProvider).unreadMessages[friend.id] ?? 0;

    return FriendCardWidget(
      friend: friend,
      hasUnreadMessages: unreadCount > 0,
      onInvite: () {
        ref.read(partyProvider.notifier).inviteFriend(friend);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Party Invite sent to ${friend.username}!'),
            backgroundColor: AppColors.purpleNeon,
          ),
        );
      },
      onMessage: () {
        ref.read(notificationProvider.notifier).markMessagesRead(friend.id);
        ref.read(socialServiceProvider).markMessagesRead(friend.id);
        GoRouter.of(context).push('/chat/${friend.id}', extra: friend);
      },
      onViewProfile: () =>
          GoRouter.of(context).push('/public-profile', extra: friend),
      onSendPopularity: () {
        _showGiftDialog(context, ref, friend);
      },
      onRemove: () {
        _showRemoveConfirmation(context, ref, friend);
      },
    );
  }

  static void _showRemoveConfirmation(
    BuildContext context,
    WidgetRef ref,
    FriendModel friend,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Remove Friend',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to remove ${friend.username} from your friends list?',
          style: const TextStyle(color: AppColors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.white50),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(friendsProvider.notifier).removeFriend(friend.id);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Friend removed'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  static void _showGiftDialog(
    BuildContext context,
    WidgetRef ref,
    FriendModel friend,
  ) {
    final myInfluence = ref.read(authProvider).user?.influencePoints ?? 0;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Send Popularity',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: AppColors.gold, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Your Balance: $myInfluence',
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Select amount to send to ${friend.username}:',
              style: const TextStyle(color: AppColors.white70),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildGiftButton(context, ref, friend, 100),
                _buildGiftButton(context, ref, friend, 500),
                _buildGiftButton(context, ref, friend, 1000),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.white50),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildGiftButton(
    BuildContext context,
    WidgetRef ref,
    FriendModel friend,
    int amount,
  ) {
    return InkWell(
      onTap: () async {
        final messenger = ScaffoldMessenger.of(context);
        final myInfluence = ref.read(authProvider).user?.influencePoints ?? 0;

        Navigator.pop(context);

        if (myInfluence < amount) {
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Not enough popularity tokens!'),
              backgroundColor: Colors.redAccent,
            ),
          );
          return;
        }

        try {
          await ref
              .read(userApiServiceProvider)
              .giftPopularity(friend.id, amount);
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                'You have sent $amount popularity to ${friend.username}!',
              ),
              backgroundColor: AppColors.purpleNeon,
              duration: const Duration(seconds: 2),
            ),
          );
        } catch (e) {
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Failed to send popularity.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.stars, color: AppColors.gold, size: 28),
            const SizedBox(height: 8),
            Text(
              amount.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final userApiServiceProvider = Provider((ref) => UserApiService());
