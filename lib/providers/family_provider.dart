import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/family_model.dart';
import '../models/family/family_treasury_model.dart';
import '../models/family/family_war_model.dart';
import '../models/family/family_achievement_model.dart';
import '../models/family/family_application_model.dart';
import '../models/family/family_audit_log_model.dart';
import '../models/family/family_chat_model.dart';
import '../services/family_service.dart';
import '../services/family_chat_service.dart';
import 'game_provider.dart';
import 'dart:async';

// ── Service Providers ──
final familyServiceProvider = Provider<FamilyService>((ref) => FamilyService());
final familyChatServiceProvider = Provider<FamilyChatService>(
  (ref) => FamilyChatService(),
);

// ── State ──
class FamilyHubState {
  final FamilyModel? family;
  final FamilyTreasury treasury;
  final List<FamilyApplication> applications;
  final List<FamilyWarModel> wars;
  final List<RivalryRecord> rivalries;
  final List<FamilyAchievement> achievements;
  final List<FamilyAuditEntry> auditLog;
  final List<FamilyChatMessage> chatMessages;
  final List<FamilyModel> searchResults;
  final bool isLoading;
  final String? error;

  const FamilyHubState({
    this.family,
    this.treasury = const FamilyTreasury(),
    this.applications = const [],
    this.wars = const [],
    this.rivalries = const [],
    this.achievements = const [],
    this.auditLog = const [],
    this.chatMessages = const [],
    this.searchResults = const [],
    this.isLoading = false,
    this.error,
  });

  bool get hasFamily => family != null;
  int get onlineCount => family?.onlineCount ?? 0;
  int get pendingApps =>
      applications.where((a) => a.status == ApplicationStatus.pending).length;

