import 'package:go_router/go_router.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/matchmaking/screens/matchmaking_screen.dart';
import '../../features/game/screens/game_screen.dart';
import '../../features/game/screens/match_result_screen.dart';
import '../../features/battle_pass/screens/battle_pass_screen.dart';
import '../../features/store/screens/store_screen.dart';
import '../../features/family/screens/family_screen.dart';
import '../../features/family/screens/family_create_screen.dart';
import '../../features/family/screens/family_search_screen.dart';
import '../../features/family/screens/family_profile_screen.dart';
import '../../features/family/screens/family_chat_screen.dart';
import '../../features/family/screens/family_war_screen.dart';
import '../../features/family/screens/family_audit_log_screen.dart';
import '../../features/family/screens/family_settings_screen.dart';
import '../../features/family/screens/spectate_match_screen.dart';
import '../../features/rankings/screens/rankings_screen.dart';
import '../../features/leaderboard/screens/leaderboard_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/social/screens/friends_hub_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (c, s) => const SignupScreen()),
      GoRoute(path: '/home', builder: (c, s) => const HomeScreen()),
      GoRoute(path: '/matchmaking', builder: (c, s) => const MatchmakingScreen()),
      GoRoute(path: '/game', builder: (c, s) => const GameScreen()),
      GoRoute(path: '/game/result', builder: (c, s) => const MatchResultScreen()),
      GoRoute(path: '/battle-pass', builder: (c, s) => const BattlePassScreen()),
      GoRoute(path: '/store', builder: (c, s) => const StoreScreen()),
      GoRoute(path: '/family', builder: (c, s) => const FamilyScreen()),
      GoRoute(path: '/family/create', builder: (c, s) => const FamilyCreateScreen()),
      GoRoute(path: '/family/search', builder: (c, s) => const FamilySearchScreen()),
      GoRoute(path: '/family/profile', builder: (c, s) => const FamilyProfileScreen()),
      GoRoute(path: '/family/chat', builder: (c, s) => const FamilyChatScreen()),
      GoRoute(path: '/family/war', builder: (c, s) => const FamilyWarScreen()),
      GoRoute(path: '/family/audit', builder: (c, s) => const FamilyAuditLogScreen()),
      GoRoute(path: '/family/settings', builder: (c, s) => const FamilySettingsScreen()),
      GoRoute(path: '/family/spectate', builder: (c, s) => const SpectateMatchScreen()),
      GoRoute(path: '/rankings', builder: (c, s) => const RankingsScreen()),
      GoRoute(path: '/leaderboard', builder: (c, s) => const LeaderboardScreen()),
      GoRoute(path: '/profile', builder: (c, s) => const ProfileScreen()),
      GoRoute(path: '/profile/edit', builder: (c, s) => const EditProfileScreen()),
      GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
      GoRoute(path: '/friends', builder: (c, s) => const FriendsHubScreen()),
    ],
  );
}
