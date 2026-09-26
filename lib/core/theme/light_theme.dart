import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../style/app_colors.dart';
import '../style/app_spacing.dart';
import '../style/app_typography.dart';
import '../style/app_button_styles.dart';

/// Light Theme specification for Car Driver & Passenger app
ThemeData createLightTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBackground,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryDark,
      onPrimary: AppColors.white,
      primaryContainer: AppColors.primaryLight,
      onPrimaryContainer: AppColors.black,
      secondary: AppColors.accentBlue,
      onSecondary: AppColors.white,
      surface: AppColors.lightSurface,
      onSurface: AppColors.textPrimaryLight,
      error: AppColors.error,
      onError: AppColors.white,
    ),
    textTheme: TextTheme(
      displayLarge: AppTypography.displayLarge(color: AppColors.textPrimaryLight),
      displayMedium: AppTypography.displayMedium(color: AppColors.textPrimaryLight),
      headlineLarge: AppTypography.headingLarge(color: AppColors.textPrimaryLight),
      headlineMedium: AppTypography.headingMedium(color: AppColors.textPrimaryLight),
      headlineSmall: AppTypography.headingSmall(color: AppColors.textPrimaryLight),
      bodyLarge: AppTypography.bodyLarge(color: AppColors.textSecondaryLight),
      bodyMedium: AppTypography.bodyMedium(color: AppColors.textSecondaryLight),
      bodySmall: AppTypography.bodySmall(color: AppColors.textMutedLight),
      labelLarge: AppTypography.buttonPrimary(color: AppColors.black),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      iconTheme: IconThemeData(color: AppColors.black),
    ),
    cardTheme: CardThemeData(
      color: AppColors.lightCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.roundedLg,
        side: const BorderSide(color: AppColors.lightCardBorder, width: 1),
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
      fillColor: AppColors.lightInputFill,
      contentPadding: AppSpacing.inputContentPadding,
      border: OutlineInputBorder(
        borderRadius: AppSpacing.roundedMd,
        borderSide: const BorderSide(color: AppColors.lightCardBorder, width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppSpacing.roundedMd,
        borderSide: const BorderSide(color: AppColors.lightCardBorder, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppSpacing.roundedMd,
        borderSide: const BorderSide(color: AppColors.primaryDark, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppSpacing.roundedMd,
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      hintStyle: AppTypography.inputHint(color: AppColors.textMutedLight),
      labelStyle: AppTypography.inputLabel(color: AppColors.textSecondaryLight),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.lightCardBorder,
      thickness: 1,
    ),
  );
}
