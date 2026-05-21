// ══════════════════════════════════════════════════════════════════════════
// LEGACY BRIDGE — audio_service.dart
// ══════════════════════════════════════════════════════════════════════════
//
// This file re-exports the new modular AudioService so that existing
// imports (e.g., from game_provider.dart) continue to compile.
//
// The real implementation is in:
//   lib/services/audio/audio_service.dart
//   lib/services/audio/bgm_manager.dart
//   lib/services/audio/sfx_manager.dart
//   lib/services/audio/audio_constants.dart
//
// All new code should import from 'services/audio/audio_service.dart'.
// ══════════════════════════════════════════════════════════════════════════

export 'audio/audio_service.dart';
export 'audio/audio_constants.dart';
