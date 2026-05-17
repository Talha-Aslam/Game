import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/family/family_war_model.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../providers/family_provider.dart';
import '../../../models/family_model.dart';
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
import '../widgets/war_lobby_card.dart';
import '../widgets/rivalry_history_card.dart';
import '../widgets/family_achievement_card.dart';
import '../../../models/family/family_treasury_model.dart';

class FamilyScreen extends ConsumerStatefulWidget {
  const FamilyScreen({super.key});
  @override
  ConsumerState<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends ConsumerState<FamilyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(familyProvider);

    if (state.isLoading) {
      return Scaffold(body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.backgroundGradient),
        child: const Center(child: CircularProgressIndicator(color: AppColors.purpleNeon))));
    }

    if (!state.hasFamily) return _buildNoFamilyView();
    return _buildHubView(state);
  }

  Widget _buildNoFamilyView() {
    return Scaffold(body: Stack(children: [
      Container(decoration: const BoxDecoration(gradient: AppGradients.backgroundGradient)),
      const ParticleField(particleCount: 15),
      SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: Column(
        children: [
          Row(children: [
            GestureDetector(onTap: () => context.pop(),
              child: const Icon(Icons.arrow_back, color: AppColors.white70)),
            const SizedBox(width: 16),
            Text('Family', style: AppTextStyles.headlineMedium),
          ]),
          const Spacer(),
          Icon(Icons.groups, color: AppColors.purpleNeon.withValues(alpha: 0.3), size: 80),
          const SizedBox(height: 20),
          Text('No Family Yet', style: AppTextStyles.headlineLarge),
          const SizedBox(height: 8),
          Text('Create or join a Family to unlock social features',
            style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: 32),
          // Create
          GestureDetector(
            onTap: () => context.push('/family/create'),
            child: Container(width: double.infinity, height: 50, decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: AppGradients.purpleNeonGradient),
              child: const Center(child: Text('CREATE FAMILY  (500 coins)',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14, letterSpacing: 1)))),
          ),
          const SizedBox(height: 12),
          // Search
          GestureDetector(
            onTap: () => context.push('/family/search'),
            child: Container(width: double.infinity, height: 50, decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14), color: AppColors.white05,
              border: Border.all(color: AppColors.cyan.withValues(alpha: 0.3))),
              child: const Center(child: Text('SEARCH FAMILIES',
                style: TextStyle(color: AppColors.cyan, fontWeight: FontWeight.w700, fontSize: 14, letterSpacing: 1)))),
          ),
          const Spacer(),
        ],
      ))),
    ]));
  }

  Widget _buildHubView(FamilyHubState state) {
    final family = state.family!;
    return Scaffold(body: Stack(children: [
      Container(decoration: const BoxDecoration(gradient: AppGradients.backgroundGradient)),
      const ParticleField(particleCount: 15),
      SafeArea(child: Column(children: [
        // Top bar
        Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0), child: Row(children: [
          GestureDetector(onTap: () => context.pop(), child: Container(
            padding: const EdgeInsets.all(8), decoration: BoxDecoration(
              shape: BoxShape.circle, color: AppColors.white05,
              border: Border.all(color: AppColors.glassBorder)),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20))),
          const SizedBox(width: 12),
          FamilyCrestWidget(themeColor: family.themeColor, level: family.level, size: 36),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(family.name, style: AppTextStyles.headlineSmall, overflow: TextOverflow.ellipsis),
            Text(family.tag, style: TextStyle(color: family.themeColor, fontSize: 11, fontWeight: FontWeight.w600)),
          ])),
          // Settings (Boss/Underboss)
          GestureDetector(onTap: () => context.push('/family/settings'), child: Container(
            padding: const EdgeInsets.all(8), decoration: BoxDecoration(
              shape: BoxShape.circle, color: AppColors.white05,
              border: Border.all(color: AppColors.glassBorder)),
            child: const Icon(Icons.settings, color: AppColors.white70, size: 18))),
        ])),
        const SizedBox(height: 12),
        // Tab bar
        _buildTabBar(state),
        Expanded(child: TabBarView(controller: _tabController, children: [
          _OverviewTab(state: state),
          _MembersTab(state: state, ref: ref),
          _ChatTab(),
          _TreasuryTab(state: state, ref: ref),
          _WarsTab(state: state),
          _AchievementsTab(state: state),
        ])),
      ])),
    ]));
  }

  Widget _buildTabBar(FamilyHubState state) {
    final tabs = [
      ('Overview', Icons.dashboard, null),
      ('Members', Icons.people, state.family?.memberCount),
      ('Chat', Icons.chat, null),
      ('Treasury', Icons.account_balance, null),
      ('Wars', Icons.whatshot, state.wars.where((w) => w.status == WarStatus.pending).length),
      ('Achieve', Icons.emoji_events, null),
    ];
    return Container(
      height: 42, margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),
        color: AppColors.white05, border: Border.all(color: AppColors.glassBorder)),
      child: TabBar(
        controller: _tabController, isScrollable: true,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(borderRadius: BorderRadius.circular(12),
          color: AppColors.purpleNeon.withValues(alpha: 0.2),
          border: Border.all(color: AppColors.purpleNeon.withValues(alpha: 0.4))),
        dividerColor: Colors.transparent,
        labelColor: AppColors.purpleGlow, unselectedLabelColor: AppColors.white30,
        labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
        tabAlignment: TabAlignment.start, padding: const EdgeInsets.all(3),
        tabs: tabs.map((t) => Tab(height: 34, child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(t.$2, size: 13), const SizedBox(width: 4), Text(t.$1),
          if (t.$3 != null && (t.$3 as int) > 0) ...[const SizedBox(width: 3), Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(6),
              color: AppColors.crimsonRed.withValues(alpha: 0.2)),
            child: Text('${t.$3}', style: const TextStyle(
              color: AppColors.crimsonRed, fontSize: 8, fontWeight: FontWeight.w700)))],
        ]))).toList(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  OVERVIEW TAB
// ═══════════════════════════════════════════════════════════
class _OverviewTab extends StatelessWidget {
  final FamilyHubState state;
  const _OverviewTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final f = state.family!;
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        // MOTD
        if (f.motd.isNotEmpty) ...[
          FamilyAnnouncementBanner(motd: f.motd, updatedAt: f.motdUpdatedAt),
          const SizedBox(height: 16),
        ],
        // XP Bar
        FamilyLevelProgressBar(level: f.level, currentXP: f.currentXP, xpToNextLevel: f.xpToNextLevel),
        const SizedBox(height: 16),
        // Stats grid
        GridView.count(crossAxisCount: 3, shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.2, children: [
            FamilyStatCard(label: 'Members', value: '${f.memberCount}/${f.levelMaxMembers}',
              icon: Icons.people, color: AppColors.cyan),
            FamilyStatCard(label: 'Online', value: '${f.onlineCount}',
              icon: Icons.circle, color: AppColors.online),
            FamilyStatCard(label: 'Wins', value: '${f.totalWins}',
              icon: Icons.emoji_events, color: AppColors.gold),
            FamilyStatCard(label: 'Win Rate', value: '${f.winRate.toStringAsFixed(1)}%',
              icon: Icons.trending_up, color: AppColors.mintGreen),
            FamilyStatCard(label: 'Wars Won', value: '${f.warWins}',
              icon: Icons.whatshot, color: AppColors.crimsonRed),
            FamilyStatCard(label: 'Rank', value: '#${f.globalRank}',
              icon: Icons.leaderboard, color: AppColors.purpleGlow),
          ]),
        const SizedBox(height: 20),
        // Description
        if (f.description.isNotEmpty) ...[
          Text('ABOUT', style: TextStyle(color: AppColors.white30, fontSize: 10,
            fontWeight: FontWeight.w700, letterSpacing: 1.5)),
          const SizedBox(height: 6),
          Text(f.description, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 16),
        ],
        // Quick actions
        Row(children: [
          _QuickAction(Icons.person_add, 'Invite', AppColors.cyan, () {}),
          const SizedBox(width: 8),
          _QuickAction(Icons.chat, 'Chat', AppColors.purpleGlow,
            () => DefaultTabController.of(context)),
          const SizedBox(width: 8),
          _QuickAction(Icons.visibility, 'Spectate', AppColors.gold, () {}),
        ]),
      ],
    ));
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon; final String label; final Color color; final VoidCallback onTap;
  const _QuickAction(this.icon, this.label, this.color, this.onTap);
  @override
  Widget build(BuildContext context) {
    return Expanded(child: GestureDetector(onTap: onTap, child: Container(
      padding: const EdgeInsets.all(12), decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12), color: color.withValues(alpha: 0.06),
        border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Column(children: [
        Icon(icon, color: color, size: 20), const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
      ]),
    )));
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
    members.sort((a, b) => a.role.hierarchyLevel.compareTo(b.role.hierarchyLevel));
    final apps = state.applications;
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (apps.isNotEmpty) ...[
          Text('PENDING APPLICATIONS (${apps.length})', style: const TextStyle(
            color: AppColors.white30, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          ...apps.map((a) => FamilyInviteCard(application: a,
            onAccept: () => ref.read(familyProvider.notifier).acceptApplication(a.id),
            onReject: () => ref.read(familyProvider.notifier).rejectApplication(a.id))),
          const SizedBox(height: 16),
        ],
        Text('MEMBERS (${members.length})', style: const TextStyle(
          color: AppColors.white30, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        ...members.map((m) => FamilyMemberCard(member: m, onTap: () {
          MemberActionSheet.show(context, member: m, myRole: FamilyRole.boss,
            onPromote: () => ref.read(familyProvider.notifier).promoteMember(m.userId),
            onDemote: () => ref.read(familyProvider.notifier).demoteMember(m.userId),
            onKick: () => ref.read(familyProvider.notifier).kickMember(m.userId),
            onMute: () => ref.read(familyProvider.notifier).muteMember(m.userId));
        })),
      ],
    ));
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

  @override
  void dispose() { _msgController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(familyProvider).chatMessages;
    return Column(children: [
      Expanded(child: ListView.builder(
        reverse: true, padding: const EdgeInsets.all(16),
        itemCount: messages.length,
        itemBuilder: (_, i) {
          final msg = messages[messages.length - 1 - i];
          final isMe = msg.senderId == 'local_user';
          if (msg.isSystem) return Center(child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(msg.content, style: const TextStyle(
              color: AppColors.white30, fontSize: 10, fontStyle: FontStyle.italic))));
          return Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: isMe ? AppColors.purpleNeon.withValues(alpha: 0.12) : AppColors.glassBackground,
                border: Border.all(color: isMe ? AppColors.purpleNeon.withValues(alpha: 0.3) : AppColors.glassBorder)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (!isMe) Text(msg.senderName, style: const TextStyle(
                  color: AppColors.cyan, fontSize: 10, fontWeight: FontWeight.w600)),
                Text(msg.content, style: const TextStyle(color: Colors.white, fontSize: 13)),
                const SizedBox(height: 2),
                Text('${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(color: AppColors.white30, fontSize: 9)),
              ]),
            ),
          );
        },
      )),
      // Input bar
      Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        decoration: BoxDecoration(color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.glassBorder))),
        child: Row(children: [
          Expanded(child: TextField(controller: _msgController,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(hintText: 'Type a message...',
              hintStyle: TextStyle(color: AppColors.white30, fontSize: 14),
              border: InputBorder.none))),
          GestureDetector(
            onTap: () {
              if (_msgController.text.trim().isEmpty) return;
              ref.read(familyProvider.notifier).sendChatMessage(_msgController.text.trim());
              _msgController.clear();
            },
            child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(
              shape: BoxShape.circle, gradient: AppGradients.purpleNeonGradient),
              child: const Icon(Icons.send, color: Colors.white, size: 18)),
          ),
        ]),
      ),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════
