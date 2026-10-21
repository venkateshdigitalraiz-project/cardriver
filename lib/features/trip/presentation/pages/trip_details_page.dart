import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/style/app_colors.dart';
import '../../../../core/style/app_typography.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/trip_entity.dart';
import '../bloc/trip_details_bloc.dart';
import '../bloc/trip_details_event.dart';
import '../bloc/trip_details_state.dart';

class TripDetailsPage extends StatelessWidget {
  final TripEntity? trip;
  final String? bookingId;
  final String? driverToken;

  const TripDetailsPage({
    super.key,
    required TripEntity this.trip,
    this.bookingId,
    this.driverToken,
  });

  const TripDetailsPage.fromId({
    super.key,
    required String this.bookingId,
    this.driverToken,
  }) : trip = null;

  @override
  Widget build(BuildContext context) {
    final targetId = bookingId ?? trip?.id ?? trip?.bookingId ?? '';

    return BlocProvider(
      create: (_) =>
          InjectionContainer.createTripDetailsBloc(driverToken: driverToken)
            ..add(
              LoadTripDetailsEvent(
                bookingId: targetId,
                trip: trip,
                token: driverToken,
              ),
            ),
      child: _TripDetailsView(bookingId: targetId, driverToken: driverToken),
    );
  }
}

class _TripDetailsView extends StatelessWidget {
  final String bookingId;
  final String? driverToken;

