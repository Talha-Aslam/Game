import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../providers/social_provider.dart';
import '../../../providers/party_provider.dart';
import '../../../widgets/particle_field.dart';
import 'tabs/online_friends_tab.dart';
import 'tabs/all_friends_tab.dart';
import 'tabs/friend_requests_tab.dart';
import 'tabs/recent_players_tab.dart';
import 'tabs/party_invites_tab.dart';
import 'tabs/family_invites_tab.dart';

class FriendsHubScreen extends ConsumerStatefulWidget {
  const FriendsHubScreen({super.key});

  @override
  ConsumerState<FriendsHubScreen> createState() => _FriendsHubScreenState();
}

class _FriendsHubScreenState extends ConsumerState<FriendsHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _tabs = [
    _TabItem(icon: Icons.circle, label: 'Online'),
    _TabItem(icon: Icons.people, label: 'All'),
    _TabItem(icon: Icons.person_add, label: 'Requests'),
    _TabItem(icon: Icons.history, label: 'Recent'),
    _TabItem(icon: Icons.groups, label: 'Party'),
    _TabItem(icon: Icons.shield, label: 'Family'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final friendsState = ref.watch(friendsProvider);
    final partyState = ref.watch(partyProvider);
    final onlineCount = friendsState.onlineCount;
    final requestCount = friendsState.pendingIncomingCount;
    final partyInviteCount = partyState.inviteCount;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: AppGradients.backgroundGradient,
            ),
          ),
          const ParticleField(particleCount: 20),
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.white05,
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text('Friends Hub', style: AppTextStyles.headlineMedium),
                      const Spacer(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Tab bar
                _buildTabBar(onlineCount, requestCount, partyInviteCount),
                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      OnlineFriendsTab(),
                      AllFriendsTab(),
                      FriendRequestsTab(),
                      RecentPlayersTab(),
                      PartyInvitesTab(),
                      FamilyInvitesTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(int onlineCount, int requestCount, int partyCount) {
    return Container(
      height: 42,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppColors.white05,
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.purpleNeon.withValues(alpha: 0.2),
          border: Border.all(
            color: AppColors.purpleNeon.withValues(alpha: 0.4),
          ),
        ),
        dividerColor: Colors.transparent,
        labelColor: AppColors.purpleGlow,
        unselectedLabelColor: AppColors.white30,
        labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        tabAlignment: TabAlignment.start,
        padding: const EdgeInsets.all(3),
        tabs: _tabs.asMap().entries.map((entry) {
          final i = entry.key;
          final tab = entry.value;
          int? badge;
          if (i == 0 && onlineCount > 0) badge = onlineCount;
          if (i == 2 && requestCount > 0) badge = requestCount;
          if (i == 4 && partyCount > 0) badge = partyCount;

          return Tab(
            height: 34,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(tab.icon, size: 14),
                const SizedBox(width: 4),
                Text(tab.label),
                if (badge != null) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: i == 0
                          ? AppColors.online.withValues(alpha: 0.2)
                          : AppColors.crimsonRed.withValues(alpha: 0.2),
                    ),
                    child: Text(
                      '$badge',
                      style: TextStyle(
                        color: i == 0 ? AppColors.online : AppColors.crimsonRed,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;
  const _TabItem({required this.icon, required this.label});
}
