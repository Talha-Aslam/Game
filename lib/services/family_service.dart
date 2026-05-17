import 'dart:async';
import 'dart:math';
import '../models/family_model.dart';
import '../models/family/family_treasury_model.dart';
import '../models/family/family_war_model.dart';
import '../models/family/family_achievement_model.dart';
import '../models/family/family_application_model.dart';
import '../models/family/family_audit_log_model.dart';

/// Comprehensive mock family service
class FamilyService {
  final _rng = Random(42);
  FamilyModel? _currentFamily;
  final List<FamilyApplication> _applications = [];
  final List<FamilyAuditEntry> _auditLog = [];
  final List<FamilyWarModel> _wars = [];
  final List<RivalryRecord> _rivalries = [];
  late FamilyTreasury _treasury;
  List<FamilyAchievement> _achievements = [];
  final List<FamilyModel> _allFamilies = [];

  static const int creationCost = 500;

  FamilyService() {
    _currentFamily = _buildMockFamily();
    _treasury = _buildMockTreasury();
    _applications.addAll(_buildMockApplications());
    _auditLog.addAll(_buildMockAuditLog());
    _wars.addAll(_buildMockWars());
    _rivalries.addAll(_buildMockRivalries());
    _achievements = _buildMockAchievements();
    _allFamilies.addAll(_buildSearchableFamilies());
  }

