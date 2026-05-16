import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Full Material3 dark theme for City Of Lies
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.purpleNeon,
        secondary: AppColors.cyan,
        surface: AppColors.surface,
        error: AppColors.crimsonRed,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.white,
        onError: AppColors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.outfit(
          fontSize: 48,
          fontWeight: FontWeight.w800,
          color: AppColors.white,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
        displaySmall: GoogleFonts.outfit(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        headlineLarge: GoogleFonts.outfit(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        headlineSmall: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.white70,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.white70,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          color: AppColors.white50,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.white70,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.white50,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.purpleNeon,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white05,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.purpleNeon, width: 1.5),
        ),
        labelStyle: GoogleFonts.inter(color: AppColors.white50),
        hintStyle: GoogleFonts.inter(color: AppColors.white30),
        prefixIconColor: AppColors.white50,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.purpleNeon,
        unselectedItemColor: AppColors.white30,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.white10,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface,
        contentTextStyle: GoogleFonts.inter(color: AppColors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
