// ══════════════════════════════════════════════════════════════════════════
// AUDIO CONSTANTS — MAFIA AT CITY
// All asset paths, volume presets, and timing constants for the audio system.
// ══════════════════════════════════════════════════════════════════════════

class AudioPaths {
  AudioPaths._();

  // ── BASE DIRECTORIES ──
  static const _narration = 'audio/narration/';

  // ══════════════════════════════════════════════════════════════════════
  // NARRATOR VOICE LINES — deep cinematic Game Master
  // ══════════════════════════════════════════════════════════════════════

  /// Lobby countdown start (10s) — "Trust no one..."
  static const narrationTrustNoOne = '${_narration}trust_no_one.mp3';

  /// Lobby countdown end (0s) — "The show begins."
  static const narrationShowBegins = '${_narration}the_show_begins.mp3';

  /// Night phase init — "The shadows have claimed the city..."
  static const narrationNightStart = '${_narration}the_shadows_have_claimed.mp3';

  /// Mafia turn start — "Mafia, choose your prey..."
  static const narrationMafiaTurn = '${_narration}mafia_turn.mp3';

  /// Mafia confirm — "Prey locked."
  static const narrationMafiaLocked = '${_narration}prey_locked.mp3';

  /// Doctor turn start — "Doctor, listen... save a life..."
  static const narrationDoctorTurn = '${_narration}listen_Doctor_save.mp3';

  /// Doctor confirm — "A life locked."
  static const narrationDoctorLocked = '${_narration}a_Life_Locked.mp3';

  /// Detective turn start — "Detective, the streets are lying..."
  static const narrationDetectiveTurn = '${_narration}detective_the_streets_are_lying.mp3';

  /// Detective confirm — "Investigation complete."
  static const narrationDetectiveLocked = '${_narration}investigation_complete.mp3';

  /// Morning — someone died — "A body was found..."
  static const narrationBodyFound = '${_narration}A_body_was_found.mp3';

  /// Morning — everyone open your eyes
  static const narrationOpenEyes = '${_narration}Everyone_Open_your_eyes.mp3';

  /// Morning — saved — "A life is saved."
  static const narrationLifeSaved = '${_narration}a_Life_is_saved.mp3';

  /// Voting start — "Cast your votes."
  static const narrationVotingStart = '${_narration}cast_your_votes.mp3';

  /// Voting result: exile — "A citizen has been eliminated."
  static const narrationCitizenEliminated = '${_narration}a_citizen_has_been_eliminated.mp3';

  /// Voting result: tie / no one eliminated — "No one is eliminated."
  static const narrationNoOneEliminated = '${_narration}no_one_is_Eliminated.mp3';

  /// Voting result: skip — "No vote was cast."
  static const narrationNoVoteCast = '${_narration}no_vote_was_cast.mp3';

  /// Game over: mafia wins — "The MAFIA wins."
  static const narrationMafiaWins = '${_narration}the_MAFIA_wins..mp3';

  /// Game over: civilians win — "The Civilians win."
  static const narrationCiviliansWin = '${_narration}the_Civilians_win.mp3';
}

/// ══════════════════════════════════════════════════════════════════════════
/// VOLUME PRESETS
/// ══════════════════════════════════════════════════════════════════════════
class AudioVolumes {
  AudioVolumes._();

  // Narrator
  static const double narratorFull = 1.0;
}

/// ══════════════════════════════════════════════════════════════════════════
/// TIMING CONSTANTS
/// ══════════════════════════════════════════════════════════════════════════
class AudioTiming {
  AudioTiming._();

  /// Minimum gap between rapid narration triggers
  static const Duration narratorDebounce = Duration(milliseconds: 300);
}
