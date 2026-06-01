import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../models/social/friend_model.dart';
import '../../../models/social/private_chat_message.dart';
import '../../../providers/social_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../providers/game_provider.dart';
import '../../../providers/auth_provider.dart';

class PrivateChatScreen extends ConsumerStatefulWidget {
  final FriendModel friend;

  const PrivateChatScreen({super.key, required this.friend});

  @override
  ConsumerState<PrivateChatScreen> createState() => _PrivateChatScreenState();
}

class _PrivateChatScreenState extends ConsumerState<PrivateChatScreen> {
  final _msgController = TextEditingController();
  final _scrollController = ScrollController();
  List<PrivateChatMessage> _messages = [];
  bool _isLoading = true;
  StreamSubscription? _wsSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activeChatFriendIdProvider.notifier).state = widget.friend.id;
      ref
          .read(notificationProvider.notifier)
          .markMessagesRead(widget.friend.id);
    });
    _loadHistory();
    _initWebSocket();
  }

  Future<void> _loadHistory() async {
    final service = ref.read(socialServiceProvider);
    final history = await service.getPrivateChatHistory(widget.friend.id);
    if (mounted) {
      setState(() {
        _messages = history;
        _isLoading = false;
      });
    }
  }

  void _initWebSocket() {
    final ws = ref.read(wsServiceProvider);
    _wsSubscription = ws.eventStream.listen((msg) {
      if (msg.event == 'private_message') {
        final data = msg.data;
        if (data.isNotEmpty) {
          final newMsg = PrivateChatMessage.fromJson(data);
          // Only add if it's from the friend or from us to the friend
          if (newMsg.senderId == widget.friend.id ||
              newMsg.senderId == ref.read(authProvider).user?.id) {
            if (mounted) {
              setState(() {
                _messages.insert(0, newMsg);
              });
            }
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    _wsSubscription?.cancel();
    // Clear active chat when leaving screen
    Future.microtask(() {
      try {
        ref.read(activeChatFriendIdProvider.notifier).state = null;
      } catch (_) {}
    });
    super.dispose();
  }

  void _sendMessage() {
    final content = _msgController.text.trim();
    if (content.isEmpty) return;

    final ws = ref.read(wsServiceProvider);
    ws.send('private_message', {
      'targetId': widget.friend.id,
      'content': content,
    });

    _msgController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final localUserId = ref.watch(authProvider).user?.id;

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
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.purpleNeon.withValues(
                        alpha: 0.2,
                      ),
                      child: Text(
                        widget.friend.username[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.purpleNeon,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.friend.username,
                          style: AppTextStyles.headlineSmall,
                        ),
                        Text(
                          widget.friend.isOnline ? 'Online' : 'Offline',
                          style: TextStyle(
                            color: widget.friend.isOnline
                                ? AppColors.online
                                : AppColors.white30,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Messages
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.purpleNeon,
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _messages.length,
                        itemBuilder: (_, i) {
                          final msg = _messages[i];
                          final isMe = msg.senderId == localUserId;
                          return _ChatBubble(message: msg, isMe: isMe);
                        },
                      ),
              ),

              // Input
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.glassBorder)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _msgController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Message...',
                          hintStyle: TextStyle(color: AppColors.white30),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    GestureDetector(
                      onTap: _sendMessage,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
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
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final PrivateChatMessage message;
  final bool isMe;

  const _ChatBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe
              ? AppColors.purpleNeon.withValues(alpha: 0.2)
              : AppColors.white05,
          border: Border.all(
            color: isMe
                ? AppColors.purpleNeon.withValues(alpha: 0.3)
                : AppColors.white10,
          ),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
        ),
        child: Text(
          message.content,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontFamilyFallback: [
              'Apple Color Emoji',
              'Segoe UI Emoji',
              'Noto Color Emoji',
            ],
          ),
        ),
      ),
    );
  }
}
