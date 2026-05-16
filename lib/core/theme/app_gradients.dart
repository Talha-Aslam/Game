import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Cinematic gradient presets used throughout City Of Lies
class AppGradients {
  AppGradients._();

  // ── Background Gradients ──
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF06060E),
      Color(0xFF0A0A1A),
      Color(0xFF0E0E24),
      Color(0xFF06060E),
    ],
  );

  static const RadialGradient backgroundRadial = RadialGradient(
    center: Alignment.center,
    radius: 1.2,
    colors: [
      Color(0xFF1A0A2E),
      Color(0xFF06060E),
    ],
  );

  // ── Card Gradients ──
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x1A9B59FF),
      Color(0x0D00E5FF),
    ],
  );

  static const LinearGradient goldCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x33FFD700),
      Color(0x1AB8860B),
    ],
  );

  // ── Neon Gradients ──
  static const LinearGradient purpleNeonGradient = LinearGradient(
    colors: [AppColors.purpleNeon, AppColors.purpleDeep],
  );

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [AppColors.cyan, AppColors.cyanDeep],
  );

  static const LinearGradient crimsonGradient = LinearGradient(
    colors: [AppColors.crimsonRed, AppColors.crimsonDeep],
  );

  static const LinearGradient mintGradient = LinearGradient(
    colors: [AppColors.mintGreen, Color(0xFF00C853)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [AppColors.gold, AppColors.goldDark],
  );

  // ── Overlay Gradients ──
  static const LinearGradient nightOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xCC000010),
      Color(0xE6000008),
    ],
  );

  static const LinearGradient dayOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x33FFD700),
      Color(0x00000000),
    ],
  );

  // ── Button Gradients ──
  static const LinearGradient primaryButton = LinearGradient(
    colors: [AppColors.purpleNeon, AppColors.purpleDeep],
  );

  static const LinearGradient dangerButton = LinearGradient(
    colors: [AppColors.crimsonRed, AppColors.crimsonDeep],
  );

  // ── Phase Gradients ──
  static LinearGradient phaseGradient(Color color) {
    return LinearGradient(
      colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.05)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }
}
