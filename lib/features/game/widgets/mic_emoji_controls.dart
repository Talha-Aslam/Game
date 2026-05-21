import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Master mic button + emoji wheel
class MicEmojiControls extends StatefulWidget {
  final bool isMuted;
  final bool isSpeaking;
  final VoidCallback? onToggleMic;
  final ValueChanged<String>? onEmojiSend;

  const MicEmojiControls({
    super.key, required this.isMuted, this.isSpeaking = false,
    this.onToggleMic, this.onEmojiSend,
  });

  @override
  State<MicEmojiControls> createState() => _MicEmojiControlsState();
}

class _MicEmojiControlsState extends State<MicEmojiControls>
    with TickerProviderStateMixin {
  late AnimationController _micPulse;
  late AnimationController _emojiWheel;
  bool _showEmojis = false;

  static const _emojis = ['🤔', '😇', '💀', '😂', '😡', '👏'];

  @override
  void initState() {
    super.initState();
    _micPulse = AnimationController(duration: const Duration(milliseconds: 800), vsync: this)..repeat(reverse: true);
    _emojiWheel = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
  }

  @override
  void dispose() { _micPulse.dispose(); _emojiWheel.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      // Emoji button + wheel
      Stack(clipBehavior: Clip.none, children: [
        // Emoji wheel (radial)
        if (_showEmojis)
          ...List.generate(_emojis.length, (i) {
            final angle = -(pi / 2) - (i / (_emojis.length - 1)) * (pi / 1.5);
            final radius = 64.0;
            return Positioned(
              left: 20 + cos(angle) * radius - 16,
              top: 20 + sin(angle) * radius - 16,
              child: AnimatedBuilder(animation: _emojiWheel, builder: (_, __) {
                final delay = i / _emojis.length;
                final t = ((_emojiWheel.value - delay) * 2).clamp(0.0, 1.0);
                return Transform.scale(
                  scale: Curves.elasticOut.transform(t),
                  child: GestureDetector(
                    onTap: () {
                      widget.onEmojiSend?.call(_emojis[i]);
                      setState(() => _showEmojis = false);
                      _emojiWheel.reverse();
                    },
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle, color: AppColors.surface,
                        border: Border.all(color: AppColors.glassBorder),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8)]),
                      child: Center(child: Text(_emojis[i], style: const TextStyle(fontSize: 16))),
                    ),
                  ),
                );
              }),
            );
          }),

        // Emoji trigger button
        GestureDetector(
          onTap: () {
            setState(() => _showEmojis = !_showEmojis);
            _showEmojis ? _emojiWheel.forward() : _emojiWheel.reverse();
          },
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, color: AppColors.white05,
                  border: Border.all(color: AppColors.glassBorder)),
                child: const Icon(Icons.emoji_emotions_outlined, color: AppColors.white50, size: 20)),
            ),
          ),
        ),
      ]),
      const SizedBox(height: 10),
      // Master mic button
      AnimatedBuilder(animation: _micPulse, builder: (_, __) {
        final p = _micPulse.value;
        final isActive = !widget.isMuted && widget.isSpeaking;
        final micColor = widget.isMuted ? AppColors.crimsonRed : AppColors.mintGreen;

        return GestureDetector(
          onTap: widget.onToggleMic,
          child: Container(
            width: 54, height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: micColor.withValues(alpha: 0.08),
              border: Border.all(color: micColor.withValues(alpha: 0.3 + (isActive ? p * 0.2 : 0)), width: 2),
              boxShadow: [BoxShadow(
                color: micColor.withValues(alpha: isActive ? 0.2 + p * 0.15 : 0.08),
                blurRadius: isActive ? 16 + p * 8 : 10, spreadRadius: -2)],
            ),
            child: Stack(alignment: Alignment.center, children: [
              Icon(widget.isMuted ? Icons.mic_off : Icons.mic,
                color: micColor, size: 24),
              if (widget.isMuted) Positioned(
                child: Transform.rotate(angle: -pi / 4, child: Container(
                  width: 28, height: 2, color: AppColors.crimsonRed.withValues(alpha: 0.6)))),
            ]),
          ),
        );
      }),
    ]);
  }
}
