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
                                '₹${state.todaysEarnings.toStringAsFixed(0)}',
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
                  if (state.activeRequestIds.isNotEmpty) ...[
                    Text(
                      'New Ride Requests',
                      style: AppTypography.headingMedium(color: primaryTextColor),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (state.activeRequestIds.contains('req_1')) ...[
                    _buildRideRequestCard(
                      requestId: 'req_1',
                      context: context,
                      riderName: 'Sarah Connor',
                      rating: '4.9',
                      timeAway: '2 mins away',
                      fare: '₹1250',
                      distanceTime: '8.5 km • 25 mins',
                      pickup: 'Koramangala, Bangalore',
                      dropoff: 'International Airport T2',
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (state.activeRequestIds.contains('req_2')) ...[
                    _buildRideRequestCard(
                      requestId: 'req_2',
                      context: context,
                      riderName: 'John Smith',
                      rating: '4.7',
                      timeAway: '5 mins away',
                      fare: '₹650',
                      distanceTime: '3.2 km • 12 mins',
                      pickup: 'Indiranagar',
                      dropoff: 'MG Road',
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (state.activeRequestIds.contains('req_3')) ...[
                    _buildRideRequestCard(
                      requestId: 'req_3',
                      context: context,
                      riderName: 'Emily Chen',
                      rating: '5.0',
                      timeAway: '1 min away',
                      fare: '₹1800',
                      distanceTime: '15.0 km • 40 mins',
                      pickup: 'Electronic City',
                      dropoff: 'Whitefield',
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                    const SizedBox(height: 24),
                  ],
                ],

                // Map Placeholder
                /* Text(
                  'Current Location',
                  style: AppTypography.headingMedium(color: primaryTextColor),
                ),
                const SizedBox(height: 12),
                const CurrentLocationMap(),
                */
                
                // Weekly Goal Progress
                Text(
                  'Weekly Goal',
                  style: AppTypography.headingMedium(color: primaryTextColor),
                ),
                const SizedBox(height: 12),
                Container(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Earn ₹40,000 this week',
                            style: AppTypography.bodyMedium(color: primaryTextColor).copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '₹9,640 / ₹40,000',
                            style: AppTypography.bodySmall(color: AppColors.primary).copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: 9640.0 / 40000.0,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          color: AppColors.primary,
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'You are on track to reach your goal!',
                        style: AppTypography.bodySmall(color: secondaryTextColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Recent Activity / Trips
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Trips',
                      style: AppTypography.headingMedium(color: primaryTextColor),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<NavigationBloc>().add(const NavigationTabChanged(1));
                      },
                      child: Text(
                        'See All',
                        style: AppTypography.bodyMedium(color: AppColors.primary).copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildRecentTripItem('Koramangala, BLR', '₹1960', '2:30 PM', primaryTextColor, secondaryTextColor),
                const SizedBox(height: 12),
                _buildRecentTripItem('Kempegowda Airport', '₹3600', '10:15 AM', primaryTextColor, secondaryTextColor),
                const SizedBox(height: 12),
                _buildRecentTripItem('MG Road, BLR', '₹1450', 'Yesterday', primaryTextColor, secondaryTextColor),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentTripItem(String destination, String earnings, String time, Color primaryText, Color secondaryText) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  destination,
                  style: AppTypography.bodyMedium(color: primaryText).copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: AppTypography.bodySmall(color: secondaryText),
                ),
              ],
            ),
          ),
          Text(
            earnings,
            style: AppTypography.bodyMedium(color: const Color(0xFF10B981)).copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildRideRequestCard({
    required String requestId,
    required BuildContext context,
    required String riderName,
    required String rating,
    required String timeAway,
    required String fare,
    required String distanceTime,
    required String pickup,
    required String dropoff,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.15),
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
                      riderName,
                      style: AppTypography.headingSmall(color: primaryTextColor),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: Color(0xFFF59E0B),
                        ),
                        Text(
                          ' $rating',
                          style: AppTypography.bodySmall(color: secondaryTextColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  timeAway,
                  style: AppTypography.badgeText(color: const Color(0xFF10B981)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Estimated Fare', style: AppTypography.bodySmall(color: secondaryTextColor)),
                    const SizedBox(height: 4),
                    Text(fare, style: AppTypography.headingMedium(color: AppColors.primary)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Trip Distance', style: AppTypography.bodySmall(color: secondaryTextColor)),
                    const SizedBox(height: 4),
                    Text(distanceTime, style: AppTypography.bodyMedium(color: primaryTextColor).copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
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
                  pickup,
                  style: AppTypography.bodyMedium(color: primaryTextColor),
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
                  dropoff,
                  style: AppTypography.bodyMedium(color: primaryTextColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    context.read<HomeBloc>().add(DeclineRideRequestEvent(requestId));
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
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
                        builder: (_) => ActiveRidePage(
                          startLocation: const LatLng(12.9716, 77.5946),
                          endLocation: const LatLng(12.9916, 77.5946),
                          startLocationName: pickup,
                          endLocationName: dropoff,
                          cost: fare,
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
    );
  }
}
