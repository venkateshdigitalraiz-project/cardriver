import 'package:flutter/material.dart';
import '../style/app_colors.dart';
import '../style/app_spacing.dart';
import '../style/app_typography.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double height;
  final bool useGradient;

  const CustomElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height = 54,
    this.useGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveFgColor = foregroundColor ?? AppColors.black;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: AppSpacing.roundedMd,
          gradient: (useGradient && onPressed != null && !isLoading)
              ? AppColors.driverPrimaryGradient
              : null,
          color: (useGradient && onPressed != null && !isLoading)
              ? null
              : (backgroundColor ?? (onPressed == null ? AppColors.darkCardBorder : AppColors.primary)),
          boxShadow: (onPressed != null && !isLoading)
              ? AppSpacing.primaryButtonGlow
              : null,
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.transparent,
            shadowColor: AppColors.transparent,
            foregroundColor: effectiveFgColor,
            disabledBackgroundColor: AppColors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: AppSpacing.roundedMd,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24),
          ),
          child: isLoading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(effectiveFgColor),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20, color: effectiveFgColor),
                      const SizedBox(width: 10),
                    ],
                    Text(
                      text,
                      style: AppTypography.buttonPrimary(color: effectiveFgColor),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
