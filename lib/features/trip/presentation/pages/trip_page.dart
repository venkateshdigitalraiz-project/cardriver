import 'package:cardriver/features/trip/presentation/bloc/trip_bloc.dart';
import 'package:cardriver/features/trip/presentation/bloc/trip_event.dart';
import 'package:cardriver/features/trip/presentation/bloc/trip_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/style/app_colors.dart';
import '../../../../core/style/app_spacing.dart';
import '../../../../core/style/app_typography.dart';

class TripPage extends StatelessWidget {
  const TripPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TripBloc()..add(LoadTripsEvent()),
      child: const _TripView(),
    );
  }
}

class _TripView extends StatelessWidget {
  const _TripView();

  @override
  Widget build(BuildContext context) {
    // Forced to light mode as requested
    final primaryTextColor = AppColors.textPrimaryLight;
    final secondaryTextColor = AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightSurface,
        title: Text(
          'Ride History',
          style: AppTypography.headingMedium(color: primaryTextColor),
        ),
        centerTitle: false,
      ),
      body: BlocBuilder<TripBloc, TripState>(
        builder: (context, state) {
          if (state.isLoading && state.trips.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          return Column(
            children: [
              // Filters
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    _buildFilterChip(context, 'Upcoming', state.filterType),
                    const SizedBox(width: 8),
                    _buildFilterChip(context, 'Completed', state.filterType),
                    const SizedBox(width: 8),
                    _buildFilterChip(context, 'Cancelled', state.filterType),
                  ],
                ),
              ),

              // Trip List
              Expanded(
                child: state.filteredTrips.isEmpty
                    ? Center(
                        child: Text(
                          'No ${state.filterType.toLowerCase()} trips found.',
                          style: AppTypography.bodyMedium(
                            color: secondaryTextColor,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: AppSpacing.screenPadding,
                        itemCount: state.filteredTrips.length,
                        itemBuilder: (context, index) {
                          final trip = state.filteredTrips[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
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
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        trip.date,
                                        style: AppTypography.bodySmall(
                                          color: secondaryTextColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '\$${trip.fare.toStringAsFixed(2)}',
                                        style: AppTypography.headingSmall(
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.person,
                                        size: 20,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        trip.customerName,
                                        style: AppTypography.bodyMedium(
                                          color: primaryTextColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.my_location_rounded,
                                        size: 18,
                                        color: Color(0xFF10B981),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          trip.pickupLocation,
                                          style: AppTypography.bodyMedium(
                                            color: primaryTextColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(left: 8),
                                    child: SizedBox(
                                      height: 12,
                                      child: VerticalDivider(
                                        color: Colors.grey,
                                        thickness: 1,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on_rounded,
                                        size: 18,
                                        color: AppColors.error,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          trip.destination,
                                          style: AppTypography.bodyMedium(
                                            color: primaryTextColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  if (trip.status == 'Upcoming')
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          // Navigate to Active Trip Screen
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        child: const Text('Start Trip'),
                                      ),
                                    )
                                  else
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton(
                                        onPressed: () {
                                          // Navigate to Trip Details
                                        },
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor:
                                              trip.status == 'Completed'
                                              ? const Color(0xFF10B981)
                                              : AppColors.error,
                                          side: BorderSide(
                                            color: trip.status == 'Completed'
                                                ? const Color(0xFF10B981)
                                                : AppColors.error,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        child: const Text('View Details'),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    String currentFilter,
  ) {
    final isSelected = label == currentFilter;
    return GestureDetector(
      onTap: () {
        context.read<TripBloc>().add(FilterTripsEvent(label));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
