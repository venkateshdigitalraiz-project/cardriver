import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/style/app_colors.dart';
import '../../../../core/style/app_typography.dart';
import '../../../auth/domain/entities/customer_entity.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_state.dart';

/// Feature Card on Driver HomePage for Booking Driver / Direct Ride Booking.
/// Built strictly following Clean Architecture with BLoC.
class BookingDriverCard extends StatelessWidget {
  final CustomerEntity customer;
  final VoidCallback? onBookTap;

  const BookingDriverCard({super.key, required this.customer, this.onBookTap});

  void _handleTap(BuildContext context) {
    if (onBookTap != null) {
      onBookTap!();
      return;
    }

    // Navigate to Create Ride / Booking Driver page passing BLoC and customer context
    context.push(
      AppRoutes.createRide,
      extra: {'homeBloc': context.read<HomeBloc>(), 'customer': customer},
    );
  }

  void _handleViewAll(BuildContext context) {
    // Navigate to Driver-to-Driver Bookings list screen
    context.push(
      AppRoutes.dToDBookings,
      extra: {'customer': customer, 'driverToken': customer.token},
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryTextColor = AppColors.textPrimaryLight;
    final secondaryTextColor = AppColors.textSecondaryLight;

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        // Count any direct/manual bookings present in available rides
        final manualBookings = state.availableRides
            .where(
              (ride) =>
                  ride.id.startsWith('manual_') ||
                  ride.serviceType.toLowerCase().contains('manual'),
            )
            .toList();
        final hasManualBooking = manualBookings.isNotEmpty;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasManualBooking
                  ? const Color(0xFF10B981).withValues(alpha: 0.6)
                  : Colors.grey.shade200,
              width: hasManualBooking ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: hasManualBooking
                    ? const Color(0xFF10B981).withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () => _handleTap(context),
              borderRadius: BorderRadius.circular(16),
              splashColor: const Color(0xFF10B981).withValues(alpha: 0.1),
              highlightColor: const Color(0xFF10B981).withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Icon, Title, Badge & Action Button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Service Icon with premium gradient/tint
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF059669)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF10B981,
                                ).withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person_pin_circle_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),

                        // Title, Subtitle & Status
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Booking Driver',
                                      style:
                                          AppTypography.headingSmall(
                                            color: primaryTextColor,
                                          ).copyWith(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                hasManualBooking
                                    ? 'Latest: ${manualBookings.first.riderName} (${manualBookings.first.bookingId})'
                                    : 'Create instant booking for walk-in or offline passenger',
                                style: AppTypography.bodySmall(
                                  color: secondaryTextColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          onTap: () => _handleViewAll(context),
                          borderRadius: BorderRadius.circular(6),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'View All',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                SizedBox(width: 3),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 14,
                                  color: Colors.blue,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Action Button
                      ],
                    ),

                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    const SizedBox(height: 10),

                    // Feature highlights tags and View All action
                    Row(
                      children: [
                        _buildFeatureTag(
                          icon: Icons.bolt_rounded,
                          label: 'Instant Ride',
                          color: const Color(0xFFF59E0B),
                        ),
                        const SizedBox(width: 10),
                        _buildFeatureTag(
                          icon: Icons.navigation_rounded,
                          label: 'Live Route',
                          color: const Color(0xFF3B82F6),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF10B981,
                                ).withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.add_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Book',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureTag({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
