import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// AppInputStyles encapsulates standard input decoration rules.
class AppInputStyles {
  AppInputStyles._();

  static InputDecoration inputDecoration({
    required String hintText,
    String? labelText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool isDark = true,
  }) {
    final fillColor = isDark ? AppColors.darkInputFill : AppColors.lightInputFill;
    final borderColor = isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder;
    final hintColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final labelColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return InputDecoration(
      filled: true,
      fillColor: fillColor,
      hintText: hintText,
      labelText: labelText,
      hintStyle: AppTypography.inputHint(color: hintColor),
      labelStyle: AppTypography.inputLabel(color: labelColor),
      floatingLabelStyle: AppTypography.inputLabel(color: AppColors.primary),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      contentPadding: AppSpacing.inputContentPadding,
      border: OutlineInputBorder(
        borderRadius: AppSpacing.roundedMd,
        borderSide: BorderSide(color: borderColor, width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppSpacing.roundedMd,
        borderSide: BorderSide(color: borderColor, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppSpacing.roundedMd,
        borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppSpacing.roundedMd,
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppSpacing.roundedMd,
        borderSide: const BorderSide(color: AppColors.error, width: 1.8),
      ),
      errorStyle: AppTypography.inputError(),
    );
  }
}
