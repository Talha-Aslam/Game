import 'package:flutter/material.dart';

/// Text with neon glow shadow effect
class NeonText extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;
  final FontWeight fontWeight;
  final double glowRadius;
  final TextAlign textAlign;

  const NeonText({
    super.key,
    required this.text,
    this.color = const Color(0xFF9B59FF),
    this.fontSize = 24,
    this.fontWeight = FontWeight.w700,
    this.glowRadius = 20,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: 2,
        shadows: [
          Shadow(color: color.withValues(alpha: 0.8), blurRadius: glowRadius),
          Shadow(color: color.withValues(alpha: 0.4), blurRadius: glowRadius * 2),
          Shadow(color: color.withValues(alpha: 0.2), blurRadius: glowRadius * 3),
        ],
      ),
    );
  }
}
