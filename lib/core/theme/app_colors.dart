import 'package:flutter/material.dart';

/// Core color palette for City Of Lies
/// Dark futuristic aesthetic with neon accents
class AppColors {
  AppColors._();

  // ── Backgrounds ──
  static const Color background = Color(0xFF06060E);
  static const Color surface = Color(0xFF0D0D1A);
  static const Color surfaceLight = Color(0xFF141428);
  static const Color cardDark = Color(0xFF0A0A18);

  // ── Primary ──
  static const Color purpleNeon = Color(0xFF9B59FF);
  static const Color purpleDeep = Color(0xFF6C3CE0);
  static const Color purpleGlow = Color(0xFFBB86FC);

  // ── Accents ──
  static const Color gold = Color(0xFFFFD700);
  static const Color goldDark = Color(0xFFB8860B);
  static const Color cyan = Color(0xFF00E5FF);
  static const Color cyanDeep = Color(0xFF00B4D8);
  static const Color mintGreen = Color(0xFF00F5A0);
  static const Color crimsonRed = Color(0xFFFF1744);
  static const Color crimsonDeep = Color(0xFFD50000);

  // ── Neutrals ──
  static const Color white = Color(0xFFFFFFFF);
  static const Color white70 = Color(0xB3FFFFFF);
  static const Color white50 = Color(0x80FFFFFF);
  static const Color white30 = Color(0x4DFFFFFF);
  static const Color white10 = Color(0x1AFFFFFF);
  static const Color white05 = Color(0x0DFFFFFF);
  static const Color charcoal = Color(0xFF1A1A2E);
  static const Color darkGrey = Color(0xFF2D2D44);

  // ── Glass ──
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassBackground = Color(0x14FFFFFF);
  static const Color glassBackgroundDark = Color(0x0AFFFFFF);

  // ── Role Colors ──
  static const Color mafiaColor = crimsonRed;
  static const Color doctorColor = mintGreen;
  static const Color detectiveColor = purpleNeon;
  static const Color civilianColor = cyan;

  // ── Status ──
  static const Color online = Color(0xFF00E676);
  static const Color offline = Color(0xFF616161);
  static const Color inGame = Color(0xFFFF9100);
}