//  TREASURY TAB
// ═══════════════════════════════════════════════════════════
class _TreasuryTab extends StatelessWidget {
  final FamilyHubState state;
  final WidgetRef ref;
  const _TreasuryTab({required this.state, required this.ref});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        TreasuryWidget(treasury: state.treasury, onDonate: () => _showDonateDialog(context)),
        const SizedBox(height: 20),
        Text('AVAILABLE BOOSTS', style: TextStyle(color: AppColors.white30, fontSize: 10,
          fontWeight: FontWeight.w700, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        ...FamilyBoostType.values.map((t) => TreasuryBoostCard(
          type: t, treasuryBalance: state.treasury.balance,
          onActivate: () async {
            final ok = await ref.read(familyProvider.notifier).activateBoost(t);
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(ok ? '${t.displayName} activated!' : 'Not enough funds'),
              behavior: SnackBarBehavior.floating));
          },
        )),
      ],
    ));
  }

  void _showDonateDialog(BuildContext context) {
    final ctrl = TextEditingController(text: '100');
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text('Donate to Treasury', style: AppTextStyles.headlineSmall),
      content: TextField(controller: ctrl, keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(hintText: 'Amount', hintStyle: TextStyle(color: AppColors.white30))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppColors.white50))),
        TextButton(onPressed: () {
          final amt = int.tryParse(ctrl.text) ?? 0;
          if (amt > 0) ref.read(familyProvider.notifier).donate(amt);
          Navigator.pop(context);
        }, child: const Text('DONATE', style: TextStyle(color: AppColors.gold))),
      ],
    ));
  }
}

