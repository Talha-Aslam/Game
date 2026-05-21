import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/social_api_service.dart';

class RankingEntry {
  final int position;
  final String id;
  final String username;
  final String avatarUrl;
  final int rankTier;
  final int points;
  final String? familyTag;
  final int wins;
  final int losses;

  const RankingEntry({
    required this.position,
    this.id = '',
    required this.username,
    this.avatarUrl = '',
    required this.rankTier,
    required this.points,
    this.familyTag,
    this.wins = 0,
    this.losses = 0,
  });
}

class LeaderboardState {
  final List<RankingEntry> entries;
  final bool isLoading;
  final String? error;

  const LeaderboardState({
    this.entries = const [],
    this.isLoading = false,
    this.error,
  });

  LeaderboardState copyWith({
    List<RankingEntry>? entries,
    bool? isLoading,
    String? error,
  }) {
    return LeaderboardState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class LeaderboardNotifier extends Notifier<LeaderboardState> {
  @override
  LeaderboardState build() {
    _loadLeaderboard();
    return const LeaderboardState(isLoading: true);
  }

  Future<void> _loadLeaderboard() async {
    try {
      final api = SocialApiService();
      final data = await api.getLeaderboard(limit: 50);
      final entries = data.map((json) => RankingEntry(
        position: json['position'] ?? 0,
        id: json['id'] ?? '',
        username: json['username'] ?? '',
        avatarUrl: json['avatarUrl'] ?? json['avatar_url'] ?? '',
        rankTier: json['rankTier'] ?? json['rank_tier'] ?? 0,
        points: json['points'] ?? 0,
        familyTag: json['familyTag'] ?? json['family_tag'],
        wins: json['wins'] ?? 0,
        losses: json['losses'] ?? 0,
      )).toList();
      state = LeaderboardState(entries: entries, isLoading: false);
    } catch (e) {
      state = LeaderboardState(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async => _loadLeaderboard();
}

final leaderboardNotifierProvider = NotifierProvider<LeaderboardNotifier, LeaderboardState>(
  LeaderboardNotifier.new,
);

/// Backward-compatible provider for screens that use the old static list
final leaderboardProvider = Provider<List<RankingEntry>>((ref) {
  return ref.watch(leaderboardNotifierProvider).entries;
});
