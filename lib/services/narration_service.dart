/// Dynamic narration clip combiner
/// Combines pre-recorded audio clips to form contextual narration
class NarrationService {
  final List<String> _queue = [];
  bool _isPlaying = false;

  /// Queue a narration sequence from clips
  void queueNarration(List<String> clipPaths) {
    _queue.addAll(clipPaths);
    if (!_isPlaying) _playNext();
  }

  /// Play next clip in queue
  Future<void> _playNext() async {
    if (_queue.isEmpty) {
      _isPlaying = false;
      return;
    }
    _isPlaying = true;
    _queue.removeAt(0); // clip consumed
    // In production: await audioPlayer.setAsset(clipPath); await audioPlayer.play();
    await Future.delayed(const Duration(seconds: 2));
    _playNext();
  }

  /// Clear queue
  void clear() {
    _queue.clear();
    _isPlaying = false;
  }

  void dispose() {
    clear();
  }
}
