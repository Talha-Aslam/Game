import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceService {
  late RtcEngine _engine;
  final String appId = "faee0e101a9a48338663b3fc493b14a4";
  bool _isInitialized = false;

  final _activeSpeakersController = StreamController<List<int>>.broadcast();
  Stream<List<int>> get activeSpeakers => _activeSpeakersController.stream;

  Future<void> initAgora() async {
    if (_isInitialized) return;

    await [Permission.microphone].request();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: appId));

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          // print("Joined channel: ${connection.channelId}");
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          // print("User joined: $remoteUid");
        },
        onUserOffline:
            (
              RtcConnection connection,
              int remoteUid,
              UserOfflineReasonType reason,
            ) {
              // print("User offline: $remoteUid");
            },
        onAudioVolumeIndication:
            (
              RtcConnection connection,
              List<AudioVolumeInfo> speakers,
              int speakerNumber,
              int totalVolume,
            ) {
              final activeIds = speakers
                  .where((s) => s.volume! > 10)
                  .map((s) => s.uid!)
                  .toList();
              _activeSpeakersController.add(activeIds);
            },
      ),
    );

    // Enable audio volume indication every 200ms
    await _engine.enableAudioVolumeIndication(
      interval: 200,
      smooth: 3,
      reportVad: true,
    );
    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.enableAudio();

    _isInitialized = true;
  }

  Future<void> joinChannel(
    String token,
    String channelName,
    String userId,
  ) async {
    if (!_isInitialized) await initAgora();

    int uid = userId.hashCode
        .abs(); // Agora uses int uid, we hash the string ID

    await _engine.joinChannel(
      token: token,
      channelId: channelName,
      uid: uid,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        autoSubscribeAudio: true,
        publishMicrophoneTrack: true,
      ),
    );
  }

  Future<void> leaveChannel() async {
    if (_isInitialized) {
      await _engine.leaveChannel();
    }
  }

  Future<void> switchChannel(
    String token,
    String channelName,
    String userId,
  ) async {
    await leaveChannel();
    await joinChannel(token, channelName, userId);
  }

  Future<void> muteMicrophone(bool mute) async {
    if (_isInitialized) {
      await _engine.muteLocalAudioStream(mute);
    }
  }

  // Ambient noise for civilians at night
  void setAmbientAudioMode(bool enable) {
    if (!_isInitialized) return;
    if (enable) {
      _engine.muteLocalAudioStream(true);
      // In a real app, play local ambient rain/heartbeat loop using audioplayers package here
    } else {
      _engine.muteLocalAudioStream(false);
    }
  }

  void dispose() {
    _activeSpeakersController.close();
    if (_isInitialized) {
      _engine.release();
    }
  }
}
