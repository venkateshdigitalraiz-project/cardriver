import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../injection_container.dart';
import '../../../auth/domain/entities/customer_entity.dart';
import '../../domain/entities/d_to_d_booking_entity.dart';
import '../bloc/d_to_d_bookings/d_to_d_bookings_bloc.dart';
import '../bloc/d_to_d_bookings/d_to_d_bookings_event.dart';
import '../bloc/d_to_d_bookings/d_to_d_bookings_state.dart';

/// Screen displaying all Driver-to-Driver (D-to-D) bookings.
/// Follows Clean Architecture with BLoC.
/// Fetches: GET /api/driver/d-to-d-bookings?page=1&limit=10
class DtoDBookingsPage extends StatelessWidget {
  final CustomerEntity? customer;
  final String? driverToken;

  const DtoDBookingsPage({super.key, this.customer, this.driverToken});

  @override
  Widget build(BuildContext context) {
    final effectiveToken = driverToken ?? customer?.token;

    return BlocProvider<DtoDBookingsBloc>(
      create: (context) => InjectionContainer.createDtoDBookingsBloc(
        driverToken: effectiveToken,
      ),
      child: _DtoDBookingsView(customer: customer, driverToken: effectiveToken),
    );
  }
}

class _DtoDBookingsView extends StatefulWidget {
  final CustomerEntity? customer;
  final String? driverToken;

  const _DtoDBookingsView({this.customer, this.driverToken});

  @override
  State<_DtoDBookingsView> createState() => _DtoDBookingsViewState();
}