  const _TripDetailsView({required this.bookingId, this.driverToken});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimaryLight,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Booking Details',
          style: AppTypography.headingMedium(color: AppColors.textPrimaryLight),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: () {
              context.read<TripDetailsBloc>().add(
                RefreshTripDetailsEvent(
                  bookingId: bookingId,
                  token: driverToken,
                ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<TripDetailsBloc, TripDetailsState>(
        listener: (context, state) {
          if (state is TripDetailsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          TripEntity? trip;
          bool isInitialLoading = false;
          bool isRefreshing = false;

          if (state is TripDetailsLoading) {
            trip = state.cachedTrip;
            isInitialLoading = trip == null;
          } else if (state is TripDetailsLoaded) {
            trip = state.trip;
            isRefreshing = state.isRefreshing;
          } else if (state is TripDetailsError) {
            trip = state.cachedTrip;
          }

          if (isInitialLoading) {
            return _buildLoadingSkeleton();
          }

          if (trip == null) {
            return _buildErrorState(context);
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              context.read<TripDetailsBloc>().add(
                RefreshTripDetailsEvent(
                  bookingId: bookingId,
                  token: driverToken,
                ),
              );
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isRefreshing)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: LinearProgressIndicator(
                        minHeight: 2,
                        color: AppColors.primary,
                      ),
                    ),

                  // 1. Hero Summary Card (Fare, Earnings, Booking ID, Status)
                  _buildHeroSummaryCard(context, trip),

                  const SizedBox(height: 16),

                  // 3. Route & Schedule Card (Pickup, Drop, Coordinates, Timing)
                  _buildRouteCard(trip),

                  const SizedBox(height: 16),

                  // 4. Passenger Details Card (Name, Phone, Email, Address, CustId)
                  _buildPassengerCard(context, trip),

                  const SizedBox(height: 16),

                  // 5. Vehicle & Service Specifications Card
                  _buildVehicleCard(trip),

                  const SizedBox(height: 16),

                  // 6. Detailed Fare Breakdown Card
                  _buildFareBreakdownCard(trip),

                  const SizedBox(height: 24),

                  // 8. Action Buttons
                  //    _buildActionButtons(context, trip),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= 1. Hero Summary Card =================

  Widget _buildHeroSummaryCard(BuildContext context, TripEntity trip) {
    final isCompleted = trip.status == 'Completed';
    final isCancelled = trip.status == 'Cancelled';

    Color statusColor;
    Color statusBgColor;
    IconData statusIcon;

    if (isCompleted) {
      statusColor = const Color(0xFF10B981);
      statusBgColor = const Color(0xFFECFDF5);
      statusIcon = Icons.check_circle_rounded;
    } else if (isCancelled) {
      statusColor = AppColors.error;
      statusBgColor = const Color(0xFFFEF2F2);
      statusIcon = Icons.cancel_rounded;
    } else {
      statusColor = const Color(0xFF2563EB);
      statusBgColor = const Color(0xFFEFF6FF);
      statusIcon = Icons.access_time_filled_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Booking ID & Status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  final textToCopy = trip.bookingId.isNotEmpty
                      ? trip.bookingId
                      : trip.id;
                  if (textToCopy.isNotEmpty) {
                    Clipboard.setData(ClipboardData(text: textToCopy));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Copied #$textToCopy to clipboard'),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        trip.bookingId.isNotEmpty
                            ? '#${trip.bookingId}'
                            : '#${trip.id}',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.copy_rounded,
                        size: 13,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      trip.statusBadgeLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Row 2: Total Fare & Driver Earnings
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Expanded(
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Text(
              //         'Total Customer Fare',
              //         style: TextStyle(
              //           fontSize: 12,
              //           fontWeight: FontWeight.w500,
              //           color: Colors.grey.shade600,
              //         ),
              //       ),
              //       const SizedBox(height: 4),
              //       Text(
              //         trip.formattedTotalFare,
              //         style: const TextStyle(
              //           fontSize: 28,
              //           fontWeight: FontWeight.w800,
              //           color: AppColors.primary,
              //           height: 1.1,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              if (trip.driverFee > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Trip Earnings',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF065F46),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        trip.formattedDriverFee,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF047857),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),

          // Row 3: Service Mode, Trip Type, and Payment Badge
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _buildMetaTag(
                Icons.directions_car_rounded,
                '${trip.serviceType.toUpperCase()} • ${trip.tripType.replaceAll('_', ' ').toUpperCase()}',
                const Color(0xFFF1F5F9),
                Colors.grey.shade700,
              ),
              if (trip.durationHours > 0)
                _buildMetaTag(
                  Icons.schedule_rounded,
                  '${trip.durationHours} HOURS',
                  const Color(0xFFEFF6FF),
                  const Color(0xFF1D4ED8),
                ),
              _buildMetaTag(
                Icons.payment_rounded,
                '${trip.paymentMethod.toUpperCase()} (${trip.paymentStatus.toUpperCase()})',
                trip.paymentStatus.toLowerCase() == 'paid'
                    ? const Color(0xFFECFDF5)
                    : const Color(0xFFFEF3C7),
                trip.paymentStatus.toLowerCase() == 'paid'
                    ? const Color(0xFF047857)
                    : const Color(0xFFB45309),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetaTag(IconData icon, String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: fg,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ================= 3. Route Card =================

  Widget _buildRouteCard(TripEntity trip) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.route_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Route & Schedule',
                style: AppTypography.headingSmall(
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Pickup Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(Icons.circle, size: 14, color: Color(0xFF10B981)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PICKUP LOCATION',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade500,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            trip.date,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      trip.pickupAddress,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    if (trip.pickupLat != 0.0 && trip.pickupLng != 0.0) ...[
                      const SizedBox(height: 2),
                      Text(
                        'GPS: ${trip.pickupLat.toStringAsFixed(4)}, ${trip.pickupLng.toStringAsFixed(4)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // Connecting line
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Row(
              children: [
                Container(width: 2, height: 32, color: Colors.grey.shade300),
                const SizedBox(width: 20),
                if (trip.durationHours > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 12,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${trip.durationHours} Hours Duration',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Dropoff Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.location_on_rounded,
                  size: 16,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DROP DESTINATION',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      trip.dropAddress,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    if (trip.dropLat != 0.0 && trip.dropLng != 0.0) ...[
                      const SizedBox(height: 2),
                      Text(
                        'GPS: ${trip.dropLat.toStringAsFixed(4)}, ${trip.dropLng.toStringAsFixed(4)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= 4. Passenger Details Card =================

  Widget _buildPassengerCard(BuildContext context, TripEntity trip) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Customer Information',
                style: AppTypography.headingSmall(
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: const Icon(
                  Icons.person,
                  size: 28,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.customerName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (trip.custId.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'ID: ${trip.custId}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),

          // if (trip.customerPhone.isNotEmpty)
          //   _buildCustomerDetailRow(
          //     Icons.phone_outlined,
          //     'Phone',
          //     trip.customerPhone,
          //     trailing: TextButton.icon(
          //       onPressed: () {
          //         ScaffoldMessenger.of(context).showSnackBar(
          //           SnackBar(
          //             content: Text('Calling ${trip.customerPhone}...'),
          //             behavior: SnackBarBehavior.floating,
          //             duration: const Duration(seconds: 1),
          //           ),
          //         );
          //       },
          //       icon: const Icon(Icons.call, size: 14),
          //       label: const Text('Call'),
          //       style: TextButton.styleFrom(
          //         foregroundColor: const Color(0xFF10B981),
          //         padding: const EdgeInsets.symmetric(
          //           horizontal: 10,
          //           vertical: 4,
          //         ),
          //       ),
          //     ),
          //   ),
          // if (trip.customerEmail.isNotEmpty)
          //   _buildCustomerDetailRow(
          //     Icons.email_outlined,
          //     'Email',
          //     trip.customerEmail,
          //   ),
          // if (trip.customerAddress.isNotEmpty)
          //   _buildCustomerDetailRow(
          //     Icons.location_city_rounded,
          //     'City/Location',
          //     trip.customerAddress.trim(),
          //   ),
          // if (trip.userNotes.isNotEmpty)
          //   _buildCustomerDetailRow(
          //     Icons.note_alt_outlined,
          //     'Notes',
          //     trip.userNotes,
          //   ),
        ],
      ),
    );
  }

  // Widget _buildCustomerDetailRow(
  //   IconData icon,
  //   String label,
  //   String value, {
  //   Widget? trailing,
  // }) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 4),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: [
  //         Icon(icon, size: 15, color: Colors.grey.shade500),
  //         const SizedBox(width: 8),
  //         Text(
  //           '$label: ',
  //           style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
  //         ),
  //         Expanded(
  //           child: Text(
  //             value,
  //             style: const TextStyle(
  //               fontSize: 12,
  //               fontWeight: FontWeight.w600,
  //               color: AppColors.textPrimaryLight,
  //             ),
  //             overflow: TextOverflow.ellipsis,
  //           ),
  //         ),
  //         ?trailing,
  //       ],
  //     ),
  //   );
  // }

  // ================= 5. Vehicle Specifications Card =================

  Widget _buildVehicleCard(TripEntity trip) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.directions_car_filled_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Vehicle & Driving Specifications',
                style: AppTypography.headingSmall(
                  color: AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _buildSpecTile(
                  icon: Icons.directions_car,
                  label: 'Vehicle Type',
                  value: trip.vehicleType.toUpperCase(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSpecTile(
                  icon: Icons.tune,
                  label: 'Transmission',
                  value: trip.transmission.toUpperCase(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildSpecTile(
                  icon: Icons.vpn_key_rounded,
                  label: 'Ownership',
                  value: trip.vehicleOwnership
                      .replaceAll('_', ' ')
                      .toUpperCase(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSpecTile(
                  icon: Icons.people_alt_rounded,
                  label: 'Capacity',
                  value: '${trip.numberOfPassengers} Passenger(s)',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ================= 6. Fare Breakdown Card =================

  Widget _buildFareBreakdownCard(TripEntity trip) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.receipt_long_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Fare Breakdown',
                    style: AppTypography.headingSmall(
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: trip.paymentStatus.toLowerCase() == 'paid'
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${trip.paymentMethod.toUpperCase()} (${trip.paymentStatus.toUpperCase()})',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: trip.paymentStatus.toLowerCase() == 'paid'
                        ? const Color(0xFF047857)
                        : const Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (trip.baseAmount > 0)
            _buildCostRow(
              'Base Fare',
              '₹${trip.baseAmount.toStringAsFixed(0)}',
            ),
          if (trip.driverFee > 0)
            _buildCostRow(
              'Driver Fee (Your Share)',
              '₹${trip.driverFee.toStringAsFixed(0)}',
              valueColor: const Color(0xFF10B981),
            ),
          if (trip.taxAmount > 0)
            _buildCostRow(
              'Tax & GST (5%)',
              '₹${trip.taxAmount.toStringAsFixed(0)}',
            ),
          if (trip.extraKmAmount > 0)
            _buildCostRow(
              'Extra Km Charge',
              '₹${trip.extraKmAmount.toStringAsFixed(0)}',
            ),
          if (trip.platformFee > 0)
            _buildCostRow(
              'Platform Fee',
              '₹${trip.platformFee.toStringAsFixed(0)}',
            ),
          if (trip.discountAmount > 0)
            _buildCostRow(
              'Discount',
              '-₹${trip.discountAmount.toStringAsFixed(0)}',
              valueColor: AppColors.error,
            ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
          ),

          _buildCostRow(
            'Total Customer Amount',
            trip.formattedTotalFare,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCostRow(
    String title,
    String amount, {
    Color? valueColor,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: isTotal ? 14 : 13,
                fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
                color: isTotal
                    ? AppColors.textPrimaryLight
                    : Colors.grey.shade600,
              ),
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: isTotal ? 16 : 13,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
              color:
                  valueColor ??
                  (isTotal ? AppColors.primary : AppColors.textPrimaryLight),
            ),
          ),
        ],
      ),
    );
  }

  // ================= 8. Actions =================

  // Widget _buildActionButtons(BuildContext context, TripEntity trip) {
  //   final isUpcoming = trip.status == 'Upcoming';

  //   return Column(
  //     children: [
  //       if (isUpcoming) ...[
  //         SizedBox(
  //           width: double.infinity,
  //           child: ElevatedButton.icon(
  //             onPressed: () {
  //               Navigator.push(
  //                 context,
  //                 MaterialPageRoute(
  //                   builder: (_) => ActiveRidePage(
  //                     acceptedRide: trip.toAcceptedRideEntity(),
  //                   ),
  //                 ),
  //               );
  //             },
  //             icon: const Icon(Icons.navigation_rounded, size: 20),
  //             label: const Text(
  //               'Start Trip / Open Live Navigation',
  //               style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
  //             ),
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: AppColors.primary,
  //               foregroundColor: Colors.white,
  //               padding: const EdgeInsets.symmetric(vertical: 14),
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(12),
  //               ),
  //               elevation: 0,
  //             ),
  //           ),
  //         ),
  //         const SizedBox(height: 12),
  //       ],

  //       SizedBox(
  //         width: double.infinity,
  //         child: OutlinedButton.icon(
  //           onPressed: () {
  //             ScaffoldMessenger.of(context).showSnackBar(
  //               const SnackBar(
  //                 content: Text('Support ticket feature opened.'),
  //                 behavior: SnackBarBehavior.floating,
  //               ),
  //             );
  //           },
  //           icon: const Icon(Icons.help_outline_rounded, size: 18),
  //           label: const Text(
  //             'Report an Issue / Help Support',
  //             style: TextStyle(fontWeight: FontWeight.w600),
  //           ),
  //           style: OutlinedButton.styleFrom(
  //             padding: const EdgeInsets.symmetric(vertical: 14),
  //             foregroundColor: AppColors.textPrimaryLight,
  //             side: BorderSide(color: Colors.grey.shade300),
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(12),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // ================= Skeletons & Errors =================

  Widget _buildLoadingSkeleton() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            'Fetching booking details from server...',
            style: AppTypography.bodySmall(color: AppColors.textSecondaryLight),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load booking details',
              style: AppTypography.headingSmall(
                color: AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Could not retrieve the booking from the server. Please check connection and try again.',
              style: AppTypography.bodyMedium(
                color: AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                context.read<TripDetailsBloc>().add(
                  RefreshTripDetailsEvent(
                    bookingId: bookingId,
                    token: driverToken,
                  ),
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
