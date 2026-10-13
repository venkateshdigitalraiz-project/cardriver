import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/style/app_colors.dart';
import '../../../../core/style/app_spacing.dart';
import '../../../../core/style/app_typography.dart';
import '../../domain/entities/trip_entity.dart';
import '../bloc/trip_details_bloc.dart';
import '../bloc/trip_details_event.dart';
import '../bloc/trip_details_state.dart';

class TripDetailsPage extends StatelessWidget {
  final TripEntity trip;

  const TripDetailsPage({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TripDetailsBloc()..add(LoadTripDetailsEvent(trip: trip)),
      child: const _TripDetailsView(),
    );
  }
}

class _TripDetailsView extends StatelessWidget {
  const _TripDetailsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightSurface,
        title: Text(
          'Trip Details',
          style: AppTypography.headingMedium(color: AppColors.textPrimaryLight),
        ),
      ),
      body: BlocBuilder<TripDetailsBloc, TripDetailsState>(
        builder: (context, state) {
          if (state is TripDetailsLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          } else if (state is TripDetailsLoaded) {
            final trip = state.trip;
            return SingleChildScrollView(
              padding: AppSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Receipt Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Total Fare',
                          style: AppTypography.bodyMedium(color: AppColors.textSecondaryLight),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$${trip.fare.toStringAsFixed(2)}',
                          style: AppTypography.headingLarge(color: AppColors.primary),
                        ),
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),
                        _buildDetailRow('Date', trip.date),
                        const SizedBox(height: 12),
                        _buildDetailRow('Customer', trip.customerName),
                        const SizedBox(height: 12),
                        _buildDetailRow('Status', trip.status, isStatus: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Location Details
                  Text(
                    'Route',
                    style: AppTypography.headingMedium(color: AppColors.textPrimaryLight),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.circle, color: Color(0xFF10B981), size: 16),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Pickup', style: AppTypography.bodySmall(color: AppColors.textSecondaryLight)),
                                  Text(trip.pickupLocation, style: AppTypography.bodyMedium(color: AppColors.textPrimaryLight)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 7),
                          child: Container(
                            height: 30,
                            width: 2,
                            color: Colors.grey.shade300,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: AppColors.error, size: 16),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Dropoff', style: AppTypography.bodySmall(color: AppColors.textSecondaryLight)),
                                  Text(trip.destination, style: AppTypography.bodyMedium(color: AppColors.textPrimaryLight)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.help_outline),
                      label: const Text('Report an Issue'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        foregroundColor: AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('Error loading trip details'));
          }
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isStatus = false}) {
    Color valueColor = AppColors.textPrimaryLight;
    if (isStatus) {
      valueColor = value == 'Completed' ? const Color(0xFF10B981) : AppColors.error;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium(color: AppColors.textSecondaryLight),
        ),
        Text(
          value,
          style: AppTypography.bodyMedium(color: valueColor).copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