  FamilyHubState copyWith({
    FamilyModel? family,
    FamilyTreasury? treasury,
    List<FamilyApplication>? applications,
    List<FamilyWarModel>? wars,
    List<RivalryRecord>? rivalries,
    List<FamilyAchievement>? achievements,
    List<FamilyAuditEntry>? auditLog,
    List<FamilyChatMessage>? chatMessages,
    List<FamilyModel>? searchResults,
    bool? isLoading,
    String? error,
    bool clearFamily = false,
  }) {
    return FamilyHubState(
      family: clearFamily ? null : (family ?? this.family),
      treasury: treasury ?? this.treasury,
      applications: applications ?? this.applications,
      wars: wars ?? this.wars,
      rivalries: rivalries ?? this.rivalries,
      achievements: achievements ?? this.achievements,
      auditLog: auditLog ?? this.auditLog,
      chatMessages: chatMessages ?? this.chatMessages,
      searchResults: searchResults ?? this.searchResults,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ── Notifier ──
class FamilyHubNotifier extends Notifier<FamilyHubState> {
  StreamSubscription? _sub;

  @override
  FamilyHubState build() {
    _loadAll();

    final ws = ref.watch(wsServiceProvider);
    _sub?.cancel();
    _sub = ws.eventStream.listen((msg) {
      if (msg.event == 'family_chat') {
        final chatMsg = _chat.parseMessage(msg.data['message']);
        if (!state.chatMessages.any((m) => m.id == chatMsg.id)) {
          state = state.copyWith(
            chatMessages: [chatMsg, ...state.chatMessages],
          );
        }
      }
    });

    ref.onDispose(() {
      _sub?.cancel();
    });

    return const FamilyHubState(isLoading: true);
  }

  FamilyService get _svc => ref.read(familyServiceProvider);
  FamilyChatService get _chat => ref.read(familyChatServiceProvider);

  Future<void> _loadAll() async {
    try {
      final family = await _svc.getCurrentFamily();
      final treasury = await _svc.getTreasury();
      final apps = await _svc.getApplications();
      final wars = await _svc.getWars();
      final rivals = await _svc.getRivalries();
      final achievements = await _svc.getAchievements();
      final audit = await _svc.getAuditLog();
      final messages = await _chat.getMessages();
      state = state.copyWith(
        family: family,
        treasury: treasury,
        applications: apps,
        wars: wars,
        rivalries: rivals,
        achievements: achievements,
        auditLog: audit,
        chatMessages: messages,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async => _loadAll();

  // ── Creation ──
  Future<void> createFamily({
    required String name,
    required String tag,
    String description = '',
    String slogan = '',
    FamilyPrivacy privacy = FamilyPrivacy.approvalRequired,
  }) async {
    state = state.copyWith(isLoading: true);
    final family = await _svc.createFamily(
      name: name,
      tag: tag,
      description: description,
      slogan: slogan,
      privacy: privacy,
    );
    state = state.copyWith(family: family, isLoading: false);
  }

  Future<void> leaveFamily() async {
    await _svc.leaveFamily();
    state = state.copyWith(clearFamily: true);
  }

  Future<void> deleteFamily() async {
    await _svc.deleteFamily();
    state = state.copyWith(clearFamily: true);
  }

  // ── Settings ──
  Future<void> updateSettings({
    String? name,
    String? tag,
    String? description,
    String? slogan,
    String? motd,
    FamilyPrivacy? privacy,
  }) async {
    await _svc.updateSettings(
      name: name,
      tag: tag,
      description: description,
      slogan: slogan,
      motd: motd,
      privacy: privacy,
    );
    final family = await _svc.getCurrentFamily();
    state = state.copyWith(family: family);
  }

  // ── Members ──
  Future<void> kickMember(String userId) async {
    await _svc.kickMember(userId);
    await _refreshFamily();
  }

  Future<void> promoteMember(String userId) async {
    await _svc.promoteMember(userId);
    await _refreshFamily();
  }

  Future<void> demoteMember(String userId) async {
    await _svc.demoteMember(userId);
    await _refreshFamily();
  }

  Future<void> muteMember(String userId) async {
    await _svc.muteMember(userId);
    await _refreshFamily();
  }

  Future<void> transferOwnership(String userId) async {
    await _svc.transferOwnership(userId);
    await _refreshFamily();
  }

  // ── Applications ──
  Future<void> acceptApplication(String appId) async {
    await _svc.acceptApplication(appId);
    final apps = await _svc.getApplications();
    final family = await _svc.getCurrentFamily();
    state = state.copyWith(applications: apps, family: family);
  }

  Future<void> rejectApplication(String appId) async {
    await _svc.rejectApplication(appId);
    final apps = await _svc.getApplications();
    state = state.copyWith(applications: apps);
  }

  // ── Treasury ──
  Future<void> donate(int amount) async {
    await _svc.donate(amount);
    final treasury = await _svc.getTreasury();
    final family = await _svc.getCurrentFamily();
    state = state.copyWith(treasury: treasury, family: family);
  }

  Future<bool> activateBoost(FamilyBoostType type) async {
    final success = await _svc.activateBoost(type);
    if (success) {
      final treasury = await _svc.getTreasury();
      state = state.copyWith(treasury: treasury);
    }
    return success;
  }

  // ── Chat ──
  Future<void> sendChatMessage(String content) async {
    await _chat.sendMessage(content);
    final messages = await _chat.getMessages();
    state = state.copyWith(chatMessages: messages);
  }

  // ── Search ──
  Future<void> searchFamilies(String query) async {
    final results = await _svc.searchFamilies(query);
    state = state.copyWith(searchResults: results);
  }

  Future<void> _refreshFamily() async {
    final family = await _svc.getCurrentFamily();
    final audit = await _svc.getAuditLog();
    state = state.copyWith(family: family, auditLog: audit);
  }

  // ── Invites & Applications ──
  Future<void> applyToFamily(String familyId) async {
    // TODO: Implement apply API
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> inviteFriendToFamily(String userId) async {
    // TODO: Implement invite API
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

// ── Provider ──
final familyProvider = NotifierProvider<FamilyHubNotifier, FamilyHubState>(
  FamilyHubNotifier.new,
);

// ── Derived ──
final familyMembersProvider = Provider<List<FamilyMember>>((ref) {
  return ref.watch(familyProvider).family?.members ?? [];
});

final onlineMemberCountProvider = Provider<int>((ref) {
  return ref.watch(familyProvider).onlineCount;
});

final familyLevelProvider = Provider<int>((ref) {
  return ref.watch(familyProvider).family?.level ?? 0;
});

final hasFamilyProvider = Provider<bool>((ref) {
  return ref.watch(familyProvider).hasFamily;
});
