import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/style/app_colors.dart';
import '../../../../core/style/app_typography.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/trip_entity.dart';
import '../../domain/entities/trip_status_update_result.dart';
import '../bloc/trip_bloc.dart';
import '../bloc/trip_event.dart';
import '../bloc/trip_state.dart';

class TripPage extends StatelessWidget {
  final String? driverToken;

  const TripPage({super.key, this.driverToken});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          InjectionContainer.createTripBloc(driverToken: driverToken)
            ..add(LoadTripsEvent(token: driverToken)),
      child: _TripView(driverToken: driverToken),
    );
  }
}

class _TripView extends StatefulWidget {
  final String? driverToken;

  const _TripView({this.driverToken});

  @override
  State<_TripView> createState() => _TripViewState();
}

class _TripViewState extends State<_TripView> {
  bool _isSearchOpen = false;
  final TextEditingController _searchController = TextEditingController();
  String? _shownCompletedBookingId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryTextColor = AppColors.textPrimaryLight;
    final secondaryTextColor = AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        title: _isSearchOpen
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search by booking ID, customer, address...',
                  hintStyle: AppTypography.bodySmall(
                    color: Colors.grey.shade400,
                  ),
                  border: InputBorder.none,
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.primary,
                  ),
                ),
                onChanged: (query) {
                  context.read<TripBloc>().add(SearchTripsEvent(query));
                },
              )
            : Text(
                'My Trips & Bookings',
                style: AppTypography.headingMedium(color: primaryTextColor),
              ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearchOpen ? Icons.close : Icons.search,
              color: primaryTextColor,
            ),
            onPressed: () {
              setState(() {
                if (_isSearchOpen) {
                  _searchController.clear();
                  context.read<TripBloc>().add(const SearchTripsEvent(''));
                }
                _isSearchOpen = !_isSearchOpen;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: () {
              context.read<TripBloc>().add(
                RefreshTripsEvent(token: widget.driverToken),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<TripBloc, TripState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          if (state.statusErrorMessage != null &&
              state.statusErrorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.statusErrorMessage!),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          if (state.statusSuccessMessage != null &&
              state.statusSuccessMessage!.isNotEmpty &&
              state.lastCompletedTripResult == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.statusSuccessMessage!),
                backgroundColor: const Color(0xFF10B981),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          if (state.lastCompletedTripResult != null &&
              _shownCompletedBookingId !=
                  state.lastCompletedTripResult!.bookingId) {
            _shownCompletedBookingId =
                state.lastCompletedTripResult!.bookingId;
            _showTripCompletionDialog(context, state.lastCompletedTripResult!);
          }
        },
        builder: (context, state) {
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              context.read<TripBloc>().add(
                RefreshTripsEvent(token: widget.driverToken),
              );
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // 1. Metrics summary bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                    child: _buildMetricsBar(state),
                  ),
                ),

                // 2. Filter Category Pills
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: _buildFilterChipsRow(context, state),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 8)),

                // 3. Body Content
                if (state.isLoading && state.trips.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildLoadingSkeleton(),
                  )
                else if (state.filteredTrips.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(state, secondaryTextColor),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final trip = state.filteredTrips[index];
                        return _buildTripCard(context, trip, state);
                      }, childCount: state.filteredTrips.length),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= Trip Completed Summary Dialog =================

  void _showTripCompletionDialog(
    BuildContext context,
    TripStatusUpdateResult result,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        final amountStr = result.totalAmount != null
            ? (result.totalAmount! % 1 == 0
                ? '₹${result.totalAmount!.toInt()}'
                : '₹${result.totalAmount!.toStringAsFixed(1)}')
            : '₹0';
        final distStr = result.actualDistance != null
            ? '${result.actualDistance!.toStringAsFixed(1)} km'
            : '';

        String startedStr = '';
        if (result.tripStartedAt != null && result.tripStartedAt!.isNotEmpty) {
          try {
            final dt = DateTime.parse(result.tripStartedAt!).toLocal();
            final hour =
                dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
            final period = dt.hour >= 12 ? 'PM' : 'AM';
            final minute = dt.minute.toString().padLeft(2, '0');
            startedStr = '$hour:$minute $period';
          } catch (_) {
            startedStr = result.tripStartedAt!;
          }
        }

        String completedStr = '';
        if (result.tripCompletedAt != null &&
            result.tripCompletedAt!.isNotEmpty) {
          try {
            final dt = DateTime.parse(result.tripCompletedAt!).toLocal();
            final hour =
                dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
            final period = dt.hour >= 12 ? 'PM' : 'AM';
            final minute = dt.minute.toString().padLeft(2, '0');
            completedStr = '$hour:$minute $period';
          } catch (_) {
            completedStr = result.tripCompletedAt!;
          }
        }

        String durationStr = '';
        if (result.tripStartedAt != null && result.tripCompletedAt != null) {
          try {
            final start = DateTime.parse(result.tripStartedAt!);
            final end = DateTime.parse(result.tripCompletedAt!);
            final mins = end.difference(start).inMinutes;
            if (mins < 60) {
              durationStr = '$mins min${mins == 1 ? '' : 's'}';
            } else {
              durationStr = '${mins ~/ 60}h ${mins % 60}m';
            }
          } catch (_) {}
        }

        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) {
              context
                  .read<TripBloc>()
                  .add(const DismissTripCompletionDialogEvent());
            }
          },
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header row with Close (X) icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 36),
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF10B981)
                                  .withValues(alpha: 0.2),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF10B981),
                            size: 36,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 22),
                          color: Colors.grey.shade600,
                          splashRadius: 20,
                          onPressed: () {
                            Navigator.of(dialogCtx).pop();
                            context
                                .read<TripBloc>()
                                .add(const DismissTripCompletionDialogEvent());
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Title & Message
                    Text(
                      result.message.isNotEmpty
                          ? result.message
                          : 'Trip Completed Successfully!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    if (result.bookingId.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '#${result.bookingId}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Total Fare Highlight Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Total Fare',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            amountStr,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Metrics List (Actual Distance, Duration, Started, Completed)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          if (distStr.isNotEmpty) ...[
                            _buildSummaryItem(
                              icon: Icons.straighten_rounded,
                              label: 'Actual Distance',
                              value: distStr,
                            ),
                            const Divider(height: 14, thickness: 0.5),
                          ],
                          if (durationStr.isNotEmpty) ...[
                            _buildSummaryItem(
                              icon: Icons.timer_outlined,
                              label: 'Trip Duration',
                              value: durationStr,
                            ),
                            const Divider(height: 14, thickness: 0.5),
                          ],
                          if (startedStr.isNotEmpty) ...[
                            _buildSummaryItem(
                              icon: Icons.play_arrow_outlined,
                              label: 'Started At',
                              value: startedStr,
                            ),
                            const Divider(height: 14, thickness: 0.5),
                          ],
                          if (completedStr.isNotEmpty) ...[
                            _buildSummaryItem(
                              icon: Icons.flag_outlined,
                              label: 'Completed At',
                              value: completedStr,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // View in Completed Bookings button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogCtx).pop();
                          context
                              .read<TripBloc>()
                              .add(const DismissTripCompletionDialogEvent());
                          context.read<TripBloc>().add(
                                const FilterTripsEvent('Completed'),
                              );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'View in Completed Bookings',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Close button
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(dialogCtx).pop();
                          context
                              .read<TripBloc>()
                              .add(const DismissTripCompletionDialogEvent());
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Close',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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




  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }

  // ================= Metrics Strip =================

  Widget _buildMetricsBar(TripState state) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricTile(
            title: 'Upcoming',
            count: state.upcomingCount,
            icon: Icons.schedule_rounded,
            color: const Color(0xFF2563EB),
            bgColor: const Color(0xFFEFF6FF),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricTile(
            title: 'Completed',
            count: state.completedCount,
            icon: Icons.check_circle_rounded,
            color: const Color(0xFF10B981),
            bgColor: const Color(0xFFECFDF5),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildMetricTile(
            title: 'Total',
            count: state.totalCount,
            icon: Icons.format_list_bulleted_rounded,
            color: const Color(0xFF6B21A8),
            bgColor: const Color(0xFFFAF5FF),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ================= Filter Chips =================

  Widget _buildFilterChipsRow(BuildContext context, TripState state) {
    final filters = [
      {'label': 'All', 'count': state.totalCount},
      {'label': 'Upcoming', 'count': state.upcomingCount},
      {'label': 'Completed', 'count': state.completedCount},
      {'label': 'Cancelled', 'count': state.cancelledCount},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((f) {
          final label = f['label'] as String;
          final count = f['count'] as int;
          final isSelected = state.filterType == label;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                context.read<TripBloc>().add(FilterTripsEvent(label));
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : Colors.grey.shade300,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    if (count > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.25)
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ================= Trip Card =================

  Widget _buildTripCard(
    BuildContext context,
    TripEntity trip,
    TripState state,
  ) {
    return _TripCardWidget(
      key: ValueKey(trip.bookingId.isNotEmpty ? trip.bookingId : trip.id),
      trip: trip,
      state: state,
      driverToken: widget.driverToken,
    );
  }

  // ================= Loading & Empty States =================

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 3,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildEmptyState(TripState state, Color secondaryTextColor) {
    final isFiltered = state.filterType != 'All';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_car_outlined,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isFiltered
                  ? 'No ${state.filterType.toLowerCase()} trips found'
                  : 'No bookings assigned yet',
              style: AppTypography.headingSmall(
                color: AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? 'Switch filter tabs or pull down to check for new bookings.'
                  : 'Your assigned and completed bookings will appear right here.',
              style: AppTypography.bodyMedium(color: secondaryTextColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                context.read<TripBloc>().add(
                  RefreshTripsEvent(token: widget.driverToken),
                );
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Refresh'),
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

class _TripCardWidget extends StatefulWidget {
  final TripEntity trip;
  final TripState state;
  final String? driverToken;

  const _TripCardWidget({
    super.key,
    required this.trip,
    required this.state,
    this.driverToken,
  });

  @override
  State<_TripCardWidget> createState() => _TripCardWidgetState();
}

class _TripCardWidgetState extends State<_TripCardWidget> {
  late final List<TextEditingController> _otpControllers;
  late final List<FocusNode> _otpFocusNodes;
  String? _otpError;

  @override
  void initState() {
    super.initState();
    _otpControllers = List.generate(4, (_) => TextEditingController());
    _otpFocusNodes = List.generate(4, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onOtpDigitChanged(int index, String value) {
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < 4 && i < digits.length; i++) {
        _otpControllers[i].text = digits[i];
      }
      final nextIndex = digits.length < 4 ? digits.length : 3;
      _otpFocusNodes[nextIndex].requestFocus();
      setState(() {
        _otpError = null;
      });
      return;
    }

    if (value.isNotEmpty) {
      setState(() {
        _otpError = null;
      });
      if (index < 3) {
        _otpFocusNodes[index + 1].requestFocus();
      } else {
        _otpFocusNodes[index].unfocus();
      }
    }
  }

  void _onStartTripPressed() {
    final otp = _otpControllers.map((c) => c.text.trim()).join();
    if (otp.length < 4) {
      setState(() {
        _otpError = 'Please enter all 4 digits of the start OTP';
      });
      for (int i = 0; i < 4; i++) {
        if (_otpControllers[i].text.isEmpty) {
          _otpFocusNodes[i].requestFocus();
          break;
        }
      }
      return;
    }

    setState(() {
      _otpError = null;
    });

    final bookingId = widget.trip.bookingId.isNotEmpty
        ? widget.trip.bookingId
        : widget.trip.id;

    context.read<TripBloc>().add(
          UpdateTripStatusEvent(
            bookingId: bookingId,
            action: 'start',
            otp: otp,
            token: widget.driverToken,
          ),
        );
  }

  void _onEndTripPressed() {
    final bookingId = widget.trip.bookingId.isNotEmpty
        ? widget.trip.bookingId
        : widget.trip.id;

    final distance = widget.trip.actualDistance > 0
        ? widget.trip.actualDistance
        : (widget.trip.distanceKm > 0 ? widget.trip.distanceKm : 25.5);

    context.read<TripBloc>().add(
          UpdateTripStatusEvent(
            bookingId: bookingId,
            action: 'end',
            actualDistance: distance,
            token: widget.driverToken,
          ),
        );
  }

  Widget _buildTagChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    final state = widget.state;
    final bookingId = trip.bookingId.isNotEmpty ? trip.bookingId : trip.id;
    final isUpdatingThisTrip = state.updatingBookingId == bookingId;
    final isArrived = trip.isDriverArrived;
    final isTripStarted = trip.isTripStarted;
    final isUpcoming = trip.status == 'Upcoming';
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
    } else if (isTripStarted) {
      statusColor = const Color(0xFF8B5CF6);
      statusBgColor = const Color(0xFFF5F3FF);
      statusIcon = Icons.local_taxi_rounded;
    } else {
      statusColor = const Color(0xFF2563EB);
      statusBgColor = const Color(0xFFEFF6FF);
      statusIcon = Icons.access_time_filled_rounded;
    }

    return BlocListener<TripBloc, TripState>(
      listener: (context, latestState) {
        if (latestState.statusErrorMessage != null &&
            latestState.statusErrorMessage!.isNotEmpty) {
          setState(() {
            _otpError = latestState.statusErrorMessage;
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header: Booking ID, Badge & Fare
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (trip.bookingId.isNotEmpty) {
                                  Clipboard.setData(
                                    ClipboardData(text: trip.bookingId),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Copied ${trip.bookingId} to clipboard',
                                      ),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      trip.bookingId.isNotEmpty
                                          ? '#${trip.bookingId}'
                                          : '#TRIP',
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimaryLight,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.copy_rounded,
                                      size: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: statusBgColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    statusIcon,
                                    size: 12,
                                    color: statusColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    trip.statusBadgeLabel,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: statusColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${trip.serviceType.toUpperCase()} • ${trip.tripType.replaceAll('_', ' ').toUpperCase()}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Fare Column
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        trip.formattedTotalFare,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      if (trip.driverFee > 0)
                        Text(
                          'Driver: ${trip.formattedDriverFee}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

            // 2. Customer & Start OTP info strip
            Container(
              color: const Color(0xFFFAFAFA),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.1,
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trip.customerName,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimaryLight,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (trip.customerPhone.isNotEmpty)
                                Text(
                                  trip.customerPhone,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

            // 3. Route Timeline (Pickup -> Drop)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Pickup row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.circle,
                          size: 14,
                          color: Color(0xFF10B981),
                        ),
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
                                  'Pickup Location',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                Text(
                                  trip.date,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              trip.pickupAddress,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimaryLight,
                              ),
                            ),
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
                        Container(
                          width: 2,
                          height: 22,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(width: 20),
                        if (trip.actualDistance > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: const Color(0xFF2563EB)
                                    .withValues(alpha: 0.2),
                              ),
                            ),
                            child: Text(
                              'Actual: ${trip.formattedActualDistance}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          )
                        else if (trip.durationHours > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Duration: ${trip.durationHours} hrs',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Drop row
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
                              'Drop Location',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              trip.dropAddress,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimaryLight,
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

            // 4. Vehicle & Trip Details Chips
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _buildTagChip(
                    Icons.directions_car,
                    trip.vehicleType.toUpperCase(),
                  ),
                  _buildTagChip(Icons.tune, trip.transmission.toUpperCase()),
                  _buildTagChip(
                    Icons.person_pin,
                    '${trip.numberOfPassengers} Passenger(s)',
                  ),
                  _buildTagChip(
                    Icons.payment,
                    '${trip.paymentMethod.toUpperCase()} (${trip.paymentStatus.toUpperCase()})',
                  ),
                  if (trip.actualDistance > 0)
                    _buildTagChip(
                      Icons.straighten_rounded,
                      '${trip.actualDistance.toStringAsFixed(1)} KM ACTUAL',
                    ),
                  if (trip.formattedCompletedDuration.isNotEmpty &&
                      trip.isTripCompleted)
                    _buildTagChip(
                      Icons.timer_outlined,
                      trip.formattedCompletedDuration.toUpperCase(),
                    ),
                ],
              ),
            ),

            // 4.5. 4-Digit Start OTP Entry Box (Shown directly in this card once driver arrived and before trip started)
            if (isUpcoming && isArrived && !isTripStarted) ...[
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _otpError != null
                        ? AppColors.error.withValues(alpha: 0.5)
                        : const Color(0xFFE2E8F0),
                    width: _otpError != null ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.lock_outline_rounded,
                            size: 14,
                            color: Color(0xFFD97706),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Customer Start OTP',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Enter 4 digits',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // 4 Single-Digit Boxes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(4, (index) {
                        return SizedBox(
                          width: 52,
                          height: 52,
                          child: KeyboardListener(
                            focusNode: FocusNode(),
                            onKeyEvent: (event) {
                              if (event is KeyDownEvent &&
                                  event.logicalKey ==
                                      LogicalKeyboardKey.backspace &&
                                  _otpControllers[index].text.isEmpty &&
                                  index > 0) {
                                _otpFocusNodes[index - 1].requestFocus();
                              }
                            },
                            child: TextField(
                              controller: _otpControllers[index],
                              focusNode: _otpFocusNodes[index],
                              enabled: !isUpdatingThisTrip,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimaryLight,
                              ),
                              maxLength: 1,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                counterText: '',
                                filled: true,
                                fillColor: _otpFocusNodes[index].hasFocus
                                    ? AppColors.primary.withValues(alpha: 0.06)
                                    : Colors.white,
                                contentPadding: EdgeInsets.zero,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                              onChanged: (val) => _onOtpDigitChanged(index, val),
                            ),
                          ),
                        );
                      }),
                    ),

                    // Error text if invalid
                    if (_otpError != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 13,
                            color: AppColors.error,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _otpError!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],

            // 5. Actions Footer
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  // If upcoming, show Reached / Start / End Trip button
                  if (isUpcoming) ...[
                    Expanded(
                      flex: 3,
                      child: ElevatedButton.icon(
                        onPressed: isUpdatingThisTrip
                            ? null
                            : () {
                                if (isTripStarted) {
                                  _onEndTripPressed();
                                } else if (isArrived) {
                                  _onStartTripPressed();
                                } else {
                                  // Call API to mark status as reached via BLoC
                                  context.read<TripBloc>().add(
                                        UpdateTripStatusEvent(
                                          bookingId: bookingId,
                                          action: 'reached',
                                          token: widget.driverToken,
                                        ),
                                      );
                                }
                              },
                        icon: isUpdatingThisTrip
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Icon(
                                isTripStarted
                                    ? Icons.stop_circle_rounded
                                    : (isArrived
                                        ? Icons.play_arrow_rounded
                                        : Icons.navigation_rounded),
                                size: 18,
                              ),
                        label: Text(
                          isTripStarted
                              ? 'End'
                              : (isArrived ? 'Start' : 'Reached'),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isTripStarted
                              ? const Color(0xFFEF4444)
                              : (isArrived
                                  ? const Color(0xFF10B981)
                                  : AppColors.primary),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],

                  // If completed, show Completed badge
                  if (isCompleted) ...[
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color:
                                const Color(0xFF10B981).withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 16,
                              color: Color(0xFF10B981),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Trip Completed',
                              style: TextStyle(
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],

                  // Details Button
                  Expanded(
                    flex: 2,
                    child: OutlinedButton(
                      onPressed: () {
                        context.push(
                          AppRoutes.tripDetails,
                          extra: {
                            'trip': trip,
                            'driverToken': widget.driverToken,
                          },
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimaryLight,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Details',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
