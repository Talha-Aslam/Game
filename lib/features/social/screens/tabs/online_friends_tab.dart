import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../providers/social_provider.dart';
import '../../../../providers/party_provider.dart';
import '../../widgets/friend_card_widget.dart';

/// Online Friends tab — shows only currently online friends
class OnlineFriendsTab extends ConsumerWidget {
  const OnlineFriendsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(friendsProvider);
    final onlineFriends = state.onlineFriends;

    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.purpleNeon),
      );
    }

    if (onlineFriends.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, color: AppColors.white10, size: 56),
            const SizedBox(height: 12),
            Text(
              'No friends online',
              style: TextStyle(color: AppColors.white30, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Check back later!',
              style: TextStyle(color: AppColors.white10, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.purpleNeon,
      backgroundColor: AppColors.surface,
      onRefresh: () => ref.read(friendsProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: onlineFriends.length,
        itemBuilder: (context, index) {
          final friend = onlineFriends[index];
          return FriendCardWidget(
            friend: friend,
            onInvite: () => ref.read(partyProvider.notifier).inviteFriend(friend),
            onMessage: () {},
            onViewProfile: () {},
            onSendPopularity: () {},
          );
        },
      ),
    );
  }
}
