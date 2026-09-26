import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// AppButtonStyles defines reusable ButtonStyle definitions.
class AppButtonStyles {
  AppButtonStyles._();

  static ButtonStyle primaryDriverButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.black,
    elevation: 4,
    shadowColor: AppColors.primary.withValues(alpha: 0.5),
    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
    shape: RoundedRectangleBorder(
      borderRadius: AppSpacing.roundedMd,
    ),
    textStyle: AppTypography.buttonPrimary().copyWith(inherit: true),
  );

  static ButtonStyle secondaryGhostButton = TextButton.styleFrom(
    foregroundColor: AppColors.primary,
    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
    shape: RoundedRectangleBorder(
      borderRadius: AppSpacing.roundedSm,
    ),
    textStyle: AppTypography.buttonSecondary().copyWith(inherit: true),
  );

  static ButtonStyle outlinedDriverButton = OutlinedButton.styleFrom(
    foregroundColor: AppColors.textPrimaryDark,
    side: const BorderSide(color: AppColors.darkCardBorder, width: 1.5),
    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
    shape: RoundedRectangleBorder(
      borderRadius: AppSpacing.roundedMd,
    ),
    textStyle: AppTypography.buttonSecondary(color: AppColors.textPrimaryDark).copyWith(inherit: true),
  );

  static ButtonStyle socialAuthButton = OutlinedButton.styleFrom(
    backgroundColor: AppColors.darkCard,
    foregroundColor: AppColors.textPrimaryDark,
    side: const BorderSide(color: AppColors.darkCardBorder, width: 1.2),
    padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 20.0),
    shape: RoundedRectangleBorder(
      borderRadius: AppSpacing.roundedMd,
    ),
    textStyle: AppTypography.bodyMedium(
      color: AppColors.textPrimaryDark,
      fontWeight: FontWeight.w600,
    ).copyWith(inherit: true),
  );
}
