import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Premium Indigo / Violet Palette
  static const Color primary = Color(0xFF6366F1); // Modern Indigo
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);

  static const Color secondary = Color(0xFF10B981); // Emerald Green Accent
  static const Color secondaryLight = Color(0xFF34D399);
  static const Color secondaryDark = Color(0xFF059669);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Light Theme Colors
  static const Color lightBg = Color(0xFFF9FAFB);
  static const Color lightSurface = Colors.white;
  static const Color lightOnBg = Color(0xFF111827);
  static const Color lightOnSurface = Color(0xFF1F2937);
  static const Color lightBorder = Color(0xFFE5E7EB);

  // Dark Theme Colors (Sleek dark mode)
  static const Color darkBg = Color(0xFF0B0F19);
  static const Color darkSurface = Color(0xFF151B2C);
  static const Color darkOnBg = Color(0xFFF9FAFB);
  static const Color darkOnSurface = Color(0xFFE5E7EB);
  static const Color darkBorder = Color(0xFF1F2937);

  // Neutral Muted Colors
  static const Color textMutedLight = Color(0xFF6B7280);
  static const Color textMutedDark = Color(0xFF9CA3AF);

  // Material 3 Color Schemes (Updated to resolve deprecations)
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFE0E7FF),
    onPrimaryContainer: Color(0xFF312E81),
    secondary: secondary,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFD1FAE5),
    onSecondaryContainer: Color(0xFF065F46),
    error: error,
    onError: Colors.white,
    surface: lightBg, // surface is used for general background/scaffold canvas
    onSurface: lightOnBg,
    surfaceContainerHighest: Color(0xFFF3F4F6), // replaces surfaceVariant
    onSurfaceVariant: Color(0xFF4B5563),
    outline: lightBorder,
  );

  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: primaryLight,
    onPrimary: Color(0xFF1E1B4B),
    primaryContainer: Color(0xFF312E81),
    onPrimaryContainer: Color(0xFFE0E7FF),
    secondary: secondaryLight,
    onSecondary: Color(0xFF064E3B),
    secondaryContainer: Color(0xFF065F46),
    onSecondaryContainer: Color(0xFFD1FAE5),
    error: error,
    onError: Colors.white,
    surface: darkBg, // surface is used for general background/scaffold canvas
    onSurface: darkOnBg,
    surfaceContainerHighest: Color(0xFF1E293B), // replaces surfaceVariant
    onSurfaceVariant: Color(0xFF94A3B8),
    outline: darkBorder,
  );
}
