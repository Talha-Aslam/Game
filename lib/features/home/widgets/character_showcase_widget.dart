import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Character showcase with animated silhouette, ambient particles, cinematic drift
class CharacterShowcaseWidget extends StatefulWidget {
  const CharacterShowcaseWidget({super.key});
  @override
  State<CharacterShowcaseWidget> createState() => _CharacterShowcaseWidgetState();
}

class _CharacterShowcaseWidgetState extends State<CharacterShowcaseWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(duration: const Duration(seconds: 6), vsync: this)..repeat();
  }

  @override
  void dispose() { _anim.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(animation: _anim, builder: (_, __) {
      final t = _anim.value;
      final floatY = sin(t * 2 * pi) * 4;
      final breathe = 0.95 + sin(t * 2 * pi) * 0.02;
      return SizedBox(
        height: 220,
        child: Stack(alignment: Alignment.center, children: [
          // Ambient glow
          Positioned(bottom: 20, child: Container(
            width: 160, height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              boxShadow: [BoxShadow(
                color: AppColors.purpleNeon.withValues(alpha: 0.15 + sin(t * 2 * pi) * 0.05),
                blurRadius: 40, spreadRadius: 10)]),
          )),
          // Character silhouette with floating + breathing
          Transform.translate(offset: Offset(0, floatY), child:
            Transform.scale(scale: breathe, child: _CharacterSilhouette(phase: t))),
          // Particle effects
          ...List.generate(6, (i) {
            final angle = (t + i / 6.0) * 2 * pi;
            final radius = 60.0 + sin(angle * 2) * 15;
            return Positioned(
              left: MediaQuery.of(context).size.width / 2 - 10 + cos(angle) * radius,
              top: 110 + sin(angle) * radius * 0.4,
              child: Opacity(opacity: 0.3 + sin(t * 2 * pi + i) * 0.15,
                child: Container(width: 3, height: 3, decoration: BoxDecoration(
                  shape: BoxShape.circle, color: AppColors.purpleGlow))),
            );
          }),
          // Title
          Positioned(bottom: 0, child: Column(children: [
            const Text('EQUIPPED SKIN', style: TextStyle(
              color: AppColors.white10, fontSize: 8, fontWeight: FontWeight.w600, letterSpacing: 2)),
            const SizedBox(height: 2),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppColors.purpleGlow, AppColors.cyan]).createShader(bounds),
              child: const Text('Shadow Boss', style: TextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1)),
            ),
          ])),
        ]),
      );
    });
  }
}

/// Stylized mafia boss silhouette using CustomPainter
class _CharacterSilhouette extends StatelessWidget {
  final double phase;
  const _CharacterSilhouette({required this.phase});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120, height: 180,
      child: CustomPaint(painter: _SilhouettePainter(phase: phase)),
    );
  }
}

class _SilhouettePainter extends CustomPainter {
  final double phase;
  _SilhouettePainter({required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width; final h = size.height;
    final cx = w / 2;

    // Body gradient
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [
          AppColors.purpleNeon.withValues(alpha: 0.6),
          AppColors.purpleDeep.withValues(alpha: 0.3),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    // Head
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, h * 0.12), width: 32, height: 36), bodyPaint);

    // Hat brim
    final hatPaint = Paint()..color = AppColors.purpleNeon.withValues(alpha: 0.5);
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, h * 0.06), width: 50, height: 10),
      const Radius.circular(5)), hatPaint);

    // Hat crown
    canvas.drawRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, h * 0.01), width: 30, height: 14),
      const Radius.circular(4)), hatPaint);

    // Shoulders + body
    final bodyPath = Path()
      ..moveTo(cx - 22, h * 0.2)
      ..quadraticBezierTo(cx - 40, h * 0.3, cx - 35, h * 0.55)
      ..lineTo(cx - 20, h * 0.85)
      ..lineTo(cx + 20, h * 0.85)
      ..lineTo(cx + 35, h * 0.55)
      ..quadraticBezierTo(cx + 40, h * 0.3, cx + 22, h * 0.2)
      ..close();
    canvas.drawPath(bodyPath, bodyPaint);

    // Collar / tie accent
    final accentPaint = Paint()..color = AppColors.gold.withValues(alpha: 0.3 + sin(phase * 2 * pi) * 0.1);
    canvas.drawLine(Offset(cx, h * 0.2), Offset(cx, h * 0.4), accentPaint..strokeWidth = 2);

    // Eye glints
    final eyePaint = Paint()..color = AppColors.purpleGlow.withValues(alpha: 0.6 + sin(phase * 2 * pi) * 0.2);
    canvas.drawCircle(Offset(cx - 6, h * 0.11), 2, eyePaint);
    canvas.drawCircle(Offset(cx + 6, h * 0.11), 2, eyePaint);
  }

  @override
  bool shouldRepaint(covariant _SilhouettePainter old) => true;
}
