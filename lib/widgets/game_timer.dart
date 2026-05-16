import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';

/// Central countdown timer with pulsing effects
class GameTimer extends StatefulWidget {
  final int seconds;
  final Color? color;

  const GameTimer({super.key, required this.seconds, this.color});

  @override
  State<GameTimer> createState() => _GameTimerState();
}

class _GameTimerState extends State<GameTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUrgent = widget.seconds <= 5;
    final color = widget.color ??
        (isUrgent ? AppColors.crimsonRed : AppColors.white);

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        final scale = isUrgent
            ? 1.0 + (_pulseController.value * 0.1)
            : 1.0;

        return Transform.scale(
          scale: scale,
          child: Text(
            '${widget.seconds}',
            style: GoogleFonts.outfit(
              fontSize: 56,
              fontWeight: FontWeight.w800,
              color: color,
              shadows: [
                Shadow(
                  color: color.withValues(alpha: isUrgent ? 0.8 : 0.3),
                  blurRadius: isUrgent ? 30 : 10,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
