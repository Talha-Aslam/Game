import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../providers/social_provider.dart';
import '../../../../models/social/friend_model.dart';
import '../../widgets/shared_friend_list.dart';
import '../../widgets/friend_card_widget.dart';

/// All Friends tab — grouped by online/offline or search results
class AllFriendsTab extends ConsumerStatefulWidget {
  const AllFriendsTab({super.key});

  @override
  ConsumerState<AllFriendsTab> createState() => _AllFriendsTabState();
}

class _AllFriendsTabState extends ConsumerState<AllFriendsTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String _searchQuery = '';
  bool _isSearching = false;
  bool _isSearchLoading = false;
  List<FriendModel> _searchResults = [];
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
    
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    if (query.trim().isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _isSearchLoading = true;
    });

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        final results = await ref.read(socialServiceProvider).searchUsers(query);
        if (mounted && _searchQuery == query) {
          setState(() {
            _searchResults = results;
            _isSearchLoading = false;
          });
        }
      } catch (e) {
        if (mounted && _searchQuery == query) {
          setState(() {
            _isSearchLoading = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(friendsProvider);
    final allFriends = state.allFriends;

    if (state.isLoading && !_isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.purpleNeon),
      );
    }

    final online = allFriends.where((f) => f.isOnline).toList();
    final offline = allFriends.where((f) => !f.isOnline).toList();

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
                hintText: 'Search friends or global users...',
                prefixIcon: Icon(Icons.search, color: AppColors.white30, size: 18),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
                isDense: true,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
        ),
        Expanded(
          child: _isSearching
              ? _buildSearchResults(allFriends)
              : RefreshIndicator(
                  color: AppColors.purpleNeon,
                  backgroundColor: AppColors.surface,
                  onRefresh: () => ref.read(friendsProvider.notifier).refresh(),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      if (online.isNotEmpty) ...[
                        _SectionLabel(
                          'ONLINE — ${online.length}',
                          AppColors.online,
                        ),
                        ...online.map((f) => SharedFriendHelper.buildFriendCard(context, ref, f)),
                      ],
                      if (offline.isNotEmpty) ...[
                        _SectionLabel(
                          'OFFLINE — ${offline.length}',
                          AppColors.white30,
                        ),
                        ...offline.map((f) => SharedFriendHelper.buildFriendCard(context, ref, f)),
                      ],
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSearchResults(List<FriendModel> myFriends) {
    if (_isSearchLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.purpleNeon),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Text(
          'No players found',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white30),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final player = _searchResults[index];
        final isFriend = myFriends.any((f) => f.id == player.id);

        if (isFriend) {
          // It's a friend, use normal card
          final friendData = myFriends.firstWhere((f) => f.id == player.id);
          return SharedFriendHelper.buildFriendCard(context, ref, friendData);
        }

        // Not a friend, show add button
        return FriendCardWidget(
          friend: player,
          showActions: false,
          showAddFriend: true,
          onAddFriend: () {
            ref.read(friendsProvider.notifier).sendFriendRequest(player.id);
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Friend request sent to ${player.username}'),
                backgroundColor: AppColors.cyan,
              ),
            );
          },
          onViewProfile: () => GoRouter.of(context).push('/public-profile', extra: player),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionLabel(this.title, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppTextStyles.labelMedium.copyWith(
              color: color,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 1,
              color: color.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }
}
