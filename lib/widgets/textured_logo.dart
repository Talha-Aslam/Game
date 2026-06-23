import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TexturedLogo extends StatelessWidget {
  const TexturedLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTexturedWord(
          'MAFIA',
          fontSize: 68,
          gradient: const LinearGradient(
            colors: [Color(0xFFB8860B), Color(0xFFFFE066), Color(0xFFDAA520), Color(0xFFB8860B)],
            stops: [0.0, 0.4, 0.7, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          shadowColor: const Color(0x66FFD700),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 50, height: 2, color: const Color(0xFFDAA520)),
            const SizedBox(width: 16),
            _buildTexturedWord(
              'AT',
              fontSize: 32,
              gradient: const LinearGradient(
                colors: [Color(0xFFB8860B), Color(0xFFFFE066), Color(0xFFDAA520), Color(0xFFB8860B)],
                stops: [0.0, 0.4, 0.7, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              shadowColor: const Color(0x66FFD700),
              letterSpacing: 2,
            ),
            const SizedBox(width: 16),
            Container(width: 50, height: 2, color: const Color(0xFFDAA520)),
          ],
        ),
        _buildTexturedWord(
          'CITY',
          fontSize: 72,
          gradient: const LinearGradient(
            colors: [Color(0xFF6C3CE0), Color(0xFFD4B5FF), Color(0xFF9B59FF), Color(0xFF4A148C)],
            stops: [0.0, 0.3, 0.6, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          shadowColor: const Color(0x669B59FF),
        ),
      ],
    );
  }

  Widget _buildTexturedWord(
    String text, {
    required double fontSize,
    required Gradient gradient,
    required Color shadowColor,
    double letterSpacing = 4,
  }) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        style: GoogleFonts.cinzel(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: letterSpacing,
          shadows: [
            Shadow(color: shadowColor, blurRadius: 15),
            Shadow(color: shadowColor.withValues(alpha: 0.3), blurRadius: 30),
          ],
        ),
      ),
    );
  }
}
