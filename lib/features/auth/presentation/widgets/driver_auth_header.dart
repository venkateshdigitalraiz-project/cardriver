import 'package:flutter/material.dart';
import '../../../../core/style/app_colors.dart';
import '../../../../core/style/app_spacing.dart';
import '../../../../core/style/app_typography.dart';

class DriverAuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const DriverAuthHeader({
    super.key,
    this.title = 'Driver Partner Login',
    this.subtitle = 'Access your live route dispatch console & instant earnings',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top GPS Active & Status Indicator Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.darkCard.withValues(alpha: 0.8),
            borderRadius: AppSpacing.roundedFull,
            border: Border.all(
              color: AppColors.driverOnline.withValues(alpha: 0.3),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.driverOnline.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.driverOnline,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.driverOnline.withValues(alpha: 0.8),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'LIVE DISPATCH NETWORK ACTIVE',
                style: AppTypography.badgeText(color: AppColors.driverOnline),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Glowing Hero Icon with Dual Ring Aura
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.3),
                Colors.transparent,
              ],
            ),
          ),
          child: Center(
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.driverPrimaryGradient,
                boxShadow: AppSpacing.primaryButtonGlow,
              ),
              child: Center(
                child: Container(
                  width: 62,
                  height: 62,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF0C1322),
                  ),
                  child: const Icon(
                    Icons.local_taxi_rounded,
                    size: 34,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Brand Name with High Contrast
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: 'CAR ',
            style: AppTypography.displayLarge(color: AppColors.white).copyWith(fontSize: 28),
            children: [
              TextSpan(
                text: 'DRIVER',
                style: AppTypography.displayLarge(color: AppColors.primary).copyWith(fontSize: 28),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // Subtitle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium(
              color: AppColors.textSecondaryDark,
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Driver Perks / Value Pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPerkChip(Icons.bolt_rounded, 'Instant Payouts', AppColors.primary),
              const SizedBox(width: 8),
              _buildPerkChip(Icons.shield_rounded, 'Trip Insurance', AppColors.secondary),
              const SizedBox(width: 8),
              _buildPerkChip(Icons.star_rounded, '100% Tips Kept', AppColors.driverOnline),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPerkChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppSpacing.roundedFull,
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTypography.bodySmall(
              color: color,
              fontWeight: FontWeight.w600,
            ).copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
