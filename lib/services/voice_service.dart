import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceService {
  late RtcEngine _engine;
  final String appId = "faee0e101a9a48338663b3fc493b14a4";
  bool _isInitialized = false;

  final _activeSpeakersController = StreamController<List<int>>.broadcast();
  Stream<List<int>> get activeSpeakers => _activeSpeakersController.stream;

  final _channelUsersController = StreamController<List<int>>.broadcast();
  Stream<List<int>> get channelUsers => _channelUsersController.stream;
  final List<int> _currentUsers = [];
  
  final Map<int, String> _uidToAccount = {};
  Map<int, String> get uidMap => _uidToAccount;

  final _mutedUsersController = StreamController<Map<int, bool>>.broadcast();
  Stream<Map<int, bool>> get mutedUsers => _mutedUsersController.stream;
  final Map<int, bool> _mutedUsers = {};

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
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) async {
          if (!_currentUsers.contains(remoteUid)) {
            _currentUsers.add(remoteUid);
            try {
              final userInfo = await _engine.getUserInfoByUid(remoteUid);
              if (userInfo.userAccount != null) {
                _uidToAccount[remoteUid] = userInfo.userAccount!;
              }
            } catch (_) {}
            _channelUsersController.add(List.from(_currentUsers));
          }
        },
        onUserOffline:
            (
              RtcConnection connection,
              int remoteUid,
              UserOfflineReasonType reason,
            ) {
              _currentUsers.remove(remoteUid);
              _uidToAccount.remove(remoteUid);
              _channelUsersController.add(List.from(_currentUsers));
              _mutedUsers.remove(remoteUid);
              _mutedUsersController.add(Map.from(_mutedUsers));
            },
        onUserMuteAudio: (RtcConnection connection, int remoteUid, bool muted) {
          _mutedUsers[remoteUid] = muted;
          _mutedUsersController.add(Map.from(_mutedUsers));
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

    try {
      await _engine.joinChannelWithUserAccount(
        token: token,
        channelId: channelName,
        userAccount: userId,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          autoSubscribeAudio: true,
          publishMicrophoneTrack: true,
          enableAudioRecordingOrPlayout: true,
        ),
      );
      
      // Explicitly ensure local audio is enabled and unmuted after join
      await _engine.enableLocalAudio(true);
      await _engine.muteLocalAudioStream(false);
      await _engine.muteAllRemoteAudioStreams(false);
      
      debugPrint("VoiceService: Joined $channelName as $userId");
    } catch (e) {
      debugPrint("VoiceService: Failed to join $channelName: $e");
    }
  }

  Future<void> leaveChannel() async {
    if (_isInitialized) {
      await _engine.leaveChannel();
      _currentUsers.clear();
      _channelUsersController.add(_currentUsers);
      _mutedUsers.clear();
      _mutedUsersController.add(_mutedUsers);
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
      // Optional: Since onUserMuteAudio doesn't trigger for the local user, we can manually add it
      // if we want to track local user mute state in the same stream.
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
    _channelUsersController.close();
    _mutedUsersController.close();
    if (_isInitialized) {
      _engine.release();
    }
  }
}
