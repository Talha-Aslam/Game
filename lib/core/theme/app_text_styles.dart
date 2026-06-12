import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Premium typography using Outfit (headings) and Inter (body)
class AppTextStyles {
  AppTextStyles._();

  // ── Headings (Outfit) ──
  static TextStyle get displayLarge => GoogleFonts.cinzel(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        color: AppColors.white,
        letterSpacing: -1.5,
      );

  static TextStyle get displayMedium => GoogleFonts.cinzel(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
        letterSpacing: -1.0,
      );

  static TextStyle get displaySmall => GoogleFonts.cinzel(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
        letterSpacing: -0.5,
      );

  static TextStyle get headlineLarge => GoogleFonts.cinzel(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
      );

  static TextStyle get headlineMedium => GoogleFonts.cinzel(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      );

  static TextStyle get headlineSmall => GoogleFonts.cinzel(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      );

  // ── Body (Inter) ──
  static TextStyle get bodyLarge => GoogleFonts.cinzel(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.white70,
      );

  static TextStyle get bodyMedium => GoogleFonts.cinzel(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.white70,
      );

  static TextStyle get bodySmall => GoogleFonts.cinzel(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.white50,
      );

  // ── Labels ──
  static TextStyle get labelLarge => GoogleFonts.cinzel(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
        letterSpacing: 0.5,
      );

  static TextStyle get labelMedium => GoogleFonts.cinzel(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.white70,
        letterSpacing: 0.3,
      );

  static TextStyle get labelSmall => GoogleFonts.cinzel(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.white50,
        letterSpacing: 0.2,
      );

  // ── Special ──
  static TextStyle get neonTitle => GoogleFonts.cinzel(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: AppColors.purpleNeon,
        letterSpacing: 2.0,
        shadows: [
          Shadow(
            color: AppColors.purpleNeon.withValues(alpha: 0.6),
            blurRadius: 20,
          ),
          Shadow(
            color: AppColors.purpleNeon.withValues(alpha: 0.3),
            blurRadius: 40,
          ),
        ],
      );

  static TextStyle get timerText => GoogleFonts.cinzel(
        fontSize: 56,
        fontWeight: FontWeight.w800,
        color: AppColors.white,
      );

  static TextStyle get phaseTitle => GoogleFonts.cinzel(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
        letterSpacing: 3.0,
      );

  static TextStyle get goldText => GoogleFonts.cinzel(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.gold,
        shadows: [
          Shadow(
            color: AppColors.gold.withValues(alpha: 0.5),
            blurRadius: 10,
          ),
        ],
      );
}
