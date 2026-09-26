import 'package:flutter/material.dart';
import '../../../../core/style/app_colors.dart';
import '../../../../core/style/app_spacing.dart';
import '../../../../core/style/app_typography.dart';

class QuickDriverPresets extends StatelessWidget {
  final Function(String email, String password) onSelectEmailPreset;
  final Function(String phone) onSelectPhonePreset;
  final bool isEmailMode;

  const QuickDriverPresets({
    super.key,
    required this.onSelectEmailPreset,
    required this.onSelectPhonePreset,
    required this.isEmailMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: AppSpacing.roundedMd,
        border: Border.all(
          color: AppColors.darkCardBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.flash_on_rounded,
                color: AppColors.primary,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'QUICK DEMO DRIVER ACCOUNTS',
                style: AppTypography.badgeText(color: AppColors.textSecondaryDark),
              ),
              const Spacer(),
              Text(
                '1-Tap Fill',
                style: AppTypography.bodySmall(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPresetCard(
                  title: 'Cab Pro',
                  subtitle: 'Toyota Camry',
                  icon: Icons.local_taxi_rounded,
                  accentColor: AppColors.primary,
                  onTap: () {
                    if (isEmailMode) {
                      onSelectEmailPreset('driver@cardriver.com', 'password123');
                    } else {
                      onSelectPhonePreset('+1 555-019-2834');
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPresetCard(
                  title: 'Chauffeur',
                  subtitle: 'Mercedes Benz',
                  icon: Icons.star_rounded,
                  accentColor: AppColors.secondary,
                  onTap: () {
                    if (isEmailMode) {
                      onSelectEmailPreset('elena@luxury.com', 'password123');
                    } else {
                      onSelectPhonePreset('+1 555-432-8765');
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPresetCard(
                  title: 'EV Fleet',
                  subtitle: 'Tesla Model Y',
                  icon: Icons.electric_car_rounded,
                  accentColor: AppColors.driverOnline,
                  onTap: () {
                    if (isEmailMode) {
                      onSelectEmailPreset('marcus@electric.com', 'password123');
                    } else {
                      onSelectPhonePreset('+1 555-888-1212');
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.roundedSm,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.darkInputFill,
          borderRadius: AppSpacing.roundedSm,
          border: Border.all(
            color: accentColor.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: accentColor),
            const SizedBox(height: 6),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmall(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySmall(
                color: AppColors.textSecondaryDark,
              ).copyWith(fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
