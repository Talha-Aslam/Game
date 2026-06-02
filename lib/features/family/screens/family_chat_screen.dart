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
                    GestureDetector(
                      onTap: () async {
                        if (_isVoiceActive) {
                          await ref.read(voiceServiceProvider).leaveChannel();
                          if (mounted) setState(() => _isVoiceActive = false);
                        } else {
                          final family = ref.read(familyProvider).family;
                          final user = ref.read(authProvider).user;
                          if (family != null && user != null) {
                            final messenger = ScaffoldMessenger.of(context);
                            final channelName = 'family_${family.id}';
                            try {
                              final token = await FamilyApiService()
                                  .getVoiceToken(channelName);
                              await ref
                                  .read(voiceServiceProvider)
                                  .joinChannel(token, channelName, user.id);
                              if (mounted)
                                setState(() => _isVoiceActive = true);
                            } catch (e) {
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to join voice chat'),
                                ),
                              );
                            }
                          }
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
              if (_isVoiceActive) const _VoiceLoungePanel(),
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
                    return FamilyChatBubble(
                      message: msg,
                      isMe:
                          user != null &&
                          (msg.senderId == user.id ||
                              msg.senderName == user.username),
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
                      icon: Icon(_showEmojiPicker ? Icons.keyboard : Icons.emoji_emotions_outlined, color: AppColors.white70),
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
                      bottomActionBarConfig: const BottomActionBarConfig(showBackspaceButton: false, showSearchViewButton: false),
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
  const _VoiceLoungePanel();
  @override
  ConsumerState<_VoiceLoungePanel> createState() => _VoiceLoungePanelState();
}

class _VoiceLoungePanelState extends ConsumerState<_VoiceLoungePanel>
    with SingleTickerProviderStateMixin {
  bool _isMuted = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
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
      height: 180,
      width: double.infinity,
      color: AppColors.purpleNeon.withValues(alpha: 0.1),
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
                  padding: const EdgeInsets.all(16),
                  itemCount: allUsers.length,
                  itemBuilder: (context, index) {
                    final uid = allUsers[index];
                    final isLocal = uid == myUid;

                    return StreamBuilder<List<int>>(
                      stream: voiceService.activeSpeakers,
                      initialData: const [],
                      builder: (context, speakerSnapshot) {
                        final speakers = speakerSnapshot.data ?? [];
                        final isSpeaking = speakers.contains(uid);

                        return Container(
                          margin: const EdgeInsets.only(right: 16),
                          child: Column(
                            children: [
                              AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  return Container(
                                    padding: EdgeInsets.all(
                                      isSpeaking
                                          ? 4.0 + (_pulseController.value * 4.0)
                                          : 4.0,
                                    ),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSpeaking
                                          ? AppColors.mintGreen.withValues(
                                              alpha: 0.3,
                                            )
                                          : Colors.transparent,
                                    ),
                                    child: CircleAvatar(
                                      radius: 24,
                                      backgroundColor: AppColors.surface,
                                      child: Icon(
                                        Icons.person,
                                        color: isLocal
                                            ? AppColors.purpleNeon
                                            : AppColors.cyan,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isLocal ? 'You' : 'User',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                              if (isBoss && !isLocal)
                                GestureDetector(
                                  onTap: () {
                                    // Simulated boss mute (in real app, call API to mute remote user globally)
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Muted user'),
                                      ),
                                    );
                                  },
                                  child: const Icon(
                                    Icons.mic_off,
                                    color: AppColors.crimsonRed,
                                    size: 14,
                                  ),
                                ),
                            ],
                          ),
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
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    _isMuted ? Icons.mic_off : Icons.mic,
                    color: _isMuted
                        ? AppColors.crimsonRed
                        : AppColors.mintGreen,
                  ),
                  onPressed: () {
                    setState(() => _isMuted = !_isMuted);
                    voiceService.muteMicrophone(_isMuted);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
