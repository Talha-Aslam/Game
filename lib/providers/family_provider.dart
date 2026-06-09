import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/family_model.dart';
import '../models/family/family_treasury_model.dart';
import '../models/family/family_achievement_model.dart';
import '../models/family/family_application_model.dart';
import '../models/family/family_audit_log_model.dart';
import '../models/family/family_chat_model.dart';
import '../services/family_service.dart';
import '../services/family_chat_service.dart';
import '../services/http_service.dart';
import 'dart:async';
import 'matchmaking_provider.dart';
import 'auth_provider.dart';

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
  final List<FamilyAchievement> achievements;
  final List<FamilyAuditEntry> auditLog;
  final List<FamilyChatMessage> chatMessages;
  final List<FamilyModel> searchResults;
  final bool hasUnreadChat;
  final bool isLoading;
  final String? error;

  const FamilyHubState({
    this.family,
    this.treasury = const FamilyTreasury(),
    this.applications = const [],
    this.achievements = const [],
    this.auditLog = const [],
    this.chatMessages = const [],
    this.searchResults = const [],
    this.hasUnreadChat = false,
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
    List<FamilyAchievement>? achievements,
    List<FamilyAuditEntry>? auditLog,
    List<FamilyChatMessage>? chatMessages,
    List<FamilyModel>? searchResults,
    bool? hasUnreadChat,
    bool? isLoading,
    String? error,
    bool clearFamily = false,
  }) {
    return FamilyHubState(
      family: clearFamily ? null : (family ?? this.family),
      treasury: treasury ?? this.treasury,
      applications: applications ?? this.applications,
      achievements: achievements ?? this.achievements,
      auditLog: auditLog ?? this.auditLog,
      chatMessages: chatMessages ?? this.chatMessages,
      searchResults: searchResults ?? this.searchResults,
      hasUnreadChat: hasUnreadChat ?? this.hasUnreadChat,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// ── Notifier ──
class FamilyHubNotifier extends Notifier<FamilyHubState> {
  StreamSubscription? _wsSub;
  StreamSubscription? _chatSub;
  final _http = HttpService();

  @override
  FamilyHubState build() {
    _loadAll();

    final ws = ref.watch(webSocketServiceProvider);
    _wsSub?.cancel();
    _wsSub = ws.eventStream.listen((msg) {
      if (msg.event == 'family_application') {
        refresh();
      } else if (msg.event == 'family_treasury_update') {
        final treasuryData = msg.data['treasury'] as Map<String, dynamic>?;
        if (treasuryData != null) {
          final treasury = _svc.parseTreasury(treasuryData);
          state = state.copyWith(treasury: treasury);
        } else {
          _loadTreasury();
        }
      } else if (msg.event == 'family_chat_cleared') {
        state = state.copyWith(chatMessages: []);
      } else if (msg.event == 'family_member_updated') {
        _refreshFamily();
      } else if (msg.event == 'family_role_updated') {
        final data = msg.data;
        if (data['target_user_id'] == ref.read(authProvider).user?.id) {
           _refreshFamily();
        }
      } else if (msg.event == 'family_member_status') {
        final data = msg.data;
        final userId = data['user_id'] as String;
        final status = data['status'] as String;
        
        if (state.family != null) {
          final members = state.family!.members.map((m) {
            if (m.userId == userId) {
              return m.copyWith(activity: status == 'online' ? MemberActivity.online : MemberActivity.offline);
            }
            return m;
          }).toList();
          state = state.copyWith(family: state.family!.copyWith(members: members));
        }
      }
    });

    _chatSub?.cancel();
    _chatSub = _chat.messageStream.listen((chatMsg) {
      if (!state.chatMessages.any((m) => m.id == chatMsg.id)) {
        state = state.copyWith(
          chatMessages: [...state.chatMessages, chatMsg],
          hasUnreadChat: true,
        );
      }
    });

    ref.onDispose(() {
      _wsSub?.cancel();
      _chatSub?.cancel();
    });

    return const FamilyHubState(isLoading: true);
  }

  FamilyService get _svc => ref.read(familyServiceProvider);
  FamilyChatService get _chat => ref.read(familyChatServiceProvider);

  Future<bool> sendGift(String targetUserId, int amount) async {
    try {
      final res = await _http.post('/family/gift', body: {
        'target_user_id': targetUserId,
        'amount': amount,
      });
      if (res != null && res['status'] == 'success') {
        final user = ref.read(authProvider).user;
        if (user != null) {
          ref.read(authProvider.notifier).updateUserLocal(
            user.copyWith(syndicateCoins: user.syndicateCoins - amount),
          );
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void markChatRead() {
    if (state.hasUnreadChat) {
      state = state.copyWith(hasUnreadChat: false);
    }
  }

  Future<void> _loadAll() async {
    try {
      final family = await _svc.getCurrentFamily();
      final treasury = await _svc.getTreasury();
      final apps = await _svc.getApplications();
      final achievements = await _svc.getAchievements();
      final audit = await _svc.getAuditLog();
      final messages = await _chat.getMessages();
      state = state.copyWith(
        family: family,
        treasury: treasury,
        applications: apps,
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

  Future<void> donate(int amount) async {
    await _svc.donate(amount);
    final treasury = await _svc.getTreasury();
    final family = await _svc.getCurrentFamily();
    state = state.copyWith(treasury: treasury, family: family);
  }

  Future<bool> activateBoost(FamilyBoostType type) async {
    final now = DateTime.now();
    final optimisticBoost = FamilyBoost(
      id: 'optimistic_${type.name}',
      type: type,
      activatedAt: now,
      expiresAt: now.add(type.duration),
      activatedBy: 'You',
    );
    final optimisticTreasury = state.treasury.copyWith(
      balance: state.treasury.balance - type.cost,
      activeBoosts: [...state.treasury.activeBoosts, optimisticBoost],
    );
    state = state.copyWith(treasury: optimisticTreasury);

    final success = await _svc.activateBoost(type);
    if (success) {
      final treasury = await _svc.getTreasury();
      state = state.copyWith(treasury: treasury);
    } else {
      final treasury = await _svc.getTreasury();
      state = state.copyWith(treasury: treasury);
    }
    return success;
  }

  Future<void> sendChatMessage(String content) async {
    await _chat.sendMessage(content);
    final messages = await _chat.getMessages();
    state = state.copyWith(chatMessages: messages);
  }

  Future<void> searchFamilies(String query) async {
    final results = await _svc.searchFamilies(query);
    state = state.copyWith(searchResults: results);
  }

  Future<void> _loadTreasury() async {
    try {
      final treasury = await _svc.getTreasury();
      final family = await _svc.getCurrentFamily();
      state = state.copyWith(treasury: treasury, family: family);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> clearChatHistory() async {
    try {
      await _chat.clearHistory();
      state = state.copyWith(chatMessages: []);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> _refreshFamily() async {
    final family = await _svc.getCurrentFamily();
    final audit = await _svc.getAuditLog();
    state = state.copyWith(family: family, auditLog: audit);
  }

  Future<void> applyToFamily(String familyId, {String message = '', bool isInvite = false}) async {
    await _svc.applyToFamily(familyId, message: message, isInvite: isInvite);
  }

  void inviteFriendToFamily(String friendId) {
    if (state.family == null) return;
    ref.read(webSocketServiceProvider).send('family_invite', {
      'targetId': friendId, 
      'familyId': state.family!.id, 
      'familyName': state.family!.name
    });
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
