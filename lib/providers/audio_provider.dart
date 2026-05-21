import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/audio/audio_service.dart';

/// Audio service provider — exposes the singleton AudioService via Riverpod.
/// Use AudioService.instance directly when possible; this provider exists
/// for Riverpod-based code that needs to read it via ref.
final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService.instance;
});
