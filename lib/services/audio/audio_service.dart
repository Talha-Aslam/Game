import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'audio_constants.dart';

/// ══════════════════════════════════════════════════════════════════════════
/// AUDIO SERVICE — City of Lies Cinematic Audio System
/// ══════════════════════════════════════════════════════════════════════════
///
/// Singleton orchestrator for the entire game audio pipeline:
/// • Narrator voice lines (deep cinematic Game Master)
///
/// Access globally via:
///   AudioService.instance
///
/// Architecture:
///   AudioService
///     ├── _narrator  (AudioPlayer) — exclusive voice line player
///
/// Audio Mixing Rules:
///   1. Narration is NEVER overlapped — new line stops previous
class AudioService {
  // ── Singleton ──
  AudioService._internal();
  static final AudioService _instance = AudioService._internal();
  static AudioService get instance => _instance;

  // ── Narrator player ──
  final AudioPlayer _narrator = AudioPlayer();
  bool _narratorPlaying = false;
  bool _initialized = false;
  bool _disposed = false;
  DateTime _lastNarrationTime = DateTime(2000);
  StreamSubscription? _narratorSub;

  // ══════════════════════════════════════════════════════════════════════
  // INITIALIZATION
  // ══════════════════════════════════════════════════════════════════════

  /// Initialize the audio service. Call once at app startup.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // Configure narrator player
    _narrator.setReleaseMode(ReleaseMode.stop);
    _narrator.setVolume(AudioVolumes.narratorFull);

    // Listen for narrator completion
    _narratorSub = _narrator.onPlayerComplete.listen((_) {
      _narratorPlaying = false;
    });

