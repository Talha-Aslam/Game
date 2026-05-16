import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Premium typography using Outfit (headings) and Inter (body)
class AppTextStyles {
  AppTextStyles._();

  // ── Headings (Outfit) ──
  static TextStyle get displayLarge => GoogleFonts.outfit(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        color: AppColors.white,
        letterSpacing: -1.5,
      );

  static TextStyle get displayMedium => GoogleFonts.outfit(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
        letterSpacing: -1.0,
      );

  static TextStyle get displaySmall => GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
        letterSpacing: -0.5,
      );

  static TextStyle get headlineLarge => GoogleFonts.outfit(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
      );

  static TextStyle get headlineMedium => GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      );

  static TextStyle get headlineSmall => GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      );

  // ── Body (Inter) ──
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.white70,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.white70,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.white50,
      );

  // ── Labels ──
  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
        letterSpacing: 0.5,
      );

  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.white70,
        letterSpacing: 0.3,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.white50,
        letterSpacing: 0.2,
      );

  // ── Special ──
  static TextStyle get neonTitle => GoogleFonts.outfit(
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

  static TextStyle get timerText => GoogleFonts.outfit(
        fontSize: 56,
        fontWeight: FontWeight.w800,
        color: AppColors.white,
      );

  static TextStyle get phaseTitle => GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
        letterSpacing: 3.0,
      );

  static TextStyle get goldText => GoogleFonts.outfit(
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
