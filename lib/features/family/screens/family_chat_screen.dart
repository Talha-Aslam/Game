import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../providers/family_provider.dart';
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

  @override
  void dispose() { _msgController.dispose(); _scrollController.dispose(); super.dispose(); }

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
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(
            shape: BoxShape.circle, color: AppColors.white05),
            child: const Icon(Icons.headset_mic, color: AppColors.cyan, size: 18)),
        ])),
        // Messages
        Expanded(child: ListView.builder(
          controller: _scrollController, reverse: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: messages.length,
          itemBuilder: (_, i) {
            final msg = messages[messages.length - 1 - i];
            return FamilyChatBubble(message: msg, isMe: msg.senderId == 'local_user');
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