    _log('AudioService initialized');
  }

  // ══════════════════════════════════════════════════════════════════════
  // GENERIC VOICE LINE METHOD
  // ══════════════════════════════════════════════════════════════════════

  /// Play a narrator voice line.
  ///
  /// This method:
  /// • Stops any currently playing narration
  /// • Catches exceptions
  /// • Logs errors
  /// • Handles rapid event triggers safely (debounce)
  Future<void> _playVoiceLine(String assetPath) async {
    if (_disposed) return;

    // Debounce rapid triggers
    final now = DateTime.now();
    if (now.difference(_lastNarrationTime) < AudioTiming.narratorDebounce) {
      await Future.delayed(AudioTiming.narratorDebounce);
    }
    _lastNarrationTime = DateTime.now();

    try {
      // Stop current narration if playing
      if (_narratorPlaying) {
        await _narrator.stop();
      }

      _narratorPlaying = true;

      // Play the voice line
      await _narrator.setVolume(AudioVolumes.narratorFull);
      await _narrator.play(AssetSource(assetPath));

      _log('Playing narration: $assetPath');
    } catch (e) {
      _narratorPlaying = false;
      _log('Narrator error: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // GAME STATE VOICE METHODS
  // ══════════════════════════════════════════════════════════════════════
  //
  // Each method maps to a specific game state transition.
  // Call these from GameNotifier when the corresponding event fires.

  // ── LOBBY PHASE ──

  /// Trigger when Lobby timer reaches 10 seconds — countdown begins.
  /// Plays: "Trust no one..."
  Future<void> playLobbyIntro() async {
    await _playVoiceLine(AudioPaths.narrationTrustNoOne);
  }

  /// Trigger when Lobby countdown reaches 0 — game is about to start.
  /// Plays: "The show begins."
  Future<void> playGameStart() async {
    await _playVoiceLine(AudioPaths.narrationShowBegins);
  }

  // ── NIGHT PHASE ──

  /// Trigger when Night phase begins (before Mafia turn).
  /// Plays: "The shadows have claimed the city..."
  Future<void> playNightStart() async {
    await _playVoiceLine(AudioPaths.narrationNightStart);
  }

  /// Trigger when Mafia sub-phase begins.
  /// Plays: "Mafia, choose your prey..."
  Future<void> playMafiaTurn() async {
    await _playVoiceLine(AudioPaths.narrationMafiaTurn);
  }

  /// Trigger when Mafia confirms target selection.
  /// Plays: "Prey locked."
  Future<void> playMafiaLocked() async {
    await _playVoiceLine(AudioPaths.narrationMafiaLocked);
  }

  /// Trigger when Doctor sub-phase begins.
  /// Plays: "Doctor, listen... save a life..."
  Future<void> playDoctorTurn() async {
    await _playVoiceLine(AudioPaths.narrationDoctorTurn);
  }

  /// Trigger when Doctor confirms target selection.
  /// Plays: "A life locked."
  Future<void> playDoctorLocked() async {
    await _playVoiceLine(AudioPaths.narrationDoctorLocked);
  }

  /// Trigger when Detective sub-phase begins.
  /// Plays: "Detective, the streets are lying..."
  Future<void> playDetectiveTurn() async {
    await _playVoiceLine(AudioPaths.narrationDetectiveTurn);
  }

  /// Trigger when Detective confirms investigation target.
  /// Plays: "Investigation complete."
  Future<void> playDetectiveLocked() async {
    await _playVoiceLine(AudioPaths.narrationDetectiveLocked);
  }

  // ── MORNING REVEAL ──

  /// Trigger when morning phase reveals results.
  /// [someoneDied] = true → "A body was found..."
  /// [someoneDied] = false → "A life is saved."
  Future<void> playMorningResults({required bool someoneDied}) async {
    // First play "Everyone open your eyes"
    await _playVoiceLine(AudioPaths.narrationOpenEyes);
    // Wait for it to finish, then play result
    await Future.delayed(const Duration(milliseconds: 2500));
    if (someoneDied) {
      await _playVoiceLine(AudioPaths.narrationBodyFound);
    } else {
      await _playVoiceLine(AudioPaths.narrationLifeSaved);
    }
  }

  // ── VOTING PHASE ──

  /// Trigger when Voting phase begins.
  /// Plays: "Cast your votes."
  Future<void> playVotingStart() async {
    await _playVoiceLine(AudioPaths.narrationVotingStart);
  }

  /// Trigger when votes are tallied and result is determined.
  /// [resultType]: 'exile', 'tie', or 'skip'
  Future<void> playVotingResult({required String resultType}) async {
    switch (resultType) {
      case 'exile':
        await _playVoiceLine(AudioPaths.narrationCitizenEliminated);
        break;
      case 'tie':
        await _playVoiceLine(AudioPaths.narrationNoOneEliminated);
        break;
      case 'skip':
        await _playVoiceLine(AudioPaths.narrationNoVoteCast);
        break;
    }
  }

  // ── GAME OVER ──

  /// Trigger when game ends.
  /// [mafiaWon] = true → "The MAFIA wins."
  /// [mafiaWon] = false → "The Civilians win."
  Future<void> playGameOver({required bool mafiaWon}) async {
    if (mafiaWon) {
      await _playVoiceLine(AudioPaths.narrationMafiaWins);
    } else {
      await _playVoiceLine(AudioPaths.narrationCiviliansWin);
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // MASTER CONTROLS
  // ══════════════════════════════════════════════════════════════════════

  /// Stop ALL audio — narrator
  Future<void> stopAll() async {
    _narratorPlaying = false;
    await _narrator.stop();
  }

  /// Stop narrator only
  Future<void> stopNarrator() async {
    _narratorPlaying = false;
    await _narrator.stop();
  }

  /// Check if narrator is currently playing
  bool get isNarratorPlaying => _narratorPlaying;

  // ══════════════════════════════════════════════════════════════════════
  // DISPOSAL
  // ══════════════════════════════════════════════════════════════════════

  /// Dispose all audio resources. Call when app closes.
  Future<void> dispose() async {
    _disposed = true;
    _narratorSub?.cancel();
    await _narrator.dispose();
    _log('AudioService disposed');
  }

  void _log(String msg) {
    assert(() {
      // ignore: avoid_print
      print('[AudioService] $msg');
      return true;
    }());
  }
}
