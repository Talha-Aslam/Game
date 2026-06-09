import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../providers/family_provider.dart';
import '../../../providers/social_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/family_model.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import '../../../widgets/particle_field.dart';
import '../widgets/family_crest_widget.dart';
import '../widgets/family_level_progress_bar.dart';
import '../widgets/family_announcement_banner.dart';
import '../widgets/family_stat_card.dart';
import '../widgets/family_member_card.dart';
import '../widgets/member_action_sheet.dart';
import '../widgets/family_invite_card.dart';
import '../widgets/treasury_widget.dart';
import '../widgets/treasury_boost_card.dart';
import '../widgets/family_achievement_card.dart';
import '../../../models/family/family_treasury_model.dart';
import 'package:mafia_wars/providers/matchmaking_provider.dart';

class FamilyScreen extends ConsumerStatefulWidget {
  const FamilyScreen({super.key});
  @override
  ConsumerState<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends ConsumerState<FamilyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  StreamSubscription? _wsSub;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    
    _tabController.addListener(() {
      if (_tabController.index == 3) { // 3 is the Chat tab
        ref.read(familyProvider.notifier).markChatRead();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ws = ref.read(webSocketServiceProvider);
      final currentUser = ref.read(authProvider).user;

      _wsSub = ws.eventStream.listen((msg) {
        if (msg.event == 'family_member_updated' && mounted) {
          final data = msg.data;
          final targetUserId = data['target_user_id'] as String;
          final newRole = data['new_role'] as String?;
          final action = data['action'] as String;

          if (currentUser?.id == targetUserId && action == 'promoted') {
            ScaffoldMessenger.of(context).showMaterialBanner(
              MaterialBanner(
                content: Text(
                  '🎉 Congratulations! You have been promoted to ${newRole?.toUpperCase()}!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: AppColors.purpleNeon.withValues(alpha: 0.9),
                actions: [
                  TextButton(
                    onPressed: () => ScaffoldMessenger.of(
                      context,
                    ).hideCurrentMaterialBanner(),
                    child: const Text(
                      'DISMISS',
                      style: TextStyle(color: AppColors.cyan),
                    ),
                  ),
                ],
              ),
            );

            // Auto hide after 5 seconds
            Future.delayed(const Duration(seconds: 5), () {
              if (mounted) {
                ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              }
            });
          }
        } else if (msg.event == 'family_member_kicked' && mounted) {
          final data = msg.data;
          final actorName = data['actor_name'] as String? ?? 'Boss';

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              backgroundColor: AppColors.surface,
              title: const Text(
                'Kicked from Family',
                style: TextStyle(color: AppColors.crimsonRed),
              ),
              content: Text(
                '$actorName has removed you from the family.',
                style: const TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.go('/home');
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(color: AppColors.cyan),
                  ),
                ),
              ],
            ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _wsSub?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(familyProvider);

    if (state.isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppGradients.backgroundGradient,
          ),
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.purpleNeon),
          ),
        ),
      );
    }

