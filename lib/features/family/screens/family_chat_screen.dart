import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../models/family_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../providers/family_provider.dart';
import '../../../providers/game_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/family_api_service.dart';
import '../../../widgets/waveform_indicator.dart';
import '../widgets/family_chat_bubble.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

/// Full-screen family chat
class FamilyChatScreen extends ConsumerStatefulWidget {
  const FamilyChatScreen({super.key});
  @override
  ConsumerState<FamilyChatScreen> createState() => _FamilyChatScreenState();
}

class _FamilyChatScreenState extends ConsumerState<FamilyChatScreen> {
  final _msgController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isVoiceActive = false;
  bool _showEmojiPicker = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _joinVoiceLounge();
    });
  }

  Future<void> _joinVoiceLounge() async {
    if (_isVoiceActive) return;
    final family = ref.read(familyProvider).family;
    final user = ref.read(authProvider).user;
    if (family != null && user != null) {
      final messenger = ScaffoldMessenger.of(context);
      final channelName = 'family_${family.id}';
      try {
        final token = await FamilyApiService().getVoiceToken(channelName);
        await ref
            .read(voiceServiceProvider)
            .joinChannel(token, channelName, user.id);
        if (mounted) setState(() => _isVoiceActive = true);
      } catch (e) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Failed to join voice chat')),
        );
      }
    }
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    if (_isVoiceActive) {
      ref.read(voiceServiceProvider).leaveChannel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(familyProvider).chatMessages;
    final family = ref.watch(familyProvider).family;
    final user = ref.watch(authProvider).user;
    final isBoss =
        family?.members.any(
          (m) => m.userId == user?.id && m.role.name.toLowerCase() == 'boss',
        ) ??
        false;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppGradients.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.white70,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text('Family Chat', style: AppTextStyles.headlineMedium),
                    const Spacer(),
                    if (isBoss) ...[
                      GestureDetector(
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: AppColors.surface,
                              title: const Text(
                                'Clear Chat',
                                style: TextStyle(color: Colors.white),
                              ),
                              content: const Text(
                                'Are you sure you want to clear the entire chat history for everyone?',
                                style: TextStyle(color: Colors.white70),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(color: AppColors.cyan),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    'Clear',
                                    style: TextStyle(
                                      color: AppColors.crimsonRed,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await ref
                                .read(familyProvider.notifier)
                                .clearChatHistory();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(right: 12),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.white05,
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            color: AppColors.crimsonRed,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                    GestureDetector(
                      onTap: () async {
                        if (_isVoiceActive) {
                          await ref.read(voiceServiceProvider).leaveChannel();
                          if (mounted) setState(() => _isVoiceActive = false);
                        } else {
                          await _joinVoiceLounge();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isVoiceActive
                              ? AppColors.mintGreen.withValues(alpha: 0.2)
                              : AppColors.white05,
                        ),
                        child: Icon(
                          Icons.headset_mic,
                          color: _isVoiceActive
                              ? AppColors.mintGreen
                              : AppColors.cyan,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Voice Lounge Visuals
              if (_isVoiceActive)
                _VoiceLoungePanel(
                  onEndCall: () {
                    if (mounted) setState(() => _isVoiceActive = false);
                  },
                ),
              // Messages
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    if (_showEmojiPicker) {
                      setState(() => _showEmojiPicker = false);
                    }
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: messages.length,
                    itemBuilder: (_, i) {
                      final msg = messages[messages.length - 1 - i];
                      final user = ref.watch(authProvider).user;
                      final senderRole = family?.members
                          .where((m) => m.userId == msg.senderId)
                          .firstOrNull
                          ?.role
                          .name;
                      return FamilyChatBubble(
                        message: msg,
                        isMe:
                            user != null &&
                            (msg.senderId == user.id ||
                                msg.senderName == user.username),
                        role: senderRole,
                      );
                    },
                  ),
                ),
              ),
              // Input
              Container(
                padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.glassBorder)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _showEmojiPicker
                            ? Icons.keyboard
                            : Icons.emoji_emotions_outlined,
                        color: AppColors.white70,
                      ),
                      onPressed: () {
                        // Close keyboard if open when showing emoji picker
                        if (!_showEmojiPicker) {
                          FocusScope.of(context).unfocus();
                        }
                        setState(() {
                          _showEmojiPicker = !_showEmojiPicker;
                        });
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: _msgController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(color: AppColors.white30),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        if (_msgController.text.trim().isEmpty) return;
                        ref
                            .read(familyProvider.notifier)
                            .sendChatMessage(_msgController.text.trim());
                        _msgController.clear();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppGradients.purpleNeonGradient,
                        ),
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_showEmojiPicker)
                SizedBox(
                  height: 250,
                  child: EmojiPicker(
                    textEditingController: _msgController,
                    config: Config(
                      bottomActionBarConfig: const BottomActionBarConfig(
                        showBackspaceButton: false,
                        showSearchViewButton: false,
                      ),
                      categoryViewConfig: const CategoryViewConfig(
                        backgroundColor: AppColors.background,
                        indicatorColor: AppColors.purpleNeon,
                        iconColorSelected: AppColors.purpleNeon,
                      ),
                      emojiViewConfig: EmojiViewConfig(
                        backgroundColor: AppColors.surface,
                        columns: 7,
                        emojiSizeMax: 28,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VoiceLoungePanel extends ConsumerStatefulWidget {
  final VoidCallback onEndCall;
  const _VoiceLoungePanel({required this.onEndCall, super.key});
  @override
  ConsumerState<_VoiceLoungePanel> createState() => _VoiceLoungePanelState();
}

class _VoiceLoungePanelState extends ConsumerState<_VoiceLoungePanel>
    with SingleTickerProviderStateMixin {
  bool _isMuted = false;
  late AnimationController _pulseController;
  StreamSubscription? _wsSub;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    // Listen for boss mute commands
    _wsSub = ref.read(wsServiceProvider).eventStream.listen((msg) {
      if (msg.event == 'voice_muted') {
        if (mounted) {
          setState(() => _isMuted = true);
          ref.read(voiceServiceProvider).muteMicrophone(true);

          final mutedBy = msg.data['mutedBy'] ?? 'The Boss';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You have been muted by $mutedBy'),
              backgroundColor: AppColors.crimsonRed,
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _wsSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final voiceService = ref.watch(voiceServiceProvider);
    final user = ref.watch(authProvider).user;
    final family = ref.watch(familyProvider).family;
    final isBoss =
        family?.members.any(
          (m) => m.userId == user?.id && m.role == FamilyRole.boss,
        ) ??
        false;

    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.purpleNeon.withValues(alpha: 0.08),
        border: Border(
          bottom: BorderSide(
            color: AppColors.purpleNeon.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<int>>(
              stream: voiceService.channelUsers,
              initialData: const [],
              builder: (context, snapshot) {
                final users = snapshot.data ?? [];
                // Include local user if not present (since Agora might not report local user in remote users list)
                final myUid = user?.id.hashCode.abs() ?? 0;
                final allUsers = {myUid, ...users}.toList();

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: allUsers.length,
                  itemBuilder: (context, index) {
                    final uid = allUsers[index];
                    final isLocal = uid == myUid;

                    return StreamBuilder<List<int>>(
                      stream: voiceService.activeSpeakers,
                      initialData: const [],
                      builder: (context, speakerSnapshot) {
                        return StreamBuilder<Map<int, bool>>(
                          stream: voiceService.mutedUsers,
                          initialData: const {},
                          builder: (context, mutedSnapshot) {
                            final speakers = speakerSnapshot.data ?? [];
                            final isSpeaking = speakers.contains(uid);
                            final mutedMap = mutedSnapshot.data ?? {};
                            final isUserMuted = isLocal
                                ? _isMuted
                                : (mutedMap[uid] == true);

                            return Container(
                              width: 80,
                              margin: const EdgeInsets.only(right: 12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      if (isSpeaking)
                                        AnimatedBuilder(
                                          animation: _pulseController,
                                          builder: (context, child) {
                                            return Container(
                                              width:
                                                  56 +
                                                  (_pulseController.value * 16),
                                              height:
                                                  56 +
                                                  (_pulseController.value * 16),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppColors.mintGreen
                                                    .withValues(
                                                      alpha:
                                                          0.15 *
                                                          (1 -
                                                              _pulseController
                                                                  .value),
                                                    ),
                                                border: Border.all(
                                                  color: AppColors.mintGreen
                                                      .withValues(
                                                        alpha:
                                                            0.6 *
                                                            (1 -
                                                                _pulseController
                                                                    .value),
                                                      ),
                                                  width: 3,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      CircleAvatar(
                                        radius: 28,
                                        backgroundColor: AppColors.surface,
                                        child: Icon(
                                          Icons.person,
                                          color: isLocal
                                              ? AppColors.purpleNeon
                                              : AppColors.cyan,
                                          size: 30,
                                        ),
                                      ),
                                      if (isUserMuted)
                                        Container(
                                          width: 56,
                                          height: 56,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.black.withValues(
                                              alpha: 0.5,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.mic_off,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                      if (isSpeaking && !isUserMuted)
                                        Positioned(
                                          bottom: 0,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.background,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: AppColors.mintGreen
                                                    .withValues(alpha: 0.5),
                                              ),
                                            ),
                                            child: WaveformIndicator(
                                              isActive: true,
                                              color: AppColors.mintGreen,
                                              width: 24,
                                              height: 10,
                                            ),
                                          ),
                                        ),
                                      if (isBoss && !isLocal)
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: GestureDetector(
                                            onTap: () {
                                              final targetUser = family!.members
                                                  .firstWhere(
                                                    (m) =>
                                                        m.userId.hashCode
                                                            .abs() ==
                                                        uid,
                                                    orElse: () =>
                                                        family!.members.first,
                                                  );
                                              ref
                                                  .read(wsServiceProvider)
                                                  .sendMuteRequest(
                                                    targetUser.userId,
                                                  );

                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Sent mute command to ${targetUser.username}',
                                                  ),
                                                  duration: const Duration(
                                                    seconds: 1,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppColors.crimsonRed
                                                    .withValues(alpha: 0.9),
                                                border: Border.all(
                                                  color: AppColors.background,
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: const Icon(
                                                Icons.mic_off,
                                                color: Colors.white,
                                                size: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    isLocal
                                        ? 'You'
                                        : (family?.members
                                                  .where(
                                                    (m) =>
                                                        m.userId.hashCode
                                                            .abs() ==
                                                        uid,
                                                  )
                                                  .firstOrNull
                                                  ?.username ??
                                              'User'),
                                    style: TextStyle(
                                      color: isSpeaking
                                          ? AppColors.mintGreen
                                          : Colors.white70,
                                      fontSize: 11,
                                      fontWeight: isSpeaking
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          // Local Controls
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _VoiceControlBtn(
                  icon: _isMuted ? Icons.mic_off : Icons.mic,
                  color: _isMuted ? AppColors.crimsonRed : AppColors.mintGreen,
                  onTap: () {
                    setState(() => _isMuted = !_isMuted);
                    voiceService.muteMicrophone(_isMuted);
                  },
                ),
                if (isBoss) ...[
                  const SizedBox(width: 20),
                  _VoiceControlBtn(
                    icon: Icons.call_end,
                    color: AppColors.crimsonRed,
                    onTap: () async {
                      await ref.read(voiceServiceProvider).leaveChannel();
                      widget.onEndCall();
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VoiceControlBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _VoiceControlBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}
