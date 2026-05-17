import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Animated typing indicator
class ChatTypingIndicator extends StatefulWidget {
  final String username;
  const ChatTypingIndicator({super.key, required this.username});

  @override
  State<ChatTypingIndicator> createState() => _ChatTypingIndicatorState();
}

class _ChatTypingIndicatorState extends State<ChatTypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this)..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text('${widget.username} is typing', style: const TextStyle(
          color: AppColors.white30, fontSize: 10, fontStyle: FontStyle.italic)),
        const SizedBox(width: 4),
        ...List.generate(3, (i) => AnimatedBuilder(animation: _ctrl,
          builder: (_, __) {
            final offset = ((_ctrl.value * 3 - i) % 3).clamp(0.0, 1.0);
            return Container(
              width: 4, height: 4, margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: AppColors.cyan.withValues(alpha: 0.3 + offset * 0.5)),
            );
          },
        )),
      ]),
    );
  }
}
