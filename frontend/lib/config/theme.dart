import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: AppColors.lightColorScheme,
      scaffoldBackgroundColor: AppColors.lightBg,
      fontFamily: GoogleFonts.inter().fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.lightOnBg),
        titleTextStyle: GoogleFonts.outfit(
          color: AppColors.lightOnBg,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.plusJakartaSans(color: AppColors.lightOnBg, fontSize: 40, fontWeight: FontWeight.w800, letterSpacing: -1),
        displayMedium: GoogleFonts.plusJakartaSans(color: AppColors.lightOnBg, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        displaySmall: GoogleFonts.plusJakartaSans(color: AppColors.lightOnBg, fontSize: 24, fontWeight: FontWeight.w700),
        titleLarge: GoogleFonts.plusJakartaSans(color: AppColors.lightOnBg, fontSize: 22, fontWeight: FontWeight.w700),
        titleMedium: GoogleFonts.plusJakartaSans(color: AppColors.lightOnBg, fontSize: 18, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.inter(color: AppColors.lightOnSurface, fontSize: 16, fontWeight: FontWeight.w400),
        bodyMedium: GoogleFonts.inter(color: AppColors.lightOnSurface, fontSize: 14, fontWeight: FontWeight.w400),
        bodySmall: GoogleFonts.inter(color: AppColors.textMutedLight, fontSize: 12, fontWeight: FontWeight.w400),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: AppColors.primary.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lightOnBg,
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.04),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.lightBorder, width: 0.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: AppColors.darkColorScheme,
      scaffoldBackgroundColor: AppColors.darkBg,
      fontFamily: GoogleFonts.inter().fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.darkOnBg),
        titleTextStyle: GoogleFonts.inter(
          color: AppColors.darkOnBg,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.plusJakartaSans(color: AppColors.darkOnBg, fontSize: 40, fontWeight: FontWeight.w800, letterSpacing: -1),
        displayMedium: GoogleFonts.plusJakartaSans(color: AppColors.darkOnBg, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        displaySmall: GoogleFonts.plusJakartaSans(color: AppColors.darkOnBg, fontSize: 24, fontWeight: FontWeight.w700),
        titleLarge: GoogleFonts.plusJakartaSans(color: AppColors.darkOnBg, fontSize: 22, fontWeight: FontWeight.w700),
        titleMedium: GoogleFonts.plusJakartaSans(color: AppColors.darkOnBg, fontSize: 18, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.inter(color: AppColors.darkOnSurface, fontSize: 16, fontWeight: FontWeight.w400),
        bodyMedium: GoogleFonts.inter(color: AppColors.darkOnSurface, fontSize: 14, fontWeight: FontWeight.w400),
        bodySmall: GoogleFonts.inter(color: AppColors.textMutedDark, fontSize: 12, fontWeight: FontWeight.w400),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 6,
          shadowColor: AppColors.primary.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkOnBg,
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 12,
        shadowColor: Colors.black.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.darkBorder, width: 0.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
