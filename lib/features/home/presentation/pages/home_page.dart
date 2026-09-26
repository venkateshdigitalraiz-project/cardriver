import 'package:cardriver/features/active_ride/presentation/pages/active_ride_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/style/app_colors.dart';
import '../../../../core/style/app_spacing.dart';
import '../../../../core/style/app_typography.dart';
import '../../../auth/domain/entities/customer_entity.dart';
import '../../../navigation/presentation/bloc/navigation_bloc.dart';
import '../../../navigation/presentation/bloc/navigation_event.dart';
import 'package:latlong2/latlong.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
// import '../widgets/current_location_map.dart';

class HomePage extends StatelessWidget {
  final CustomerEntity customer;

  const HomePage({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc(),
      child: _HomeView(customer: customer),
    );
  }
}

class _HomeView extends StatelessWidget {
  final CustomerEntity customer;

  const _HomeView({required this.customer});

  @override
  Widget build(BuildContext context) {
    final primaryTextColor = AppColors.textPrimaryLight;
    final secondaryTextColor = AppColors.textSecondaryLight;

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.lightBackground,
          appBar: AppBar(
            backgroundColor: AppColors.lightSurface,
            title: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(customer.avatarUrl),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Captain ${customer.name}',
                        style: AppTypography.headingSmall(
                          color: primaryTextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        state.isOnline ? 'Online' : 'Offline',
                        style: AppTypography.bodySmall(
                          color: state.isOnline
                              ? const Color(0xFF10B981)
                              : AppColors.textMutedLight,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              Row(
                children: [
                  Text(
                    state.isOnline ? 'GO OFFLINE' : 'GO ONLINE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: state.isOnline
                          ? const Color(0xFF10B981)
                          : secondaryTextColor,
                    ),
                  ),
                  Switch(
                    value: state.isOnline,
                    activeThumbColor: const Color(0xFF10B981),
                    onChanged: (value) {
                      context.read<HomeBloc>().add(ToggleOnlineStatusEvent());
                    },
                  ),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Row
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // Quick access to Trips (can be handled by NavigationBloc or local routing)
                          // If Trips is index 1 in bottom nav:
                          context.read<NavigationBloc>().add(
                            const NavigationTabChanged(1),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.account_balance_wallet_rounded,
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '\$${state.todaysEarnings.toStringAsFixed(2)}',
                                style: AppTypography.headingMedium(
                                  color: primaryTextColor,
                                ).copyWith(fontSize: 18),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Earnings",
                                style: AppTypography.bodySmall(
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // Quick access to Trips
                          context.read<NavigationBloc>().add(
                            const NavigationTabChanged(1),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withValues(
                                    alpha: 0.1,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.directions_car_rounded,
                                  color: AppColors.secondary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${state.todaysTrips}',
                                style: AppTypography.headingMedium(
                                  color: primaryTextColor,
                                ).copyWith(fontSize: 18),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Trips",
                                style: AppTypography.bodySmall(
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // Quick access to Profile (Rating)
                          context.read<NavigationBloc>().add(
                            const NavigationTabChanged(2),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFF59E0B,
                                  ).withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.star_rounded,
                                  color: Color(0xFFF59E0B),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${state.rating}',
                                style: AppTypography.headingMedium(
                                  color: primaryTextColor,
                                ).copyWith(fontSize: 18),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Rating",
                                style: AppTypography.bodySmall(
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Upcoming Booking / Request Card
                if (state.isOnline) ...[
                  Text(
                    'New Ride Request',
                    style: AppTypography.headingMedium(color: primaryTextColor),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF10B981,
                          ).withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFF10B981),
                        width: 1.5,
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundImage: NetworkImage(
                                'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&auto=format&fit=crop&q=80',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Sarah Connor',
                                    style: AppTypography.headingSmall(
                                      color: primaryTextColor,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star_rounded,
                                        size: 14,
                                        color: Color(0xFFF59E0B),
                                      ),
                                      Text(
                                        ' 4.9',
                                        style: AppTypography.bodySmall(
                                          color: secondaryTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF10B981,
                                ).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '2 mins away',
                                style: AppTypography.badgeText(
                                  color: const Color(0xFF10B981),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(
                              Icons.my_location_rounded,
                              size: 20,
                              color: Color(0xFF10B981),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '742 Evergreen Terrace',
                                style: AppTypography.bodyMedium(
                                  color: primaryTextColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 9),
                          child: SizedBox(
                            height: 16,
                            child: VerticalDivider(
                              color: Colors.grey,
                              thickness: 1.5,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 20,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'International Airport T2',
                                style: AppTypography.bodyMedium(
                                  color: primaryTextColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                  side: const BorderSide(
                                    color: AppColors.error,
                                  ),
                                ),
                                child: const Text('Decline'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ActiveRidePage(
                                        startLocation: LatLng(
                                          12.9716,
                                          77.5946,
                                        ), // Dummy start (e.g. Bangalore)
                                        endLocation: LatLng(
                                          12.9916,
                                          77.5946,
                                        ), // Dummy end
                                        startLocationName:
                                            '742 Evergreen Terrace',
                                        endLocationName:
                                            'International Airport T2',
                                        cost: '\$15.50',
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('view'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Map Placeholder
                /* Text(
                  'Current Location',
                  style: AppTypography.headingMedium(color: primaryTextColor),
                ),
                const SizedBox(height: 12),
                const CurrentLocationMap(),
                */
              ],
            ),
          ),
        );
      },
    );
  }
}
