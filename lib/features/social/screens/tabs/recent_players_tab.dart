import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../providers/social_provider.dart';
import '../../widgets/friend_card_widget.dart';

/// Recent Players tab — last 20 players interacted with
class RecentPlayersTab extends ConsumerWidget {
  const RecentPlayersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(friendsProvider);
    final recentPlayers = state.recentPlayers;

    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.purpleNeon),
      );
    }

    if (recentPlayers.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, color: AppColors.white10, size: 56),
            const SizedBox(height: 12),
            Text(
              'No recent players',
              style: TextStyle(color: AppColors.white30, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Play some matches to see players here',
              style: TextStyle(color: AppColors.white10, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: recentPlayers.length,
      itemBuilder: (context, index) {
        final player = recentPlayers[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index == 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'LAST ${recentPlayers.length} PLAYERS',
                  style: const TextStyle(
                    color: AppColors.white30,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            FriendCardWidget(
              friend: player,
              showActions: false,
              showAddFriend: true,
              onAddFriend: () {
                ref.read(friendsProvider.notifier).sendFriendRequest(player.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Friend request sent to ${player.username}'),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              onViewProfile: () => context.push('/public-profile', extra: player),
            ),
          ],
        );
      },
    );
  }
}
