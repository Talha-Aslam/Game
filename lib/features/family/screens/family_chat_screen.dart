import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../providers/family_provider.dart';
import '../../../providers/game_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/family_api_service.dart';
import '../widgets/family_chat_bubble.dart';

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
    return Scaffold(body: Container(
      decoration: const BoxDecoration(gradient: AppGradients.backgroundGradient),
      child: SafeArea(child: Column(children: [
        // Header
        Padding(padding: const EdgeInsets.all(16), child: Row(children: [
          GestureDetector(onTap: () => context.pop(),
            child: const Icon(Icons.arrow_back, color: AppColors.white70)),
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
                    final token = await FamilyApiService().getVoiceToken(channelName);
                    await ref.read(voiceServiceProvider).joinChannel(token, channelName, user.id);
                    if (mounted) setState(() => _isVoiceActive = true);
                  } catch (e) {
                    messenger.showSnackBar(const SnackBar(content: Text('Failed to join voice chat')));
                  }
                }
              }
            },
            child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(
              shape: BoxShape.circle, color: _isVoiceActive ? AppColors.mintGreen.withValues(alpha: 0.2) : AppColors.white05),
              child: Icon(Icons.headset_mic, color: _isVoiceActive ? AppColors.mintGreen : AppColors.cyan, size: 18)),
          ),
        ])),
        // Messages
        Expanded(child: ListView.builder(
          controller: _scrollController, reverse: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: messages.length,
          itemBuilder: (_, i) {
            final msg = messages[messages.length - 1 - i];
            final user = ref.watch(authProvider).user;
            return FamilyChatBubble(message: msg, isMe: user != null && msg.senderId == user.id);
          },
        )),
        // Input
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          decoration: BoxDecoration(color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.glassBorder))),
          child: Row(children: [
            Expanded(child: TextField(controller: _msgController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(hintText: 'Type a message...',
                hintStyle: TextStyle(color: AppColors.white30), border: InputBorder.none))),
            GestureDetector(
              onTap: () {
                if (_msgController.text.trim().isEmpty) return;
                ref.read(familyProvider.notifier).sendChatMessage(_msgController.text.trim());
                _msgController.clear();
              },
              child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(
                shape: BoxShape.circle, gradient: AppGradients.purpleNeonGradient),
                child: const Icon(Icons.send, color: Colors.white, size: 18))),
          ]),
        ),
      ])),
    ));
  }
}
