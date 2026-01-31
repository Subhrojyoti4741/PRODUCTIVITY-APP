import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.accent,
        surface: Colors.white,
        error: AppColors.error,
        background: AppColors.backgroundLight,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.splineSans(
          fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textLight),
        displayMedium: GoogleFonts.splineSans(
          fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textLight),
        displaySmall: GoogleFonts.splineSans(
          fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textLight),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16, color: AppColors.textLight),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14, color: AppColors.textLight.withOpacity(0.8)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.splineSans(
          fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textLight),
        iconTheme: IconThemeData(color: AppColors.textLight),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.accent,
        surface: Color(0xFF1A332F),
        error: AppColors.error,
        background: AppColors.backgroundDark,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.splineSans(
          fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.textDark),
        displayMedium: GoogleFonts.splineSans(
          fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark),
        displaySmall: GoogleFonts.splineSans(
          fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textDark),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16, color: AppColors.textDark),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14, color: AppColors.textDark.withOpacity(0.8)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.splineSans(
          fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark),
        iconTheme: IconThemeData(color: AppColors.textDark),
      ),
    );
  }
}