// ═══════════════════════════════════════════════════════════
//  WARS TAB
// ═══════════════════════════════════════════════════════════
class _WarsTab extends StatelessWidget {
  final FamilyHubState state;
  const _WarsTab({required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (state.wars.isNotEmpty) ...[
          Text('SYNDICATE WARS', style: TextStyle(color: AppColors.white30, fontSize: 10,
            fontWeight: FontWeight.w700, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          ...state.wars.map((w) => WarLobbyCard(war: w)),
        ],
        if (state.rivalries.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('RIVALRIES', style: TextStyle(color: AppColors.white30, fontSize: 10,
            fontWeight: FontWeight.w700, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          ...state.rivalries.map((r) => RivalryHistoryCard(rivalry: r)),
        ],
      ],
    ));
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
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (unlocked.isNotEmpty) ...[
          Text('UNLOCKED (${unlocked.length})', style: TextStyle(color: AppColors.gold, fontSize: 10,
            fontWeight: FontWeight.w700, letterSpacing: 1.5)),
          const SizedBox(height: 8),
          ...unlocked.map((a) => FamilyAchievementCard(achievement: a)),
          const SizedBox(height: 16),
        ],
        Text('IN PROGRESS (${locked.length})', style: TextStyle(color: AppColors.white30, fontSize: 10,
          fontWeight: FontWeight.w700, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        ...locked.map((a) => FamilyAchievementCard(achievement: a)),
      ],
    ));
  }
}
