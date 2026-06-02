import 'dart:async';
import '../models/family_model.dart';
import '../models/family/family_treasury_model.dart';
import '../models/family/family_war_model.dart';
import '../models/family/family_achievement_model.dart';
import '../models/family/family_application_model.dart';
import '../models/family/family_audit_log_model.dart';
import 'family_api_service.dart';

/// Family service backed by FastAPI
class FamilyService {
  final FamilyApiService _api = FamilyApiService();

  static const int creationCost = 500;

  // ── Family CRUD ──

  Future<FamilyModel?> getCurrentFamily() async {
    try {
      final data = await _api.getMyFamily();
      if (data == null) return null;
      return _familyFromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<FamilyModel> createFamily({
    required String name,
    required String tag,
    String description = '',
    String slogan = '',
    FamilyPrivacy privacy = FamilyPrivacy.approvalRequired,
    FamilyRequirements requirements = const FamilyRequirements(),
  }) async {
    final data = await _api.createFamily(
      name: name,
      tag: tag,
      description: description,
      slogan: slogan,
      privacy: _privacyToString(privacy),
    );
    return _familyFromJson(data);
  }

  Future<void> leaveFamily() async {
    await _api.leaveFamily();
  }

  Future<void> deleteFamily() async {
    await _api.deleteFamily();
  }

  Future<void> updateSettings({
    String? name,
    String? tag,
    String? description,
    String? slogan,
    String? motd,
    FamilyPrivacy? privacy,
    FamilyRequirements? requirements,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (tag != null) updates['tag'] = tag;
    if (description != null) updates['description'] = description;
    if (slogan != null) updates['slogan'] = slogan;
    if (motd != null) updates['motd'] = motd;
    if (privacy != null) updates['privacy'] = _privacyToString(privacy);
    await _api.updateSettings(updates);
  }

  // ── Members ──

  Future<void> kickMember(String userId) async {
    await _api.kickMember(userId);
  }

  Future<void> promoteMember(String userId) async {
    await _api.promoteMember(userId);
  }

  Future<void> demoteMember(String userId) async {
    await _api.demoteMember(userId);
  }

  Future<void> muteMember(String userId) async {
    await _api.muteMember(userId);
  }

  Future<void> transferOwnership(String userId) async {
    await _api.transferOwnership(userId);
  }

  // ── Applications ──

  Future<List<FamilyApplication>> getApplications() async {
    try {
      final data = await _api.getMyFamily();
      if (data == null) return [];
      final apps = List<Map<String, dynamic>>.from(data['applications'] ?? []);
      return apps
          .where((a) => a['status'] == 'pending')
          .map((a) => _applicationFromJson(a))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> acceptApplication(String appId) async {
    await _api.acceptApplication(appId);
  }

  Future<void> rejectApplication(String appId) async {
    await _api.rejectApplication(appId);
  }

  Future<void> applyToFamily(String familyId, {String message = '', bool isInvite = false}) async {
    await _api.applyToFamily(familyId, message: message, isInvite: isInvite);
  }

  // ── Treasury ──

  Future<FamilyTreasury> getTreasury() async {
    try {
      final data = await _api.getMyFamily();
      if (data == null) return const FamilyTreasury();
      final treasury = data['treasury'] ?? {};
      return _treasuryFromJson(Map<String, dynamic>.from(treasury));
    } catch (_) {
      return const FamilyTreasury();
    }
  }

  Future<void> donate(int amount) async {
    await _api.donate(amount);
  }

  Future<bool> activateBoost(FamilyBoostType type) async {
    try {
      await _api.activateBoost(type.name);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Wars ──

  Future<List<FamilyWarModel>> getWars() async {
    try {
      final data = await _api.getMyFamily();
      if (data == null) return [];
      final wars = List<Map<String, dynamic>>.from(data['wars'] ?? []);
      return wars.map((w) => _warFromJson(w)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<RivalryRecord>> getRivalries() async {
    try {
      final data = await _api.getRivalries();
      return data.map((r) => _rivalryFromJson(r)).toList();
    } catch (_) {
      return [];
    }
  }

  // ── Achievements ──

  Future<List<FamilyAchievement>> getAchievements() async {
    try {
      final data = await _api.getAchievements();
      if (data.isEmpty) return FamilyAchievement.allAchievements; // Fallback
      return data.map((a) => FamilyAchievement(
        id: a['id'] ?? '',
        title: a['title'] ?? '',
        description: a['description'] ?? '',
        target: a['required_value'] ?? a['target'] ?? 1,
        currentProgress: a['current_value'] ?? a['current_progress'] ?? 0,
        isUnlocked: a['is_unlocked'] ?? false,
      )).toList();
    } catch (_) {
      return FamilyAchievement.allAchievements;
    }
  }

  // ── Audit Log ──

  Future<List<FamilyAuditEntry>> getAuditLog() async {
    try {
      final data = await _api.getMyFamily();
      if (data == null) return [];
      final log = List<Map<String, dynamic>>.from(data['audit_log'] ?? []);
      return log.map((e) => _auditFromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  // ── Search ──

  Future<List<FamilyModel>> searchFamilies(String query) async {
    try {
      final data = await _api.searchFamilies(query);
      return data.map((j) => _familyFromJson(j)).toList();
    } catch (_) {
      return [];
    }
  }

  // ══════════════════════════════════════════════════════
  //  JSON → MODEL CONVERTERS
  // ══════════════════════════════════════════════════════

  FamilyModel _familyFromJson(Map<String, dynamic> json) {
    final membersRaw = List<Map<String, dynamic>>.from(json['members'] ?? []);
    return FamilyModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      tag: json['tag'] ?? '',
      description: json['description'] ?? '',
      slogan: json['slogan'] ?? '',
      privacy: _parsePrivacy(json['privacy'] ?? 'approvalRequired'),
      level: json['level'] ?? 1,
      currentXP: json['current_xp'] ?? 0,
      xpToNextLevel: json['xp_to_next_level'] ?? 1000,
      totalWins: json['total_wins'] ?? 0,
      totalLosses: json['total_losses'] ?? 0,
      seasonPoints: json['season_points'] ?? 0,
      globalRank: json['global_rank'] ?? 0,
      treasuryBalance: (json['treasury'] is Map)
          ? (json['treasury']['balance'] ?? 0)
          : (json['treasury_balance'] ?? 0),
      motd: json['motd'] ?? '',
      motdUpdatedAt: json['motd_updated_at'] != null
          ? DateTime.tryParse(json['motd_updated_at'])
          : null,
      warWins: json['war_wins'] ?? 0,
      warLosses: json['war_losses'] ?? 0,
      members: membersRaw.map((m) => _memberFromJson(m)).toList(),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      createdBy: json['created_by'] ?? '',
    );
  }

  FamilyMember _memberFromJson(Map<String, dynamic> json) {
    return FamilyMember(
      userId: json['user_id'] ?? '',
      username: json['username'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
      role: _parseRole(json['role'] ?? 'associate'),
      contributedPoints: json['contributed_points'] ?? 0,
      activity: _parseActivity(json['activity'] ?? 'offline'),
      rankTier: json['rank_tier'] ?? 0,
      rankPoints: json['rank_points'] ?? 0,
      winRate: (json['win_rate'] ?? 0).toDouble(),
      totalGames: json['total_games'] ?? 0,
      trustRating: (json['trust_rating'] ?? 5.0).toDouble(),
      popularityScore: json['popularity_score'] ?? 0,
      mostPlayedRole: json['most_played_role'],
      joinedAt: DateTime.tryParse(json['joined_at'] ?? '') ?? DateTime.now(),
      lastActive:
          DateTime.tryParse(json['last_active'] ?? '') ?? DateTime.now(),
      isMuted: json['is_muted'] ?? false,
    );
  }

  FamilyTreasury _treasuryFromJson(Map<String, dynamic> json) {
    final donations = List<Map<String, dynamic>>.from(
      json['recent_donations'] ?? [],
    );
    final boosts = List<Map<String, dynamic>>.from(
      json['active_boosts'] ?? [],
    );
    return FamilyTreasury(
      balance: json['balance'] ?? 0,
      activeBoosts: boosts.map((b) => _boostFromJson(b)).toList(),
      recentDonations: donations
          .map(
            (d) => TreasuryDonation(
              id: d['id'] ?? '',
              userId: d['user_id'] ?? '',
              username: d['username'] ?? '',
              amount: d['amount'] ?? 0,
              timestamp:
                  DateTime.tryParse(d['timestamp'] ?? '') ?? DateTime.now(),
            ),
          )
          .toList(),
    );
  }

  FamilyBoost _boostFromJson(Map<String, dynamic> json) {
    return FamilyBoost(
      id: json['id'] ?? '',
      type: FamilyBoostType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => FamilyBoostType.influenceBonus,
      ),
      activatedAt:
          DateTime.tryParse(json['activated_at'] ?? '') ?? DateTime.now(),
      expiresAt: DateTime.tryParse(json['expires_at'] ?? '') ?? DateTime.now(),
      activatedBy: json['activated_by'] ?? '',
    );
  }

  FamilyApplication _applicationFromJson(Map<String, dynamic> json) {
    return FamilyApplication(
      id: json['id'] ?? '',
      applicantId: json['applicant_id'] ?? '',
      applicantName: json['applicant_name'] ?? '',
      familyId: json['family_id'] ?? '',
      rankTier: json['rank_tier'] ?? 0,
      rankPoints: json['rank_points'] ?? 0,
      winRate: (json['win_rate'] ?? 0).toDouble(),
      totalGames: json['total_games'] ?? 0,
      trustRating: (json['trust_rating'] ?? 5.0).toDouble(),
      popularityScore: json['popularity_score'] ?? 0,
      mostPlayedRole: json['most_played_role'],
      submittedAt:
          DateTime.tryParse(json['submitted_at'] ?? '') ?? DateTime.now(),
    );
  }

  FamilyWarModel _warFromJson(Map<String, dynamic> json) {
    return FamilyWarModel(
      id: json['id'] ?? '',
      challengerFamilyId: json['challenger_family_id'] ?? '',
      challengerFamilyName: json['challenger_family_name'] ?? '',
      challengerFamilyTag: json['challenger_family_tag'] ?? '',
      defenderFamilyId: json['defender_family_id'] ?? '',
      defenderFamilyName: json['defender_family_name'] ?? '',
      defenderFamilyTag: json['defender_family_tag'] ?? '',
      challengerScore: json['challenger_score'] ?? 0,
      defenderScore: json['defender_score'] ?? 0,
      status: _parseWarStatus(json['status'] ?? 'pending'),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  RivalryRecord _rivalryFromJson(Map<String, dynamic> json) {
    return RivalryRecord(
      rivalFamilyId: json['rival_family_id'] ?? '',
      rivalFamilyName: json['rival_family_name'] ?? '',
      rivalFamilyTag: json['rival_family_tag'] ?? '',
      wins: json['wars_won'] ?? json['wins'] ?? 0,
      losses: json['wars_lost'] ?? json['losses'] ?? 0,
      lastMatchDate:
          DateTime.tryParse(
            json['last_match_date'] ?? json['started_at'] ?? '',
          ) ??
          DateTime.now(),
    );
  }

  FamilyAuditEntry _auditFromJson(Map<String, dynamic> json) {
    return FamilyAuditEntry(
      id: json['id'] ?? '',
      action: _parseAuditAction(json['action'] ?? ''),
      actorId: json['actor_id'] ?? '',
      actorName: json['actor_name'] ?? '',
      targetName: json['target_name'],
      details: json['details'],
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  // ── Enum Parsers ──

  String _privacyToString(FamilyPrivacy p) {
    switch (p) {
      case FamilyPrivacy.public:
        return 'public';
      case FamilyPrivacy.approvalRequired:
        return 'approvalRequired';
      case FamilyPrivacy.inviteOnly:
        return 'inviteOnly';
    }
  }

  FamilyPrivacy _parsePrivacy(String s) {
    switch (s) {
      case 'public':
        return FamilyPrivacy.public;
      case 'inviteOnly':
        return FamilyPrivacy.inviteOnly;
      default:
        return FamilyPrivacy.approvalRequired;
    }
  }

  FamilyRole _parseRole(String s) {
    switch (s) {
      case 'boss':
        return FamilyRole.boss;
      case 'underboss':
        return FamilyRole.underboss;
      case 'capo':
        return FamilyRole.capo;
      default:
        return FamilyRole.associate;
    }
  }

  MemberActivity _parseActivity(String s) {
    switch (s) {
      case 'online':
        return MemberActivity.online;
      case 'inMatch':
        return MemberActivity.inMatch;
      case 'inVoiceChat':
        return MemberActivity.inVoiceChat;
      case 'inParty':
        return MemberActivity.inParty;
      case 'spectating':
        return MemberActivity.spectating;
      case 'idle':
        return MemberActivity.idle;
      default:
        return MemberActivity.offline;
    }
  }

  WarStatus _parseWarStatus(String s) {
    switch (s) {
      case 'accepted':
        return WarStatus.accepted;
      case 'active':
        return WarStatus.active;
      case 'completed':
        return WarStatus.completed;
      case 'cancelled':
        return WarStatus.cancelled;
      default:
        return WarStatus.pending;
    }
  }

  AuditAction _parseAuditAction(String s) {
    const map = {
      'familyCreated': AuditAction.familyCreated,
      'settingsChanged': AuditAction.settingsChanged,
      'memberJoined': AuditAction.memberJoined,
      'memberLeft': AuditAction.memberLeft,
      'memberKicked': AuditAction.memberKicked,
      'memberPromoted': AuditAction.memberPromoted,
      'memberDemoted': AuditAction.memberDemoted,
      'memberMuted': AuditAction.memberMuted,
      'ownershipTransferred': AuditAction.ownershipTransferred,
      'motdUpdated': AuditAction.motdUpdated,
      'boostActivated': AuditAction.boostActivated,
      'treasuryDonation': AuditAction.treasuryDonation,
      'warStarted': AuditAction.warStarted,
      'warCompleted': AuditAction.warCompleted,
    };
    return map[s] ?? AuditAction.settingsChanged;
  }
}