    if (!state.hasFamily) return _buildNoFamilyView();
    return _buildHubView(state);
  }

  Widget _buildNoFamilyView() {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: AppGradients.backgroundGradient,
            ),
          ),
          const ParticleField(particleCount: 15),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: const Icon(
                          Icons.arrow_back,
                          color: AppColors.white70,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text('Family', style: AppTextStyles.headlineMedium),
                    ],
                  ),
                  const Spacer(),
                  Icon(
                    Icons.groups,
                    color: AppColors.purpleNeon.withValues(alpha: 0.3),
                    size: 80,
                  ),
                  const SizedBox(height: 20),
                  Text('No Family Yet', style: AppTextStyles.headlineLarge),
                  const SizedBox(height: 8),
                  Text(
                    'Create or join a Family to unlock social features',
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // Create
                  GestureDetector(
                    onTap: () {
                      final user = ref.read(authProvider).user;
                      if (user == null) return;
                      if (user.syndicateCoins < 500) {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: AppColors.surface,
                            title: const Text(
                              'Not Enough Coins',
                              style: TextStyle(color: Colors.white),
                            ),
                            content: const Text(
                              'You need 500 Syndicate Coins to create a family.',
                              style: TextStyle(color: AppColors.white70),
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
                                  context.push('/store');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.gold,
                                ),
                                child: const Text(
                                  'Buy with Syndicate Coins',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        context.push('/family/create');
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: AppGradients.purpleNeonGradient,
                      ),
                      child: const Center(
                        child: Text(
                          'CREATE FAMILY  (500 coins)',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Search
                  GestureDetector(
                    onTap: () => context.push('/family/search'),
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: AppColors.white05,
                        border: Border.all(
                          color: AppColors.cyan.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'SEARCH FAMILIES',
                          style: TextStyle(
                            color: AppColors.cyan,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHubView(FamilyHubState state) {
    final family = state.family!;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: AppGradients.backgroundGradient,
            ),
          ),
          const ParticleField(particleCount: 15),
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/home');
                          }
                        },
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
                      const SizedBox(width: 12),
                      FamilyCrestWidget(
                        themeColor: family.themeColor,
                        level: family.level,
                        size: 36,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              family.name,
                              style: AppTextStyles.headlineSmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              family.tag,
                              style: TextStyle(
                                color: family.themeColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Settings (Boss/Underboss)
                      GestureDetector(
                        onTap: () => context.push('/family/settings'),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.white05,
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: const Icon(
                            Icons.settings,
                            color: AppColors.white70,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Tab bar
                _buildTabBar(state),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _OverviewTab(
                        state: state,
                        onChatTap: () => _tabController.animateTo(3),
                      ),
                      _MembersTab(state: state, ref: ref),
                      _RequestsTab(state: state, ref: ref),
                      _ChatTab(),
                      _TreasuryTab(),
                      _AchievementsTab(state: state),
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

  Widget _buildTabBar(FamilyHubState state) {
    final tabs = [
      ('Overview', Icons.dashboard, null),
      ('Members', Icons.people, state.family?.memberCount),
      ('Requests', Icons.person_add, state.applications.length),
      ('Chat', Icons.chat, null),
      ('Treasury', Icons.account_balance, null),
      ('Achieve', Icons.emoji_events, null),
    ];
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
        labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
        tabAlignment: TabAlignment.start,
        padding: const EdgeInsets.all(3),
        tabs: tabs
            .map(
              (t) => Tab(
                height: 34,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(t.$2, size: 13),
                    const SizedBox(width: 4),
                    Text(t.$1),
                    if (t.$3 != null && (t.$3 as int) > 0) ...[
                      const SizedBox(width: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: AppColors.crimsonRed.withValues(alpha: 0.2),
                        ),
                        child: Text(
                          '${t.$3}',
                          style: const TextStyle(
                            color: AppColors.crimsonRed,
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  OVERVIEW TAB
// ═══════════════════════════════════════════════════════════
class _OverviewTab extends ConsumerWidget {
  final FamilyHubState state;
  final VoidCallback onChatTap;
  const _OverviewTab({required this.state, required this.onChatTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = state.family!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // MOTD
          if (f.motd.isNotEmpty) ...[
            FamilyAnnouncementBanner(motd: f.motd, updatedAt: f.motdUpdatedAt),
            const SizedBox(height: 16),
          ],
          // XP Bar
          FamilyLevelProgressBar(
            level: f.level,
            currentXP: f.currentXP,
            xpToNextLevel: f.xpToNextLevel,
          ),
          const SizedBox(height: 16),
          // Stats grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.0,
            children: [
              FamilyStatCard(
                label: 'Members',
                value: '${f.memberCount}/${f.levelMaxMembers}',
                icon: Icons.people,
                color: AppColors.cyan,
              ),
              FamilyStatCard(
                label: 'Online',
                value: '${f.onlineCount}',
                icon: Icons.circle,
                color: AppColors.online,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Description
          if (f.description.isNotEmpty) ...[
            Text(
              'ABOUT',
              style: TextStyle(
                color: AppColors.white30,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(f.description, style: AppTextStyles.bodyMedium),
            const SizedBox(height: 16),
          ],
          // Quick actions
          Row(
            children: [
              _QuickAction(Icons.person_add, 'Invite', AppColors.cyan, () {
                _showInviteDialog(context, ref, state.family);
              }),
              const SizedBox(width: 8),
              _QuickAction(
                Icons.chat, 
                'Chat', 
                AppColors.purpleGlow, 
                onChatTap,
                hasAlert: state.hasUnreadChat,
              ),
              const SizedBox(width: 8),
              _QuickAction(Icons.visibility, 'Spectate', AppColors.gold, () {
                context.push('/family/spectate');
              }),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool hasAlert;
  const _QuickAction(this.icon, this.label, this.color, this.onTap, {this.hasAlert = false});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: color.withValues(alpha: 0.06),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(icon, color: color, size: 20),
                  if (hasAlert)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.crimsonRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  MEMBERS TAB
// ═══════════════════════════════════════════════════════════
class _MembersTab extends StatelessWidget {
  final FamilyHubState state;
  final WidgetRef ref;
  const _MembersTab({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    final members = List<FamilyMember>.from(state.family?.members ?? []);
    members.sort(
      (a, b) => a.role.hierarchyLevel.compareTo(b.role.hierarchyLevel),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MEMBERS (${members.length})',
            style: const TextStyle(
              color: AppColors.white30,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          ...members.map(
            (m) => FamilyMemberCard(
              member: m,
              onTap: () {
                final currentUserId = ref.read(authProvider).user?.id;
                final myMember = state.family?.members
                    .where((m) => m.userId == currentUserId)
                    .firstOrNull;
                final myRole = myMember?.role ?? FamilyRole.associate;

                MemberActionSheet.show(
                  context,
                  member: m,
                  myRole: myRole,
                  onPromote: () =>
                      ref.read(familyProvider.notifier).promoteMember(m.userId),
                  onDemote: () =>
                      ref.read(familyProvider.notifier).demoteMember(m.userId),
                  onKick: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppColors.surface,
                        title: const Text(
                          'Kick Member',
                          style: TextStyle(color: Colors.white),
                        ),
                        content: Text(
                          'Are you sure you want to kick ${m.username} from the family?',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: AppColors.cyan),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              'Kick',
                              style: TextStyle(color: AppColors.crimsonRed),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      ref.read(familyProvider.notifier).kickMember(m.userId);
                    }
                  },
                  onMute: () =>
                      ref.read(familyProvider.notifier).muteMember(m.userId),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  REQUESTS TAB
// ═══════════════════════════════════════════════════════════
class _RequestsTab extends StatelessWidget {
  final FamilyHubState state;
  final WidgetRef ref;
  const _RequestsTab({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    final apps = state.applications;

    if (apps.isEmpty) {
      return const Center(
        child: Text(
          'No pending applications',
          style: TextStyle(color: AppColors.white30),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PENDING APPLICATIONS (${apps.length})',
            style: const TextStyle(
              color: AppColors.white30,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          ...apps.map(
            (a) => FamilyInviteCard(
              application: a,
              onAccept: () =>
                  ref.read(familyProvider.notifier).acceptApplication(a.id),
              onReject: () =>
                  ref.read(familyProvider.notifier).rejectApplication(a.id),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  CHAT TAB (simplified inline — full screen available)
// ═══════════════════════════════════════════════════════════
class _ChatTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends ConsumerState<_ChatTab> {
  final _msgController = TextEditingController();
  final _focusNode = FocusNode();
  bool _showEmojiPicker = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _showEmojiPicker) {
        setState(() => _showEmojiPicker = false);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _msgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(familyProvider).chatMessages;
    final user = ref.watch(authProvider).user;

    return Column(
      children: [
        GestureDetector(
          onTap: () => context.push('/family/chat'),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              gradient: AppGradients.purpleNeonGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.purpleNeon.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.headset_mic, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'JOIN VOICE LOUNGE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              if (_showEmojiPicker) {
                setState(() => _showEmojiPicker = false);
              }
            },
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (_, i) {
                final msg = messages[messages.length - 1 - i];
                final isMe =
                    user != null &&
                    (msg.senderId == user.id ||
                        msg.senderName == user.username);
                if (msg.isSystem) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        msg.content,
                        style: const TextStyle(
                          color: AppColors.white30,
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  );
                }
                return Align(
                  alignment: isMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: isMe
                          ? AppColors.purpleNeon.withValues(alpha: 0.12)
                          : AppColors.glassBackground,
                      border: Border.all(
                        color: isMe
                            ? AppColors.purpleNeon.withValues(alpha: 0.3)
                            : AppColors.glassBorder,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isMe)
                          Text(
                            msg.senderName,
                            style: const TextStyle(
                              color: AppColors.cyan,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        Text(
                          msg.content,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            color: AppColors.white30,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        // Input bar
        Container(
          padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.glassBorder)),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  _showEmojiPicker
                      ? Icons.keyboard
                      : Icons.emoji_emotions_outlined,
                  color: AppColors.white70,
                ),
                onPressed: () {
                  if (!_showEmojiPicker) {
                    FocusScope.of(context).unfocus();
                  }
                  setState(() {
                    _showEmojiPicker = !_showEmojiPicker;
                  });
                },
              ),
              Expanded(
                child: TextField(
                  controller: _msgController,
                  focusNode: _focusNode,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(
                      color: AppColors.white30,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  if (_msgController.text.trim().isEmpty) return;
                  ref
                      .read(familyProvider.notifier)
                      .sendChatMessage(_msgController.text.trim());
                  _msgController.clear();
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppGradients.purpleNeonGradient,
                  ),
                  child: const Icon(Icons.send, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ),
        // No extra closing tags
        if (_showEmojiPicker)
          SizedBox(
            height: 250,
            child: EmojiPicker(
              textEditingController: _msgController,
              config: Config(
                bottomActionBarConfig: const BottomActionBarConfig(
                  showBackspaceButton: false,
                  showSearchViewButton: false,
                ),
                categoryViewConfig: const CategoryViewConfig(
                  backgroundColor: AppColors.background,
                  indicatorColor: AppColors.purpleNeon,
                  iconColorSelected: AppColors.purpleNeon,
                ),
                emojiViewConfig: EmojiViewConfig(
                  backgroundColor: AppColors.surface,
                  columns: 7,
                  emojiSizeMax: 28,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  TREASURY TAB
// ═══════════════════════════════════════════════════════════

/// ConsumerWidget so it watches familyProvider and rebuilds in real-time
/// whenever treasury state changes (boost activated, donation, WS event).
class _TreasuryTab extends ConsumerWidget {
  const _TreasuryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch directly — this widget always has the latest treasury state
    final state = ref.watch(familyProvider);
    final treasury = state.treasury;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TreasuryWidget(
            treasury: treasury,
            onDonate: () => _showDonateDialog(context, ref),
          ),
          const SizedBox(height: 20),
          Text(
            'AVAILABLE BOOSTS',
            style: const TextStyle(
              color: AppColors.white30,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          ...FamilyBoostType.values.map(
            (t) {
              final isActive = treasury.currentActiveBoosts.any((b) => b.type == t);
              return TreasuryBoostCard(
                type: t,
                treasuryBalance: treasury.balance,
                isActive: isActive,
                onActivate: isActive
                    ? null
                    : () async {
                        final ok = await ref
                            .read(familyProvider.notifier)
                            .activateBoost(t);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                ok
                                    ? '${t.displayName} activated for all members!'
                                    : 'Not enough treasury funds',
                              ),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: ok
                                  ? AppColors.gold.withValues(alpha: 0.9)
                                  : AppColors.crimsonRed.withValues(alpha: 0.9),
                            ),
                          );
                        }
                      },
              );
            },
          ),
        ],
      ),
    );
  }

  void _showDonateDialog(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController(text: '100');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('Donate to Treasury', style: AppTextStyles.headlineSmall),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Amount',
            hintStyle: TextStyle(color: AppColors.white30),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.white50),
            ),
          ),
          TextButton(
            onPressed: () {
              final amt = int.tryParse(ctrl.text) ?? 0;
              if (amt > 0) ref.read(familyProvider.notifier).donate(amt);
              Navigator.pop(context);
            },
            child: const Text(
              'DONATE',
              style: TextStyle(color: AppColors.gold),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  ACHIEVEMENTS TAB
// ═══════════════════════════════════════════════════════════
class _AchievementsTab extends StatelessWidget {
  final FamilyHubState state;
  const _AchievementsTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final unlocked = state.achievements.where((a) => a.isUnlocked).toList();
    final locked = state.achievements.where((a) => !a.isUnlocked).toList();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (unlocked.isNotEmpty) ...[
            Text(
              'UNLOCKED (${unlocked.length})',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            ...unlocked.map((a) => FamilyAchievementCard(achievement: a)),
            const SizedBox(height: 16),
          ],
          Text(
            'IN PROGRESS (${locked.length})',
            style: TextStyle(
              color: AppColors.white30,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          ...locked.map((a) => FamilyAchievementCard(achievement: a)),
        ],
      ),
    );
  }
}

void _showInviteDialog(
  BuildContext context,
  WidgetRef ref,
  FamilyModel? family,
) {
  if (family == null) return;
  // Trigger a load if it hasn't been loaded
  ref.read(friendsProvider.notifier).refresh();

  showDialog(
    context: context,
    builder: (ctx) {
      final Set<String> invitedFriends = {};
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text(
              'Invite Friends',
              style: TextStyle(color: Colors.white),
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: Consumer(
                builder: (context, ref, child) {
                  final friendsState = ref.watch(friendsProvider);
                  final friends = friendsState.allFriends;

                  if (friendsState.isLoading && friends.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.cyan),
                    );
                  }

                  if (friends.isEmpty) {
                    return const Center(
                      child: Text(
                        'No friends to invite.',
                        style: TextStyle(color: AppColors.white50),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: friends.length,
                    itemBuilder: (context, index) {
                      final friend = friends[index];
                      final isAlreadyInFamily = family.members.any(
                        (m) => m.userId == friend.id,
                      );
                      final isInvited = invitedFriends.contains(friend.id);

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.purpleNeon.withValues(
                            alpha: 0.2,
                          ),
                          child: const Icon(
                            Icons.person,
                            color: AppColors.purpleNeon,
                          ),
                        ),
                        title: Text(
                          friend.username,
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: isAlreadyInFamily
                            ? const Text(
                                'In Family',
                                style: TextStyle(
                                  color: AppColors.white50,
                                  fontSize: 12,
                                ),
                              )
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isInvited
                                      ? AppColors.white10
                                      : AppColors.cyan,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                ),
                                onPressed: isInvited
                                    ? () {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Request already pending',
                                            ),
                                            backgroundColor:
                                                AppColors.crimsonRed,
                                          ),
                                        );
                                      }
                                    : () {
                                        ref
                                            .read(familyProvider.notifier)
                                            .inviteFriendToFamily(friend.id);
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Invited ${friend.username} to family!',
                                            ),
                                            backgroundColor: AppColors.cyan,
                                          ),
                                        );
                                        setState(() {
                                          invitedFriends.add(friend.id);
                                        });
                                      },
                                child: Text(
                                  isInvited ? 'Pending' : 'Invite',
                                  style: TextStyle(
                                    color: isInvited
                                        ? AppColors.white50
                                        : Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      );
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Close',
                  style: TextStyle(color: AppColors.white50),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
