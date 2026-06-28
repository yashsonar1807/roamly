import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Roamly Yellow / Black Palette
  static const Color primary = Color(0xFFFFC400); // Yellow from paper plane
  static const Color primaryLight = Color(0xFFFFD740);
  static const Color primaryDark = Color(0xFFFFB300);

  static const Color secondary = Color(0xFF111111); // Black text from logo
  static const Color secondaryLight = Color(0xFF333333);
  static const Color secondaryDark = Color(0xFF000000);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Light Theme Colors (White background for Yellow & White theme)
  static const Color lightBg = Colors.white;
  static const Color lightSurface = Colors.white;
  static const Color lightOnBg = Color(0xFF111111);
  static const Color lightOnSurface = Color(0xFF1F2937);
  static const Color lightBorder = Color(0xFFE5E7EB);

  // Dark Theme Colors (Sleek dark mode)
  static const Color darkBg = Color(0xFF111111); // Pure black/dark grey
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkOnBg = Color(0xFFFDFBF7);
  static const Color darkOnSurface = Color(0xFFE5E7EB);
  static const Color darkBorder = Color(0xFF333333);

  // Neutral Muted Colors
  static const Color textMutedLight = Color(0xFF6B7280);
  static const Color textMutedDark = Color(0xFF9CA3AF);

  // Material 3 Color Schemes
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: Color(0xFF111111), // Black text on yellow buttons
    primaryContainer: Color(0xFFFFF3C4),
    onPrimaryContainer: Color(0xFF111111),
    secondary: secondary,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFF333333),
    onSecondaryContainer: Colors.white,
    error: error,
    onError: Colors.white,
    surface: lightBg,
    onSurface: lightOnBg,
    surfaceContainerHighest: Color(0xFFF3F4F6),
    onSurfaceVariant: Color(0xFF4B5563),
    outline: lightBorder,
  );

  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: primary,
    onPrimary: Color(0xFF111111),
    primaryContainer: Color(0xFF997500),
    onPrimaryContainer: Colors.white,
    secondary: secondaryLight,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFF333333),
    onSecondaryContainer: Colors.white,
    error: error,
    onError: Colors.white,
    surface: darkBg,
    onSurface: darkOnBg,
    surfaceContainerHighest: Color(0xFF1E1E1E),
    onSurfaceVariant: Color(0xFF9CA3AF),
    outline: darkBorder,
  );
}
