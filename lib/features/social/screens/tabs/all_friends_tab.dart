import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../providers/social_provider.dart';
import '../../widgets/shared_friend_list.dart';

/// All Friends tab — grouped by online/offline
class AllFriendsTab extends ConsumerStatefulWidget {
  const AllFriendsTab({super.key});

  @override
  ConsumerState<AllFriendsTab> createState() => _AllFriendsTabState();
}

class _AllFriendsTabState extends ConsumerState<AllFriendsTab> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(friendsProvider);
    final allFriends = state.allFriends;

    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.purpleNeon),
      );
    }

    final filtered = _searchQuery.isEmpty
        ? allFriends
        : allFriends.where((f) =>
            f.username.toLowerCase().contains(_searchQuery.toLowerCase()),
          ).toList();

    final online = filtered.where((f) => f.isOnline).toList();
    final offline = filtered.where((f) => !f.isOnline).toList();

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
                hintText: 'Search friends...',
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
          child: RefreshIndicator(
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
