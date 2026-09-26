import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// AppTypography defines typography tokens with robust fallbacks
/// to ensure text is always razor-sharp and legible across all devices.
class AppTypography {
  AppTypography._();

  static const List<String> _fontFallbacks = [
    'Segoe UI',
    'Roboto',
    'Helvetica Neue',
    'Arial',
    'sans-serif',
  ];

  // Headings
  static TextStyle displayLarge({Color? color}) {
    try {
      return GoogleFonts.outfit(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: color ?? AppColors.textPrimaryDark,
      );
    } catch (_) {
      return TextStyle(
        fontFamilyFallback: _fontFallbacks,
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: color ?? AppColors.textPrimaryDark,
      );
    }
  }

  static TextStyle displayMedium({Color? color}) {
    try {
      return GoogleFonts.outfit(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: color ?? AppColors.textPrimaryDark,
      );
    } catch (_) {
      return TextStyle(
        fontFamilyFallback: _fontFallbacks,
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: color ?? AppColors.textPrimaryDark,
      );
    }
  }

  static TextStyle headingLarge({Color? color}) {
    try {
      return GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.textPrimaryDark,
      );
    } catch (_) {
      return TextStyle(
        fontFamilyFallback: _fontFallbacks,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.textPrimaryDark,
      );
    }
  }

  static TextStyle headingMedium({Color? color}) {
    try {
      return GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textPrimaryDark,
      );
    } catch (_) {
      return TextStyle(
        fontFamilyFallback: _fontFallbacks,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textPrimaryDark,
      );
    }
  }

  static TextStyle headingSmall({Color? color}) {
    try {
      return GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textPrimaryDark,
      );
    } catch (_) {
      return TextStyle(
        fontFamilyFallback: _fontFallbacks,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textPrimaryDark,
      );
    }
  }

  // Body Texts
  static TextStyle bodyLarge({Color? color, FontWeight? fontWeight}) {
    try {
      return GoogleFonts.inter(
        fontSize: 15,
        fontWeight: fontWeight ?? FontWeight.w400,
        height: 1.5,
        color: color ?? AppColors.textSecondaryDark,
      );
    } catch (_) {
      return TextStyle(
        fontFamilyFallback: _fontFallbacks,
        fontSize: 15,
        fontWeight: fontWeight ?? FontWeight.w400,
        height: 1.5,
        color: color ?? AppColors.textSecondaryDark,
      );
    }
  }

  static TextStyle bodyMedium({Color? color, FontWeight? fontWeight}) {
    try {
      return GoogleFonts.inter(
        fontSize: 14,
        fontWeight: fontWeight ?? FontWeight.w400,
        height: 1.4,
        color: color ?? AppColors.textSecondaryDark,
      );
    } catch (_) {
      return TextStyle(
        fontFamilyFallback: _fontFallbacks,
        fontSize: 14,
        fontWeight: fontWeight ?? FontWeight.w400,
        height: 1.4,
        color: color ?? AppColors.textSecondaryDark,
      );
    }
  }

  static TextStyle bodySmall({Color? color, FontWeight? fontWeight}) {
    try {
      return GoogleFonts.inter(
        fontSize: 12,
        fontWeight: fontWeight ?? FontWeight.w400,
        color: color ?? AppColors.textMutedDark,
      );
    } catch (_) {
      return TextStyle(
        fontFamilyFallback: _fontFallbacks,
        fontSize: 12,
        fontWeight: fontWeight ?? FontWeight.w400,
        color: color ?? AppColors.textMutedDark,
      );
    }
  }

  // Form & Input Texts
  static TextStyle inputLabel({Color? color}) {
    try {
      return GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: color ?? AppColors.textSecondaryDark,
      );
    } catch (_) {
      return TextStyle(
        fontFamilyFallback: _fontFallbacks,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: color ?? AppColors.textSecondaryDark,
      );
    }
  }

  static TextStyle inputText({Color? color}) {
    try {
      return GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: color ?? AppColors.textPrimaryDark,
      );
    } catch (_) {
      return TextStyle(
        fontFamilyFallback: _fontFallbacks,
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: color ?? AppColors.textPrimaryDark,
      );
    }
  }

  static TextStyle inputHint({Color? color}) {
    try {
      return GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color ?? AppColors.textMutedDark,
      );
    } catch (_) {
      return TextStyle(
        fontFamilyFallback: _fontFallbacks,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color ?? AppColors.textMutedDark,
      );
    }
  }

  static TextStyle inputError({Color? color}) {
    try {
      return GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color ?? AppColors.error,
      );
    } catch (_) {
      return TextStyle(
        fontFamilyFallback: _fontFallbacks,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color ?? AppColors.error,
      );
    }
  }

  // Buttons & Badges
  static TextStyle buttonPrimary({Color? color}) {
    try {
      return GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: color ?? AppColors.black,
      );
    } catch (_) {
      return TextStyle(
        fontFamilyFallback: _fontFallbacks,
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: color ?? AppColors.black,
      );
    }
  }

  static TextStyle buttonSecondary({Color? color}) {
    try {
      return GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.primary,
      );
    } catch (_) {
      return TextStyle(
        fontFamilyFallback: _fontFallbacks,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.primary,
      );
    }
  }

  static TextStyle badgeText({Color? color}) {
    try {
      return GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: color ?? AppColors.primary,
      );
    } catch (_) {
      return TextStyle(
        fontFamilyFallback: _fontFallbacks,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: color ?? AppColors.primary,
      );
    }
  }

  static TextStyle statValue({Color? color}) {
    try {
      return GoogleFonts.outfit(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.textPrimaryDark,
      );
    } catch (_) {
      return TextStyle(
        fontFamilyFallback: _fontFallbacks,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.textPrimaryDark,
      );
    }
  }

  static TextStyle statLabel({Color? color}) {
    try {
      return GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color ?? AppColors.textSecondaryDark,
      );
    } catch (_) {
      return TextStyle(
        fontFamilyFallback: _fontFallbacks,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color ?? AppColors.textSecondaryDark,
      );
    }
  }
}
