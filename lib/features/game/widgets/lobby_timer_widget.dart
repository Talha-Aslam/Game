import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/game_state_model.dart';

/// Premium animated countdown ring with circular depletion
class LobbyTimerWidget extends StatefulWidget {
  final int seconds;
  final int maxSeconds;
  final GamePhase phase;

  const LobbyTimerWidget({
    super.key, required this.seconds, this.maxSeconds = 60, required this.phase,
  });

  @override
  State<LobbyTimerWidget> createState() => _LobbyTimerWidgetState();
}

class _LobbyTimerWidgetState extends State<LobbyTimerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() { super.initState(); _pulse = AnimationController(duration: const Duration(seconds: 1), vsync: this)..repeat(reverse: true); }
  @override
  void dispose() { _pulse.dispose(); super.dispose(); }

  Color get _timerColor {
    if (widget.seconds <= 5) return AppColors.crimsonRed;
    switch (widget.phase) {
      case GamePhase.night: return AppColors.purpleGlow;
      case GamePhase.morningReveal: return AppColors.gold;
      case GamePhase.day: return AppColors.gold;
      case GamePhase.voting: return AppColors.cyan;
      case GamePhase.runoff: return AppColors.crimsonRed;
      case GamePhase.roleAssignment: return AppColors.purpleNeon;
      case GamePhase.elimination: return AppColors.crimsonRed;
      default: return AppColors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isUrgent = widget.seconds <= 5;
    final color = _timerColor;
    final progress = widget.maxSeconds > 0
        ? (widget.seconds / widget.maxSeconds).clamp(0.0, 1.0)
        : 0.0;

    return AnimatedBuilder(animation: _pulse, builder: (_, _) {
      final p = _pulse.value;
      final scale = isUrgent ? 1.0 + p * 0.08 : 1.0;

      return Transform.scale(scale: scale, child: SizedBox(
        width: 90, height: 90,
        child: Stack(alignment: Alignment.center, children: [
          // Outer glow ring
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(shape: BoxShape.circle,
              boxShadow: [BoxShadow(
                color: color.withValues(alpha: 0.15 + (isUrgent ? p * 0.12 : 0)),
                blurRadius: 20, spreadRadius: -2)]),
          ),
          // Circular progress ring
          CustomPaint(
            size: const Size(82, 82),
            painter: _RingPainter(progress: progress, color: color, glowAlpha: isUrgent ? 0.5 + p * 0.3 : 0.4)),
          // Timer text
          Text('${widget.seconds}', style: GoogleFonts.cinzel(
            fontSize: 36, fontWeight: FontWeight.w800, color: color,
            shadows: [Shadow(color: color.withValues(alpha: isUrgent ? 0.6 + p * 0.3 : 0.3), blurRadius: isUrgent ? 20 : 8)])),
        ]),
      ));
    });
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double glowAlpha;
  _RingPainter({required this.progress, required this.color, this.glowAlpha = 0.4});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    // Background ring
    canvas.drawCircle(center, radius, Paint()
      ..color = AppColors.white05 ..style = PaintingStyle.stroke ..strokeWidth = 3);

    // Progress arc
    final sweepAngle = 2 * pi * progress;
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, -pi / 2, sweepAngle, false, Paint()
      ..color = color ..style = PaintingStyle.stroke ..strokeWidth = 3 ..strokeCap = StrokeCap.round);

    // Glow overlay
    canvas.drawArc(rect, -pi / 2, sweepAngle, false, Paint()
      ..color = color.withValues(alpha: glowAlpha)
      ..style = PaintingStyle.stroke ..strokeWidth = 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.color != color;
}