class _DtoDBookingsViewState extends State<_DtoDBookingsView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Trigger load more when 200px before bottom
    if (currentScroll >= (maxScroll - 200)) {
      context.read<DtoDBookingsBloc>().add(
        LoadMoreDtoDBookingsEvent(token: widget.driverToken),
      );
    }
  }

  Future<void> _onRefresh() async {
    final currentState = context.read<DtoDBookingsBloc>().state;
    if (currentState is DtoDBookingsLoaded) {
      context.read<DtoDBookingsBloc>().add(
        LoadDtoDBookingsEvent(
          page: 1,
          limit: 10,
          isRefresh: true,
          token: widget.driverToken,
          status: currentState.status,
          serviceType: currentState.serviceType,
          tripType: currentState.tripType,
          durationDays: currentState.durationDays,
          durationHours: currentState.durationHours,
        ),
      );
    } else {
      context.read<DtoDBookingsBloc>().add(
        LoadDtoDBookingsEvent(
          page: 1,
          limit: 10,
          isRefresh: true,
          token: widget.driverToken,
        ),
      );
    }
  }

  void _showFilterBottomSheet() {
    final currentState = context.read<DtoDBookingsBloc>().state;
    String currentStatus = 'pending';
    String currentServiceType = 'outstation';
    String currentTripType = 'one_way';
    String currentDuration = '';

    if (currentState is DtoDBookingsLoaded) {
      if (currentState.status != null && currentState.status!.isNotEmpty) {
        currentStatus = currentState.status!;
      }
      if (currentState.serviceType != null &&
          currentState.serviceType!.isNotEmpty) {
        currentServiceType = currentState.serviceType!;
      }
      if (currentState.tripType != null && currentState.tripType!.isNotEmpty) {
        currentTripType = currentState.tripType!;
      }
      if (currentState.durationDays != null && currentState.durationDays! > 0) {
        currentDuration = currentState.durationDays!.toString();
      } else if (currentState.durationHours != null &&
          currentState.durationHours! > 0) {
        currentDuration = currentState.durationHours!.toString();
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => DtoDBookingsFilterBottomSheet(
        initialStatus: currentStatus,
        initialServiceType: currentServiceType,
        initialTripType: currentTripType,
        initialDuration: currentDuration,
        onReset: () {
          Navigator.of(modalContext).pop();
          context.read<DtoDBookingsBloc>().add(
            LoadDtoDBookingsEvent(
              page: 1,
              limit: 10,
              isRefresh: true,
              token: widget.driverToken,
            ),
          );
        },
        onApply: (status, serviceType, tripType, duration) {
          Navigator.of(modalContext).pop();
          final durationInt = int.tryParse(duration);
          final isLocal = serviceType.toLowerCase() == 'local';
          final durationHours = isLocal ? durationInt : null;
          final durationDays = !isLocal ? durationInt : null;

          context.read<DtoDBookingsBloc>().add(
            LoadDtoDBookingsEvent(
              page: 1,
              limit: 10,
              isRefresh: true,
              token: widget.driverToken,
              status: status == 'all' ? null : status,
              serviceType: serviceType,
              tripType: tripType,
              durationDays: durationDays,
              durationHours: durationHours,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryDark = Color(0xFF0F172A);
    const emeraldColor = Color(0xFF10B981);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: primaryDark,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'D-to-D Bookings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Driver to Driver Network Bookings',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          BlocBuilder<DtoDBookingsBloc, DtoDBookingsState>(
            builder: (context, state) {
              final hasActiveFilter =
                  state is DtoDBookingsLoaded &&
                  ((state.status != null &&
                          state.status!.isNotEmpty &&
                          state.status != 'all') ||
                      (state.serviceType != null &&
                          state.serviceType!.isNotEmpty) ||
                      (state.tripType != null && state.tripType!.isNotEmpty) ||
                      (state.durationDays != null && state.durationDays! > 0) ||
                      (state.durationHours != null &&
                          state.durationHours! > 0));

              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    tooltip: 'Filter Bookings',
                    icon: const Icon(
                      Icons.tune_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    onPressed: _showFilterBottomSheet,
                  ),
                  if (hasActiveFilter)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: BlocConsumer<DtoDBookingsBloc, DtoDBookingsState>(
        listener: (context, state) {
          if (state is DtoDBookingsLoaded && state.loadMoreError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.loadMoreError!),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is DtoDBookingsLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(emeraldColor),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading bookings...',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is DtoDBookingsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        color: Colors.red.shade600,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Failed to load bookings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: primaryDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<DtoDBookingsBloc>().add(
                          LoadDtoDBookingsEvent(
                            page: 1,
                            limit: 10,
                            token: widget.driverToken,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is DtoDBookingsLoaded) {
            final bookings = state.bookings;
            final hasActiveFilter =
                (state.status != null &&
                    state.status!.isNotEmpty &&
                    state.status != 'all') ||
                (state.serviceType != null && state.serviceType!.isNotEmpty) ||
                (state.tripType != null && state.tripType!.isNotEmpty) ||
                (state.durationDays != null && state.durationDays! > 0) ||
                (state.durationHours != null && state.durationHours! > 0);

            return Column(
              children: [
                if (hasActiveFilter) _buildActiveFiltersBanner(state),
                Expanded(
                  child: bookings.isEmpty
                      ? RefreshIndicator(
                          color: emeraldColor,
                          onRefresh: _onRefresh,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(24),
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.12,
                              ),
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE2E8F0),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.alt_route_rounded,
                                    size: 56,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                hasActiveFilter
                                    ? 'No Bookings Match Filters'
                                    : 'No D-to-D Bookings Yet',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                  color: primaryDark,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                hasActiveFilter
                                    ? 'Try resetting your filter options to see all driver-to-driver bookings.'
                                    : 'You haven\'t posted any Driver-to-Driver bookings yet. Tap below to create your first booking.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 13.5,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 28),

                              // Center(
                              //   child: SizedBox(
                              //     width: 220,
                              //     height: 46,
                              //     child: ElevatedButton.icon(
                              //       onPressed: () {
                              //         if (hasActiveFilter) {
                              //           context.read<DtoDBookingsBloc>().add(
                              //             LoadDtoDBookingsEvent(
                              //               page: 1,
                              //               limit: 10,
                              //               isRefresh: true,
                              //               token: widget.driverToken,
                              //             ),
                              //           );
                              //         } else {
                              //           context.push(
                              //             AppRoutes.createRide,
                              //             extra: {'customer': widget.customer},
                              //           );
                              //         }
                              //       },
                              //       style: ElevatedButton.styleFrom(
                              //         backgroundColor: emeraldColor,
                              //         foregroundColor: Colors.white,
                              //         elevation: 0,
                              //         shape: RoundedRectangleBorder(
                              //           borderRadius: BorderRadius.circular(12),
                              //         ),
                              //       ),
                              //       icon: Icon(
                              //         hasActiveFilter
                              //             ? Icons.filter_alt_off_rounded
                              //             : Icons.add_rounded,
                              //         size: 20,
                              //       ),
                              //       label: Text(
                              //         hasActiveFilter
                              //             ? 'Clear Filters'
                              //             : 'Post New Booking',
                              //         style: const TextStyle(
                              //           fontSize: 14.5,
                              //           fontWeight: FontWeight.w700,
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          color: emeraldColor,
                          onRefresh: _onRefresh,
                          child: ListView.separated(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                            itemCount:
                                bookings.length + (state.hasMore ? 1 : 0),
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 14),
                            itemBuilder: (context, index) {
                              if (index >= bookings.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              emeraldColor,
                                            ),
                                      ),
                                    ),
                                  ),
                                );
                              }

                              final booking = bookings[index];
                              return _DtoDBookingCard(booking: booking);
                            },
                          ),
                        ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),

      // bottomNavigationBar: Container(
      //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      //   decoration: BoxDecoration(
      //     color: Colors.white,
      //     boxShadow: [
      //       BoxShadow(
      //         color: Colors.black.withOpacity(0.05),
      //         blurRadius: 10,
      //         offset: const Offset(0, -3),
      //       ),
      //     ],
      //   ),
      //   child: SafeArea(
      //     child: SizedBox(
      //       height: 48,
      //       child: ElevatedButton.icon(
      //         onPressed: () {
      //           context.push(
      //             AppRoutes.createRide,
      //             extra: {'customer': widget.customer},
      //           );
      //         },
      //         style: ElevatedButton.styleFrom(
      //           backgroundColor: primaryDark,
      //           foregroundColor: Colors.white,
      //           elevation: 0,
      //           shape: RoundedRectangleBorder(
      //             borderRadius: BorderRadius.circular(12),
      //           ),
      //         ),
      //         icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
      //         label: const Text(
      //           'Post New D-to-D Booking',
      //           style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
      //         ),
      //       ),
      //     ),
      //   ),
      // ),
    );
  }

  Widget _buildActiveFiltersBanner(DtoDBookingsLoaded state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFF1F5F9),
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.filter_alt_rounded,
            size: 15,
            color: Color(0xFF0F172A),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (state.status != null &&
                      state.status!.isNotEmpty &&
                      state.status != 'all')
                    _buildActivePill('Status: ${state.status!.toUpperCase()}'),
                  if (state.serviceType != null &&
                      state.serviceType!.isNotEmpty)
                    _buildActivePill(
                      'Service: ${state.serviceType!.toUpperCase()}',
                    ),
                  if (state.tripType != null && state.tripType!.isNotEmpty)
                    _buildActivePill(
                      state.tripType == 'one_way'
                          ? 'Trip: ONE WAY'
                          : 'Trip: ROUND TRIP',
                    ),
                  if (state.durationDays != null && state.durationDays! > 0)
                    _buildActivePill('Duration: ${state.durationDays} DAYS'),
                  if (state.durationHours != null && state.durationHours! > 0)
                    _buildActivePill('Duration: ${state.durationHours} HOURS'),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: () {
              context.read<DtoDBookingsBloc>().add(
                LoadDtoDBookingsEvent(
                  page: 1,
                  limit: 10,
                  isRefresh: true,
                  token: widget.driverToken,
                ),
              );
            },
            borderRadius: BorderRadius.circular(4),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Text(
                'Clear',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFEF4444),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivePill(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF334155),
        ),
      ),
    );
  }
}

