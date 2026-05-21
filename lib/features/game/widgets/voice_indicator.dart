import 'package:flutter/material.dart';

class VoiceIndicator extends StatefulWidget {
  final Stream<List<int>> activeSpeakersStream;
  final String userId;
  final Widget child;

  const VoiceIndicator({
    Key? key,
    required this.activeSpeakersStream,
    required this.userId,
    required this.child,
  }) : super(key: key);

  @override
  State<VoiceIndicator> createState() => _VoiceIndicatorState();
}

class _VoiceIndicatorState extends State<VoiceIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    widget.activeSpeakersStream.listen((activeIds) {
      if (!mounted) return;
      int uid = widget.userId.hashCode.abs();
      bool speaking = activeIds.contains(uid);
      
      if (speaking && !_isSpeaking) {
        setState(() => _isSpeaking = true);
        _pulseController.repeat(reverse: true);
      } else if (!speaking && _isSpeaking) {
        setState(() => _isSpeaking = false);
        _pulseController.stop();
        _pulseController.animateTo(0.0);
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isSpeaking ? _pulseAnimation.value : 1.0,
          child: Container(
            decoration: _isSpeaking
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.greenAccent.withOpacity(0.6),
                        blurRadius: 15,
                        spreadRadius: 5,
                      ),
                    ],
                    border: Border.all(color: Colors.greenAccent, width: 3),
                  )
                : null,
            child: widget.child,
          ),
        );
      },
    );
  }
}
