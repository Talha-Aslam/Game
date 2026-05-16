/// Voice channel service architecture (Agora/LiveKit integration)
/// Manages voice channels for game phases, private mafia channels, and graveyard
class VoiceService {
  bool _isConnected = false;
  bool _isMuted = false;
  String? _currentChannel;
  bool _pushToTalk = false;
  double _micSensitivity = 0.5;

  bool get isConnected => _isConnected;
  bool get isMuted => _isMuted;
  String? get currentChannel => _currentChannel;
  bool get pushToTalk => _pushToTalk;
  double get micSensitivity => _micSensitivity;

  /// Initialize voice engine
  Future<void> init() async {
    // In production:
    // await AgoraRtcEngine.create(AppConstants.agoraAppId);
    // await _engine.enableAudio();
    // await _engine.setChannelProfile(ChannelProfile.Communication);
  }

  /// Join a voice channel
  Future<void> joinChannel(String channelName, {String? token}) async {
    _currentChannel = channelName;
    _isConnected = true;
    // await _engine.joinChannel(token, channelName, null, uid);
  }

  /// Leave current channel
  Future<void> leaveChannel() async {
    _currentChannel = null;
    _isConnected = false;
    // await _engine.leaveChannel();
  }

  /// Switch to a different channel (e.g., mafia private channel at night)
  Future<void> switchChannel(String channelName, {String? token}) async {
    await leaveChannel();
    await joinChannel(channelName, token: token);
  }

  /// Mute/unmute local microphone
  void setMuted(bool muted) {
    _isMuted = muted;
    // _engine.muteLocalAudioStream(muted);
  }

  /// Toggle mute
  void toggleMute() {
    setMuted(!_isMuted);
  }

  /// Set push-to-talk mode
  void setPushToTalk(bool enabled) {
    _pushToTalk = enabled;
    if (enabled) {
      setMuted(true); // Mute by default in PTT mode
    }
  }

  /// Set microphone sensitivity
  void setMicSensitivity(double sensitivity) {
    _micSensitivity = sensitivity;
  }

  /// Join game main channel
  Future<void> joinGameChannel(String gameId) async {
    await joinChannel('game_$gameId');
  }

  /// Join mafia private channel (night phase)
  Future<void> joinMafiaChannel(String gameId) async {
    await switchChannel('mafia_$gameId');
  }

  /// Join graveyard channel (after elimination)
  Future<void> joinGraveyardChannel(String gameId) async {
    await switchChannel('graveyard_$gameId');
  }

  /// Return to main game channel
  Future<void> returnToGameChannel(String gameId) async {
    await switchChannel('game_$gameId');
  }

  /// Dispose
  void dispose() {
    leaveChannel();
    // _engine.destroy();
  }
}