/// Card representing a single Driver-to-Driver booking
class _DtoDBookingCard extends StatelessWidget {
  final DtoDBookingEntity booking;

  const _DtoDBookingCard({required this.booking});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'active':
        return const Color(0xFF10B981);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'completed':
        return const Color(0xFF3B82F6);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF64748B);
    }
  }

  String _formatDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(raw);
      final local = dt.toLocal();
      final day = local.day.toString().padLeft(2, '0');
      final month = _monthName(local.month);
      final year = local.year;
      final hour = local.hour > 12
          ? local.hour - 12
          : (local.hour == 0 ? 12 : local.hour);
      final minute = local.minute.toString().padLeft(2, '0');
      final ampm = local.hour >= 12 ? 'PM' : 'AM';
      return '$day $month $year, $hour:$minute $ampm';
    } catch (_) {
      return raw;
    }
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(booking.status);
    final bookingCode = booking.bookingId.isNotEmpty
        ? booking.bookingId
        : (booking.id.isNotEmpty
              ? '#${booking.id.length > 8 ? booking.id.substring(0, 8).toUpperCase() : booking.id.toUpperCase()}'
              : '#D2D-BOOKING');

    final isOutstation = booking.serviceType.toLowerCase().contains(
      'outstation',
    );
    final isLocal = booking.serviceType.toLowerCase().contains('local');
    final isOneWay =
        booking.tripType.toLowerCase().contains('one_way') ||
        booking.tripType.toLowerCase().contains('oneway');

    final durationText =
        booking.durationDays != null && booking.durationDays! > 0
        ? '${booking.durationDays} Day${booking.durationDays! > 1 ? 's' : ''}'
        : (booking.durationHours != null && booking.durationHours! > 0
              ? '${booking.durationHours} Hr${booking.durationHours! > 1 ? 's' : ''}'
              : null);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar: Booking ID + Status Badge + Price
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        bookingCode,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          booking.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹${booking.totalAmount}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF10B981),
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Service & Trip Type Tags
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildChip(
                  label: isOutstation
                      ? 'Outstation'
                      : (isLocal ? 'Local' : booking.serviceType),
                  icon: isOutstation
                      ? Icons.landscape_rounded
                      : Icons.location_city_rounded,
                  color: const Color(0xFF3B82F6),
                ),
                _buildChip(
                  label: isOneWay ? 'One Way' : 'Round Trip',
                  icon: isOneWay
                      ? Icons.arrow_right_alt_rounded
                      : Icons.sync_alt_rounded,
                  color: const Color(0xFF8B5CF6),
                ),
                if (booking.vehicleType.isNotEmpty)
                  _buildChip(
                    label: booking.vehicleType.toUpperCase(),
                    icon: Icons.directions_car_filled_rounded,
                    color: const Color(0xFF0F172A),
                  ),
                if (booking.transmission.isNotEmpty)
                  _buildChip(
                    label: booking.transmission.toUpperCase(),
                    icon: Icons.settings_rounded,
                    color: const Color(0xFF64748B),
                  ),
                if (durationText != null)
                  _buildChip(
                    label: durationText,
                    icon: Icons.schedule_rounded,
                    color: const Color(0xFFF59E0B),
                  ),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 14),

            // Route: Pickup & Drop
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    const Icon(
                      Icons.circle,
                      size: 10,
                      color: Color(0xFF10B981),
                    ),
                    Container(
                      width: 1.5,
                      height: 28,
                      color: const Color(0xFFCBD5E1),
                    ),
                    const Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: Color(0xFFEF4444),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.pickupAddress.isNotEmpty
                            ? booking.pickupAddress
                            : 'Pickup location not specified',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        booking.dropAddress.isNotEmpty
                            ? booking.dropAddress
                            : 'Drop location not specified',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Time & Date info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Pickup: ${_formatDateTime(booking.scheduledStartTime)}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF475569),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (booking.returnDate != null &&
                      booking.returnDate!.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Return: ${_formatDateTime(booking.returnDate)}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF475569),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Driver return options (if outstation one-way)
            if (booking.driverReturnOption.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.transfer_within_a_station_rounded,
                    size: 14,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Return Travel: ',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  ...booking.driverReturnOption.map((opt) {
                    final isBus = opt.toLowerCase().contains('bus');
                    final label = isBus
                        ? 'Bus'
                        : (opt.toLowerCase().contains('train') ? 'Train' : opt);
                    return Container(
                      margin: const EdgeInsets.only(right: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF334155),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],

            // User Notes (if any)
            if (booking.userNotes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.notes_rounded,
                    size: 14,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      booking.userNotes,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF64748B),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Filter Bottom Sheet for D-to-D Bookings
class DtoDBookingsFilterBottomSheet extends StatefulWidget {
  final String initialStatus;
  final String initialServiceType;
  final String initialTripType;
  final String initialDuration;
  final Function(
    String status,
    String serviceType,
    String tripType,
    String duration,
  )
  onApply;
  final VoidCallback onReset;

  const DtoDBookingsFilterBottomSheet({
    super.key,
    required this.initialStatus,
    required this.initialServiceType,
    required this.initialTripType,
    required this.initialDuration,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<DtoDBookingsFilterBottomSheet> createState() =>
      _DtoDBookingsFilterBottomSheetState();
}

class _DtoDBookingsFilterBottomSheetState
    extends State<DtoDBookingsFilterBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late String _status;
  late String _serviceType;
  late String _tripType;
  late TextEditingController _durationController;

  @override
  void initState() {
    super.initState();
    final init = widget.initialStatus.toLowerCase().trim();
    _status = (init == 'pending' || init == 'confirmed' || init == 'completed')
        ? init
        : 'pending';
    _serviceType = widget.initialServiceType.isNotEmpty
        ? widget.initialServiceType
        : 'outstation';
    _tripType = widget.initialTripType.isNotEmpty
        ? widget.initialTripType
        : 'one_way';
    _durationController = TextEditingController(text: widget.initialDuration);
  }

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  bool get isLocal => _serviceType.toLowerCase() == 'local';

  void _submitFilter() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onApply(
        _status,
        _serviceType,
        _tripType,
        _durationController.text.trim(),
      );
    }
  }

  Widget _buildFieldSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF334155),
        fontWeight: FontWeight.w600,
        fontSize: 13,
        letterSpacing: 0.1,
      ),
    );
  }

  Widget _buildSegmentOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? const Color(0xFF0F172A)
                  : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF0F172A)
                        : const Color(0xFF475569),
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF64748B)
                        : const Color(0xFF94A3B8),
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Colors.white,
        colorScheme: Theme.of(context).colorScheme.copyWith(
          surface: Colors.white,
          onSurface: const Color(0xFF0F172A),
        ),
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: const Color(0xFF0F172A),
          displayColor: const Color(0xFF0F172A),
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Header: Title + Reset Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.tune_rounded,
                            size: 20,
                            color: Color(0xFF0F172A),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Filter Bookings',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: widget.onReset,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFEF4444),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text(
                          'Reset',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 14),

                  // Dropdown: Booking Status
                  _buildFieldSectionLabel('Booking Status'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _status,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                    icon: const Icon(
                      Icons.arrow_drop_down_rounded,
                      color: Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.flag_rounded,
                        size: 18,
                        color: Color(0xFF64748B),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF0F172A),
                          width: 1.5,
                        ),
                      ),
                    ),
                    dropdownColor: Colors.white,
                    selectedItemBuilder: (BuildContext context) {
                      return const [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Pending',
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Confirmed',
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Completed',
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ];
                    },
                    items: const [
                      DropdownMenuItem(
                        value: 'pending',
                        child: Text(
                          'Pending',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'confirmed',
                        child: Text(
                          'Confirmed',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'completed',
                        child: Text(
                          'Completed',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _status = val);
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // Row 1: Service Type Segmented Selector
                  _buildFieldSectionLabel('Service Type'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildSegmentOption(
                            title: 'Local',
                            subtitle: 'Within city',
                            icon: Icons.apartment_rounded,
                            isSelected: isLocal,
                            onTap: () {
                              if (!isLocal) {
                                setState(() {
                                  _serviceType = 'local';
                                  if (_durationController.text.trim().isEmpty ||
                                      _durationController.text.trim() == '1') {
                                    _durationController.text = '2';
                                  }
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: _buildSegmentOption(
                            title: 'Outstation',
                            subtitle: 'Inter-city travel',
                            icon: Icons.directions_car_rounded,
                            isSelected: !isLocal,
                            onTap: () {
                              if (isLocal) {
                                setState(() {
                                  _serviceType = 'outstation';
                                  if (_durationController.text.trim().isEmpty ||
                                      _durationController.text.trim() == '2') {
                                    _durationController.text = '1';
                                  }
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Row 2: Trip Type Segmented Selector
                  // _buildFieldSectionLabel('Trip Type'),
                  // const SizedBox(height: 8),
                  // Container(
                  //   padding: const EdgeInsets.all(4),
                  //   decoration: BoxDecoration(
                  //     color: const Color(0xFFF1F5F9),
                  //     borderRadius: BorderRadius.circular(12),
                  //   ),
                  //   child: Row(
                  //     children: [
                  //       Expanded(
                  //         child: _buildSegmentOption(
                  //           title: 'One Way',
                  //           subtitle: 'Single drop',
                  //           icon: Icons.arrow_forward_rounded,
                  //           isSelected: _tripType == 'one_way',
                  //           onTap: () {
                  //             if (_tripType != 'one_way') {
                  //               setState(() => _tripType = 'one_way');
                  //             }
                  //           },
                  //         ),
                  //       ),
                  //       const SizedBox(width: 4),
                  //       Expanded(
                  //         child: _buildSegmentOption(
                  //           title: 'Round Trip',
                  //           subtitle: 'Return journey',
                  //           icon: Icons.sync_alt_rounded,
                  //           isSelected: _tripType == 'round_trip',
                  //           onTap: () {
                  //             if (_tripType != 'round_trip') {
                  //               setState(() => _tripType = 'round_trip');
                  //             }
                  //           },
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),

                  // const SizedBox(height: 16),

                  // // Row 3: Duration Input
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     _buildFieldSectionLabel(
                  //       isLocal ? 'Duration (Hours)' : 'Duration (Days)',
                  //     ),
                  //     Text(
                  //       isLocal ? 'Min 1 hour' : 'Min 1 day',
                  //       style: const TextStyle(
                  //         color: Color(0xFF94A3B8),
                  //         fontSize: 11,
                  //         fontWeight: FontWeight.w500,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(height: 8),
                  // TextFormField(
                  //   controller: _durationController,
                  //   keyboardType: TextInputType.number,
                  //   style: const TextStyle(
                  //     color: Color(0xFF0F172A),
                  //     fontSize: 15,
                  //     fontWeight: FontWeight.w600,
                  //   ),
                  //   cursorColor: const Color(0xFF0F172A),
                  //   inputFormatters: [
                  //     FilteringTextInputFormatter.digitsOnly,
                  //     LengthLimitingTextInputFormatter(3),
                  //   ],
                  //   decoration: InputDecoration(
                  //     hintText: isLocal ? 'e.g. 2, 4, 8' : 'e.g. 1, 2, 3',
                  //     hintStyle: const TextStyle(
                  //       color: Color(0xFF94A3B8),
                  //       fontSize: 14,
                  //       fontWeight: FontWeight.w400,
                  //     ),
                  //     prefixIcon: Icon(
                  //       isLocal
                  //           ? Icons.schedule_rounded
                  //           : Icons.calendar_view_day_rounded,
                  //       color: const Color(0xFF64748B),
                  //       size: 20,
                  //     ),
                  //     suffixIcon: Container(
                  //       padding: const EdgeInsets.symmetric(
                  //         horizontal: 14,
                  //         vertical: 12,
                  //       ),
                  //       child: Text(
                  //         isLocal ? 'Hours' : 'Days',
                  //         style: const TextStyle(
                  //           color: Color(0xFF475569),
                  //           fontSize: 13,
                  //           fontWeight: FontWeight.w600,
                  //         ),
                  //       ),
                  //     ),
                  //     filled: true,
                  //     fillColor: const Color(0xFFF8FAFC),
                  //     contentPadding: const EdgeInsets.symmetric(
                  //       horizontal: 14,
                  //       vertical: 14,
                  //     ),
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(12),
                  //       borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  //     ),
                  //     enabledBorder: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(12),
                  //       borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  //     ),
                  //     focusedBorder: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(12),
                  //       borderSide: const BorderSide(
                  //         color: Color(0xFF0F172A),
                  //         width: 1.5,
                  //       ),
                  //     ),
                  //   ),
                  //   validator: (value) {
                  //     if (value == null || value.trim().isEmpty) {
                  //       return null; // Optional in filter
                  //     }
                  //     final val = int.tryParse(value.trim());
                  //     if (val == null || val <= 0) {
                  //       return 'Duration must be greater than 0';
                  //     }
                  //     return null;
                  //   },
                  // ),
                  const SizedBox(height: 24),

                  // Row with Cancel and OK buttons
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF475569),
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _submitFilter,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F172A),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'OK',
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(Icons.check_rounded, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
