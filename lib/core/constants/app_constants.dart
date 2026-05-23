/// Game timing and configuration constants
class AppConstants {
  AppConstants._();

  // ── Game Config ──
  static const int maxPlayersPerGame = 10;
  static const int minPlayersToStart = 6;

  // ── Phase Durations (seconds) ──
  static const int nightPhaseDuration = 30;
  static const int dayDiscussionDuration = 90;
  static const int votingDuration = 20;
  static const int runoffDuration = 10;
  static const int roleRevealDuration = 5;

  // ── Matchmaking ──
  static const int matchmakingTimeout = 120;
  static const int matchAcceptTimeout = 15;

  // ── Animation Durations (ms) ──
  static const int quickAnimation = 200;
  static const int normalAnimation = 400;
  static const int slowAnimation = 800;
  static const int phaseTransition = 1200;
  static const int eliminationAnimation = 1500;

  // ── Audio ──
  static const double defaultMusicVolume = 0.5;
  static const double defaultSfxVolume = 0.8;
  static const double defaultVoiceVolume = 1.0;

  // ── Voice ──
  static const String agoraAppId = 'faee0e101a9a48338663b3fc493b14a4';

  // ── WebSocket ──
  static const String wsUrl = 'ws://64.227.145.171/ws';
  static const String apiBaseUrl = 'http://64.227.145.171';

  // ── Ranks ──
  static const List<String> rankNames = [
    'Bronze',
    'Silver',
    'Gold',
    'Diamond',
    'Syndicate Boss',
  ];

  // ── Family Roles ──
  static const List<String> familyRoles = [
    'Boss',
    'Underboss',
    'Capo',
    'Associate',
  ];
}
