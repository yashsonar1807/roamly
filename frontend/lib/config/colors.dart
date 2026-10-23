import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Core Brand Colors (Premium Apple/Airbnb style)
  static const Color primary = Color(0xFF0EA5E9); // Ocean Blue
  static const Color primaryLight = Color(0xFF38BDF8);
  static const Color primaryDark = Color(0xFF0284C7);

  static const Color secondary = Color(0xFF0F172A); // Deep Navy
  static const Color secondaryLight = Color(0xFF1E293B);
  static const Color secondaryDark = Color(0xFF020617);

  // Vibrant Accents
  static const Color accentOrange = Color(0xFFF97316); // Sunset Orange

  // Status Colors
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Rose Red
  static const Color info = Color(0xFF3B82F6); // Blue

  // Light Theme Colors
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightOnBg = Color(0xFF0F172A);
  static const Color lightOnSurface = Color(0xFF0F172A);
  static const Color lightBorder = Color(0xFFE2E8F0);

  // Dark Theme Colors (Stitch Luminous Nomad)
  static const Color darkBg = Color(0xFF0B1326); // Midnight Slate Bedrock
  static const Color darkSurface = Color(0xFF131B2E); // Level 1 Card Floor
  static const Color darkSurfaceContainer = Color(0xFF171F33); // Interactive Container
  static const Color darkSurfaceHigh = Color(0xFF222A3D); // Elevated Surface
  static const Color darkOnBg = Color(0xFFDAE2FD);
  static const Color darkOnSurface = Color(0xFFDAE2FD);
  static const Color darkBorder = Color(0xFF2D3449);

  // Neutral Muted Colors
  static const Color textMutedLight = Color(0xFF64748B);
  static const Color textMutedDark = Color(0xFF94A3B8);

  // Material 3 Color Schemes
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFE0F2FE),
    onPrimaryContainer: primaryDark,
    secondary: secondary,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFF1F5F9),
    onSecondaryContainer: secondaryDark,
    error: error,
    onError: Colors.white,
    surface: lightSurface,
    onSurface: lightOnSurface,
    surfaceContainerHighest: lightBg,
  );

  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: primary,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFF0EA5E9),
    onPrimaryContainer: Colors.white,
    secondary: accentOrange,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFF1E293B),
    onSecondaryContainer: Colors.white,
    error: error,
    onError: Colors.black,
    surface: darkSurface,
    onSurface: darkOnSurface,
    surfaceContainerHighest: darkSurfaceContainer,
  );

  // Elegant Gradients inspired by Nature
  static const LinearGradient storyGradient = LinearGradient(
    colors: [Color(0xFFF97316), Color(0xFFEC4899), Color(0xFF8B5CF6)],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );

  static const LinearGradient rankGradient = LinearGradient(
    colors: [Color(0xFF0EA5E9), Color(0xFF3B82F6), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0EA5E9), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
