import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../style/app_colors.dart';
import '../style/app_spacing.dart';
import '../style/app_typography.dart';
import '../style/app_button_styles.dart';

/// Dark Theme specification for Car Driver app
ThemeData createDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: AppColors.black,
      primaryContainer: AppColors.primaryDark,
      onPrimaryContainer: AppColors.white,
      secondary: AppColors.secondary,
      onSecondary: AppColors.black,
      surface: AppColors.darkSurface,
      onSurface: AppColors.textPrimaryDark,
      error: AppColors.error,
      onError: AppColors.white,
    ),
    textTheme: TextTheme(
      displayLarge: AppTypography.displayLarge(),
      displayMedium: AppTypography.displayMedium(),
      headlineLarge: AppTypography.headingLarge(),
      headlineMedium: AppTypography.headingMedium(),
      headlineSmall: AppTypography.headingSmall(),
      bodyLarge: AppTypography.bodyLarge(),
      bodyMedium: AppTypography.bodyMedium(),
      bodySmall: AppTypography.bodySmall(),
      labelLarge: AppTypography.buttonPrimary(),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      iconTheme: IconThemeData(color: AppColors.white),
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.roundedLg,
        side: const BorderSide(color: AppColors.darkCardBorder, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: AppButtonStyles.primaryDriverButton,
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: AppButtonStyles.outlinedDriverButton,
    ),
    textButtonTheme: TextButtonThemeData(
      style: AppButtonStyles.secondaryGhostButton,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkInputFill,
      contentPadding: AppSpacing.inputContentPadding,
      border: OutlineInputBorder(
        borderRadius: AppSpacing.roundedMd,
        borderSide: const BorderSide(color: AppColors.darkCardBorder, width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppSpacing.roundedMd,
        borderSide: const BorderSide(color: AppColors.darkCardBorder, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppSpacing.roundedMd,
        borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppSpacing.roundedMd,
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      hintStyle: AppTypography.inputHint(color: AppColors.textMutedDark),
      labelStyle: AppTypography.inputLabel(color: AppColors.textSecondaryDark),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.darkCardBorder,
      thickness: 1,
    ),
  );
}
