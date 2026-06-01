import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../providers/social_provider.dart';
import '../../widgets/shared_friend_list.dart';

/// Online Friends tab — shows only currently online friends
class OnlineFriendsTab extends ConsumerStatefulWidget {
  const OnlineFriendsTab({super.key});

  @override
  ConsumerState<OnlineFriendsTab> createState() => _OnlineFriendsTabState();
}

class _OnlineFriendsTabState extends ConsumerState<OnlineFriendsTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(friendsProvider);
    final allOnlineFriends = state.onlineFriends;

    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.purpleNeon),
      );
    }

    final onlineFriends = _searchQuery.isEmpty
        ? allOnlineFriends
        : allOnlineFriends.where((f) =>
            f.username.toLowerCase().contains(_searchQuery.toLowerCase()),
          ).toList();

    if (allOnlineFriends.isEmpty) {
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

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.white05,
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: TextField(
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.white),
              decoration: const InputDecoration(
                hintText: 'Search online friends...',
                prefixIcon: Icon(Icons.search, color: AppColors.white30, size: 18),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
        ),
        Expanded(
          child: onlineFriends.isEmpty
              ? Center(
                  child: Text(
                    'No online friends match "$_searchQuery"',
                    style: const TextStyle(color: AppColors.white30, fontSize: 14),
                  ),
                )
              : RefreshIndicator(
                  color: AppColors.purpleNeon,
                  backgroundColor: AppColors.surface,
                  onRefresh: () => ref.read(friendsProvider.notifier).refresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: onlineFriends.length,
                    itemBuilder: (context, index) {
                      final friend = onlineFriends[index];
                      return SharedFriendHelper.buildFriendCard(context, ref, friend);
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