  // ── Family CRUD ──
  Future<FamilyModel?> getCurrentFamily() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _currentFamily;
  }

  Future<FamilyModel> createFamily({
    required String name,
    required String tag,
    String description = '',
    String slogan = '',
    FamilyPrivacy privacy = FamilyPrivacy.approvalRequired,
    FamilyRequirements requirements = const FamilyRequirements(),
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentFamily = FamilyModel(
      id: 'fam_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      tag: '[$tag]',
      description: description,
      slogan: slogan,
      privacy: privacy,
      requirements: requirements,
      members: [
        FamilyMember(
          userId: 'local_user', username: 'You',
          role: FamilyRole.boss, activity: MemberActivity.online,
          rankTier: 2, winRate: 65.0, totalGames: 120,
          joinedAt: DateTime.now(), lastActive: DateTime.now(),
        ),
      ],
      createdAt: DateTime.now(),
      createdBy: 'local_user',
    );
    _addAudit(AuditAction.familyCreated, 'You');
    return _currentFamily!;
  }

  Future<void> leaveFamily() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentFamily = null;
  }

  Future<void> updateSettings({
    String? name, String? tag, String? description,
    String? slogan, String? motd, FamilyPrivacy? privacy,
    FamilyRequirements? requirements,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_currentFamily == null) return;
    _currentFamily = _currentFamily!.copyWith(
      name: name, tag: tag, description: description,
      slogan: slogan, motd: motd, privacy: privacy,
      requirements: requirements,
      motdUpdatedAt: motd != null ? DateTime.now() : null,
    );
    _addAudit(AuditAction.settingsChanged, 'You');
  }

  // ── Members ──
  Future<void> kickMember(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_currentFamily == null) return;
    final target = _currentFamily!.members.where((m) => m.userId == userId).firstOrNull;
    final members = _currentFamily!.members.where((m) => m.userId != userId).toList();
    _currentFamily = _currentFamily!.copyWith(members: members);
    _addAudit(AuditAction.memberKicked, 'You', targetName: target?.username);
  }

  Future<void> promoteMember(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_currentFamily == null) return;
    final members = _currentFamily!.members.map((m) {
      if (m.userId == userId) {
        final newRole = m.role == FamilyRole.associate
            ? FamilyRole.capo
            : m.role == FamilyRole.capo
                ? FamilyRole.underboss
                : m.role;
        return m.copyWith(role: newRole);
      }
      return m;
    }).toList();
    _currentFamily = _currentFamily!.copyWith(members: members);
    final target = members.where((m) => m.userId == userId).firstOrNull;
    _addAudit(AuditAction.memberPromoted, 'You', targetName: target?.username);
  }

  Future<void> demoteMember(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_currentFamily == null) return;
    final members = _currentFamily!.members.map((m) {
      if (m.userId == userId) {
        final newRole = m.role == FamilyRole.underboss
            ? FamilyRole.capo
            : m.role == FamilyRole.capo
                ? FamilyRole.associate
                : m.role;
        return m.copyWith(role: newRole);
      }
      return m;
    }).toList();
    _currentFamily = _currentFamily!.copyWith(members: members);
    final target = members.where((m) => m.userId == userId).firstOrNull;
    _addAudit(AuditAction.memberDemoted, 'You', targetName: target?.username);
  }

  Future<void> muteMember(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (_currentFamily == null) return;
    final members = _currentFamily!.members.map((m) {
      if (m.userId == userId) return m.copyWith(isMuted: !m.isMuted);
      return m;
    }).toList();
    _currentFamily = _currentFamily!.copyWith(members: members);
    _addAudit(AuditAction.memberMuted, 'You',
        targetName: members.where((m) => m.userId == userId).firstOrNull?.username);
  }

  Future<void> transferOwnership(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (_currentFamily == null) return;
    final members = _currentFamily!.members.map((m) {
      if (m.userId == userId) return m.copyWith(role: FamilyRole.boss);
      if (m.userId == 'local_user') return m.copyWith(role: FamilyRole.underboss);
      return m;
    }).toList();
    _currentFamily = _currentFamily!.copyWith(members: members);
    _addAudit(AuditAction.ownershipTransferred, 'You',
        targetName: members.where((m) => m.userId == userId).firstOrNull?.username);
  }

  // ── Applications ──
  Future<List<FamilyApplication>> getApplications() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _applications.where((a) => a.status == ApplicationStatus.pending).toList();
  }

  Future<void> acceptApplication(String appId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _applications.indexWhere((a) => a.id == appId);
    if (idx == -1 || _currentFamily == null) return;
    final app = _applications[idx];
    _applications[idx] = app.copyWith(
      status: ApplicationStatus.accepted,
      reviewedBy: 'local_user',
      reviewedAt: DateTime.now(),
    );
    final members = List<FamilyMember>.from(_currentFamily!.members);
    members.add(FamilyMember(
      userId: app.applicantId, username: app.applicantName,
      role: FamilyRole.associate, rankTier: app.rankTier,
      winRate: app.winRate, totalGames: app.totalGames,
      popularityScore: app.popularityScore,
      joinedAt: DateTime.now(), lastActive: DateTime.now(),
    ));
    _currentFamily = _currentFamily!.copyWith(members: members);
    _addAudit(AuditAction.memberJoined, app.applicantName);
  }

  Future<void> rejectApplication(String appId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _applications.indexWhere((a) => a.id == appId);
    if (idx != -1) {
      _applications[idx] = _applications[idx].copyWith(
        status: ApplicationStatus.rejected,
        reviewedBy: 'local_user',
        reviewedAt: DateTime.now(),
      );
    }
  }

  // ── Treasury ──
  Future<FamilyTreasury> getTreasury() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _treasury;
  }

  Future<void> donate(int amount) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final donations = List<TreasuryDonation>.from(_treasury.recentDonations);
    donations.insert(0, TreasuryDonation(
      id: 'don_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'local_user', username: 'You',
      amount: amount, timestamp: DateTime.now(),
    ));
    _treasury = _treasury.copyWith(
      balance: _treasury.balance + amount,
      recentDonations: donations,
    );
    if (_currentFamily != null) {
      _currentFamily = _currentFamily!.copyWith(
        treasuryBalance: _treasury.balance,
      );
    }
    _addAudit(AuditAction.treasuryDonation, 'You', details: '$amount');
  }

  Future<bool> activateBoost(FamilyBoostType type) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (_treasury.balance < type.cost) return false;
    final now = DateTime.now();
    final boosts = List<FamilyBoost>.from(_treasury.activeBoosts);
    boosts.add(FamilyBoost(
      id: 'boost_${now.millisecondsSinceEpoch}',
      type: type, activatedAt: now,
      expiresAt: now.add(type.duration),
      activatedBy: 'You',
    ));
    _treasury = _treasury.copyWith(
      balance: _treasury.balance - type.cost,
      activeBoosts: boosts,
    );
    _addAudit(AuditAction.boostActivated, 'You', details: type.displayName);
    return true;
  }

  // ── Wars ──
  Future<List<FamilyWarModel>> getWars() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_wars);
  }

  Future<List<RivalryRecord>> getRivalries() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_rivalries);
  }

  // ── Achievements ──
  Future<List<FamilyAchievement>> getAchievements() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_achievements);
  }

  // ── Audit Log ──
  Future<List<FamilyAuditEntry>> getAuditLog() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_auditLog);
  }

  // ── Search ──
  Future<List<FamilyModel>> searchFamilies(String query) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (query.trim().isEmpty) return _allFamilies;
    final lq = query.toLowerCase();
    return _allFamilies.where((f) =>
        f.name.toLowerCase().contains(lq) ||
        f.tag.toLowerCase().contains(lq)).toList();
  }

  // ── Helpers ──
  void _addAudit(AuditAction action, String actorName, {String? targetName, String? details}) {
    _auditLog.insert(0, FamilyAuditEntry(
      id: 'audit_${DateTime.now().millisecondsSinceEpoch}',
      action: action, actorId: 'local_user', actorName: actorName,
      targetName: targetName, details: details, timestamp: DateTime.now(),
    ));
  }

  // ══════════════════════════════════════════════════════════════
  //  MOCK DATA BUILDERS
  // ══════════════════════════════════════════════════════════════

  FamilyModel _buildMockFamily() {
    final now = DateTime.now();
    final activities = MemberActivity.values;
    final names = ['ShadowKing','NightViper','IronFist','GhostWalker','RedPhantom',
      'DarkOracle','SilverBlade','CrimsonEye','StormBringer','VenomStrike',
      'BladeRunner','NeonWraith','DeathWhisper','FrostBite','ThunderBolt'];
    final roles = [FamilyRole.boss, FamilyRole.underboss, FamilyRole.capo,
      FamilyRole.capo, FamilyRole.associate, FamilyRole.associate,
      FamilyRole.associate, FamilyRole.associate, FamilyRole.associate,
      FamilyRole.associate, FamilyRole.associate, FamilyRole.associate,
      FamilyRole.associate, FamilyRole.associate, FamilyRole.associate];

    return FamilyModel(
      id: 'family_001', name: 'Cobra Dynasty', tag: '[COBRA]',
      description: 'Strike fast, vanish faster. We rule the city from the shadows.',
      slogan: 'In shadows we trust.',
      privacy: FamilyPrivacy.approvalRequired,
      level: 8, currentXP: 7200, xpToNextLevel: 10000,
      totalWins: 456, totalLosses: 123, seasonPoints: 12500, globalRank: 42,
      treasuryBalance: 8500,
      motd: '🔥 Syndicate War tonight at 8 PM — all ranked grinders online!',
      motdUpdatedAt: now.subtract(const Duration(hours: 3)),
      warWins: 18, warLosses: 5,
      createdAt: now.subtract(const Duration(days: 90)),
      createdBy: 'u1',
      members: List.generate(names.length, (i) {
        final isOnline = _rng.nextDouble() < 0.45;
        return FamilyMember(
          userId: 'u${i + 1}', username: names[i],
          role: roles[i],
          contributedPoints: 3200 - (i * 180),
          activity: isOnline ? activities[_rng.nextInt(activities.length - 1)] : MemberActivity.offline,
          rankTier: (4 - i ~/ 4).clamp(0, 4),
          rankPoints: 2000 - (i * 100),
          winRate: 75.0 - (i * 2.5),
          totalGames: 500 - (i * 25),
          trustRating: 4.5 - (i * 0.15),
          popularityScore: 3000 - (i * 150),
          mostPlayedRole: ['Mafia','Detective','Doctor','Civilian'][i % 4],
          joinedAt: now.subtract(Duration(days: 90 - i * 5)),
          lastActive: isOnline ? now : now.subtract(Duration(hours: i * 2)),
        );
      }),
    );
  }

  FamilyTreasury _buildMockTreasury() {
    return FamilyTreasury(
      balance: 8500,
      activeBoosts: [
        FamilyBoost(id: 'b1', type: FamilyBoostType.influenceBonus,
          activatedAt: DateTime.now().subtract(const Duration(hours: 6)),
          expiresAt: DateTime.now().add(const Duration(hours: 18)),
          activatedBy: 'ShadowKing'),
      ],
      topContributors: const [
        TreasuryContributor(userId: 'u1', username: 'ShadowKing', totalDonated: 3200),
        TreasuryContributor(userId: 'u2', username: 'NightViper', totalDonated: 2800),
        TreasuryContributor(userId: 'u3', username: 'IronFist', totalDonated: 1900),
        TreasuryContributor(userId: 'u4', username: 'GhostWalker', totalDonated: 1500),
        TreasuryContributor(userId: 'u5', username: 'RedPhantom', totalDonated: 800),
      ],
    );
  }

  List<FamilyApplication> _buildMockApplications() => [
    FamilyApplication(id: 'app_1', applicantId: 'ap1', applicantName: 'ZeroGravity',
      familyId: 'family_001', rankTier: 3, rankPoints: 1800,
      winRate: 68.5, totalGames: 200, trustRating: 4.2,
      popularityScore: 1500, mostPlayedRole: 'Detective',
      submittedAt: DateTime.now().subtract(const Duration(hours: 2))),
    FamilyApplication(id: 'app_2', applicantId: 'ap2', applicantName: 'SteelNerve',
      familyId: 'family_001', rankTier: 2, rankPoints: 1200,
      winRate: 55.0, totalGames: 80, trustRating: 3.8,
      popularityScore: 800, mostPlayedRole: 'Mafia',
      previousFamilyName: 'Night Syndicate',
      submittedAt: DateTime.now().subtract(const Duration(hours: 5))),
  ];

  List<FamilyAuditEntry> _buildMockAuditLog() {
    final now = DateTime.now();
    return [
      FamilyAuditEntry(id: 'a1', action: AuditAction.motdUpdated,
        actorId: 'u1', actorName: 'ShadowKing', timestamp: now.subtract(const Duration(hours: 3))),
      FamilyAuditEntry(id: 'a2', action: AuditAction.boostActivated,
        actorId: 'u1', actorName: 'ShadowKing', details: '+10% Influence Earned',
        timestamp: now.subtract(const Duration(hours: 6))),
      FamilyAuditEntry(id: 'a3', action: AuditAction.memberJoined,
        actorId: 'u15', actorName: 'ThunderBolt', timestamp: now.subtract(const Duration(days: 1))),
      FamilyAuditEntry(id: 'a4', action: AuditAction.memberPromoted,
        actorId: 'u1', actorName: 'ShadowKing', targetName: 'NightViper',
        timestamp: now.subtract(const Duration(days: 2))),
      FamilyAuditEntry(id: 'a5', action: AuditAction.warCompleted,
        actorId: 'system', actorName: 'System', targetName: 'Night Syndicate',
        timestamp: now.subtract(const Duration(days: 3))),
    ];
  }

  List<FamilyWarModel> _buildMockWars() {
    final now = DateTime.now();
    return [
      FamilyWarModel(id: 'war_1',
        challengerFamilyId: 'family_001', challengerFamilyName: 'Cobra Dynasty', challengerFamilyTag: '[COBRA]',
        defenderFamilyId: 'family_002', defenderFamilyName: 'Night Syndicate', defenderFamilyTag: '[NIGHT]',
        challengerScore: 4, defenderScore: 2, status: WarStatus.completed,
        createdAt: now.subtract(const Duration(days: 3)),
        completedAt: now.subtract(const Duration(days: 3))),
      FamilyWarModel(id: 'war_2',
        challengerFamilyId: 'family_003', challengerFamilyName: 'Ghost Protocol', challengerFamilyTag: '[GHOST]',
        defenderFamilyId: 'family_001', defenderFamilyName: 'Cobra Dynasty', defenderFamilyTag: '[COBRA]',
        status: WarStatus.pending,
        createdAt: now.subtract(const Duration(hours: 2))),
    ];
  }

  List<RivalryRecord> _buildMockRivalries() => [
    RivalryRecord(rivalFamilyId: 'family_002', rivalFamilyName: 'Night Syndicate',
      rivalFamilyTag: '[NIGHT]', wins: 12, losses: 5,
      lastMatchDate: DateTime.now().subtract(const Duration(days: 3))),
    RivalryRecord(rivalFamilyId: 'family_003', rivalFamilyName: 'Ghost Protocol',
      rivalFamilyTag: '[GHOST]', wins: 4, losses: 3,
      lastMatchDate: DateTime.now().subtract(const Duration(days: 10))),
  ];

  List<FamilyAchievement> _buildMockAchievements() {
    return FamilyAchievement.allAchievements.map((a) {
      int progress;
      switch (a.id) {
        case 'fam_wins_10': progress = 10;
        case 'fam_wins_100': progress = 82;
        case 'fam_wins_500': progress = 456;
        case 'fam_wars_won_25': progress = 18;
        case 'fam_level_10': progress = 8;
        default: progress = _rng.nextInt(a.target);
      }
      return FamilyAchievement(
        id: a.id, title: a.title, description: a.description,
        icon: a.icon, currentProgress: progress, target: a.target,
        isUnlocked: progress >= a.target, rewardDescription: a.rewardDescription,
      );
    }).toList();
  }

  List<FamilyModel> _buildSearchableFamilies() {
    final now = DateTime.now();
    return [
      FamilyModel(id: 'family_002', name: 'Night Syndicate', tag: '[NIGHT]',
        description: 'We own the night.', privacy: FamilyPrivacy.approvalRequired,
        level: 12, totalWins: 380, seasonPoints: 10800, globalRank: 58,
        createdAt: now.subtract(const Duration(days: 120))),
      FamilyModel(id: 'family_003', name: 'Ghost Protocol', tag: '[GHOST]',
        description: 'Invisible, untouchable.', privacy: FamilyPrivacy.public,
        level: 6, totalWins: 210, seasonPoints: 7500, globalRank: 95,
        createdAt: now.subtract(const Duration(days: 60))),
      FamilyModel(id: 'family_004', name: 'Crimson Blade', tag: '[BLADE]',
        description: 'Blood and honor.', privacy: FamilyPrivacy.inviteOnly,
        level: 15, totalWins: 620, seasonPoints: 18000, globalRank: 12,
        createdAt: now.subtract(const Duration(days: 200))),
      FamilyModel(id: 'family_005', name: 'Neon Vipers', tag: '[NEON]',
        description: 'Electric precision.', privacy: FamilyPrivacy.public,
        level: 4, totalWins: 95, seasonPoints: 3200, globalRank: 180,
        createdAt: now.subtract(const Duration(days: 30))),
    ];
  }
}
