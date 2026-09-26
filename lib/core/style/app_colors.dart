import 'package:flutter/material.dart';

/// AppColors defines the raw color palette for the Car Driver application.
/// Strictly separated from Theme configuration to allow modular style reuse.
class AppColors {
  AppColors._();

  // Primary Brand Colors (Driver Yellow / Electric Gold)
  static const Color primary = Color(0xFFFFB800);
  static const Color primaryDark = Color(0xFFE5A600);
  static const Color primaryLight = Color(0xFFFFD043);
  static const Color primaryGradientStart = Color(0xFFFFB800);
  static const Color primaryGradientEnd = Color(0xFFFF8A00);

  // Secondary & Accent Colors (Cyan & Driver Blue)
  static const Color secondary = Color(0xFF00D2FF);
  static const Color accentBlue = Color(0xFF2563EB);
  static const Color accentIndigo = Color(0xFF6366F1);

  // Dark Theme Background & Surface
  static const Color darkBackground = Color(0xFF0A0E17);
  static const Color darkSurface = Color(0xFF121826);
  static const Color darkCard = Color(0xFF161F30);
  static const Color darkCardBorder = Color(0xFF2A374F);
  static const Color darkInputFill = Color(0xFF0F1724);

  // Light Theme Background & Surface
  static const Color lightBackground = Color(0xFFF4F6FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardBorder = Color(0xFFE2E8F0);
  static const Color lightInputFill = Color(0xFFF1F5F9);

  // Text Colors (Enhanced Contrast & Sharp Legibility)
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFCBD5E1);
  static const Color textMutedDark = Color(0xFF94A3B8);

  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textMutedLight = Color(0xFF64748B);

  // Status & Feedback Colors
  static const Color success = Color(0xFF10B981);
  static const Color successBackground = Color(0xFF064E3B);
  static const Color error = Color(0xFFEF4444);
  static const Color errorBackground = Color(0xFF450A0A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Driver Status Indicator Colors
  static const Color driverOnline = Color(0xFF22C55E);
  static const Color driverOffline = Color(0xFF94A3B8);
  static const Color driverOnTrip = Color(0xFFEAB308);

  // Neutral Grays & Overlays
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;
  static const Color overlayDark = Color(0x80000000);
  static const Color glassBorder = Color(0x33FFFFFF);

  // Gradients
  static const LinearGradient driverPrimaryGradient = LinearGradient(
    colors: [primaryGradientStart, primaryGradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF161F30), Color(0xFF0F1724)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient neonAccentGradient = LinearGradient(
    colors: [Color(0xFF00D2FF), Color(0xFF3A7BD5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
