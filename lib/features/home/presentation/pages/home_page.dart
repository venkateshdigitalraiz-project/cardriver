import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/router/app_router.dart';

import '../../../../core/style/app_colors.dart';
import '../../../../core/style/app_spacing.dart';
import '../../../../core/style/app_typography.dart';
import '../../../../core/utils/map_launcher_utils.dart';
import '../../../../injection_container.dart';
import '../../../auth/domain/entities/customer_entity.dart';
import '../../../navigation/presentation/bloc/navigation_bloc.dart';
import '../../../navigation/presentation/bloc/navigation_event.dart';
import '../../domain/entities/available_ride_entity.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/booking_driver_card.dart';

export '../widgets/booking_driver_card.dart';
export '../widgets/create_ride_widget.dart';

class HomePage extends StatelessWidget {
  final CustomerEntity customer;

  const HomePage({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          InjectionContainer.createHomeBloc(driverToken: customer.token)
            ..add(const ToggleOnlineStatusEvent(forceStatus: true))
            ..add(LoadCommonChargesEvent(token: customer.token, silent: true)),
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

    return BlocListener<HomeBloc, HomeState>(
      listenWhen: (previous, current) =>
          (current.errorMessage != null &&
              previous.errorMessage != current.errorMessage) ||
          previous.acceptedRide != current.acceptedRide ||
          previous.rejectedRide != current.rejectedRide,
      listener: (context, state) {
        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.read<HomeBloc>().add(ClearHomeErrorEvent());
        }

        if (state.rejectedRide != null) {
          final rejected = state.rejectedRide!;
          context.read<HomeBloc>().add(ClearRejectedRideEvent());

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              elevation: 4,
              backgroundColor: const Color(0xFF1E293B),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Colors.red.shade400.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              duration: const Duration(seconds: 4),
              content: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cancel_rounded,
                      color: Color(0xFFEF4444),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ride Declined • ${rejected.bookingId}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          rejected.reason.isNotEmpty
                              ? rejected.reason
                              : rejected.message,
                          style: TextStyle(
                            color: Colors.grey.shade300,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state.acceptedRide != null) {
          final accepted = state.acceptedRide!;
          context.read<HomeBloc>().add(ClearAcceptedRideEvent());

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${accepted.message}! Opening active trip...',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
            ),
          );

          try {
            context.read<NavigationBloc>().add(const NavigationTabChanged(1));
          } catch (_) {}
        }
      },
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.lightBackground,
            appBar: AppBar(
              backgroundColor: AppColors.lightSurface,
              elevation: 1,
              title: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: customer.avatarUrl.isNotEmpty
                        ? NetworkImage(customer.avatarUrl)
                        : null,
                    child: customer.avatarUrl.isEmpty
                        ? Text(
                            customer.name.isNotEmpty
                                ? customer.name[0].toUpperCase()
                                : 'D',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.name,
                          style: AppTypography.headingSmall(
                            color: primaryTextColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: state.isOnline
                                    ? const Color(0xFF10B981)
                                    : AppColors.textMutedLight,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              state.isOnline
                                  ? 'Online' // • Live Radar'
                                  : 'Offline',
                              style: AppTypography.bodySmall(
                                color: state.isOnline
                                    ? const Color(0xFF10B981)
                                    : AppColors.textMutedLight,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.isOnline ? 'OFFLINE' : 'ONLINE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: state.isOnline
                            ? const Color(0xFF10B981)
                            : secondaryTextColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Switch(
                      value: state.isOnline,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      activeThumbColor: const Color(0xFF10B981),
                      activeTrackColor: const Color(
                        0xFF10B981,
                      ).withValues(alpha: 0.3),
                      onChanged: (value) {
                        context.read<HomeBloc>().add(
                          ToggleOnlineStatusEvent(forceStatus: value),
                        );
                      },
                    ),
                    const SizedBox(width: 4),
                    // Circle Driver Jobs Icon Button
                    IconButton(
                      tooltip: 'Driver Jobs',
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2563EB),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.directions_car_outlined,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                      onPressed: () {
                        context.push(
                          AppRoutes.driverJobs,
                          extra: customer.token,
                        );
                      },
                    ),
                    const SizedBox(width: 4),
                    // WhatsApp Helpline Icon Button in AppBar right corner
                    IconButton(
                      tooltip: 'WhatsApp Helpline',
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF25D366),
                          shape: BoxShape.circle,
                        ),
                        child: const FaIcon(
                          FontAwesomeIcons.whatsapp,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      onPressed: () {
                        context.read<HomeBloc>().add(
                          const OpenWhatsAppSupportEvent(),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                context.read<HomeBloc>().add(
                  const LoadAvailableRidesEvent(silent: false),
                );
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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

                    const SizedBox(height: 20),

                    // Feature Card for Booking Driver
                    BookingDriverCard(
                      customer: customer,
                      onBookTap: () => _openCreateRide(context),
                    ),

                    const SizedBox(height: 24),

                    // Live Available Ride Requests Section
                    if (state.isOnline) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Available Rides',
                                style: AppTypography.headingMedium(
                                  color: primaryTextColor,
                                ),
                              ),
                              if (state.availableRides.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${state.availableRides.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF10B981,
                              ).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.radar_rounded,
                                  size: 14,
                                  color: Color(0xFF10B981),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'RAPID LIVE SYNC',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      if (state.availableRides.isNotEmpty) ...[
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.availableRides.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final ride = state.availableRides[index];
                            return _buildAvailableRideCard(
                              ride: ride,
                              context: context,
                              state: state,
                              primaryTextColor: primaryTextColor,
                              secondaryTextColor: secondaryTextColor,
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                      ] else if (state.isLoadingRides) ...[
                        Container(
                          padding: const EdgeInsets.all(24),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: const Column(
                            children: [
                              CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Color(0xFF10B981),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Connecting live radar to fetch available rides...',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ] else ...[
                        // Empty state while Online
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF10B981,
                                  ).withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.radar_rounded,
                                  color: Color(0xFF10B981),
                                  size: 36,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Searching for Nearby Rides...',
                                style: AppTypography.headingSmall(
                                  color: primaryTextColor,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'You are Online! Rapid sync is actively monitoring customer bookings every few seconds. New ride requests will show up here automatically.',
                                textAlign: TextAlign.center,
                                style: AppTypography.bodySmall(
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ] else ...[
                      // Offline Status Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.power_settings_new_rounded,
                                color: Colors.grey.shade600,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'You are Offline',
                                    style: AppTypography.headingSmall(
                                      color: primaryTextColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Toggle "GO ONLINE" in the top bar to start live monitoring and receive incoming rides.',
                                    style: AppTypography.bodySmall(
                                      color: secondaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Weekly Goal Progress
                    Text(
                      'Weekly Goal',
                      style: AppTypography.headingMedium(
                        color: primaryTextColor,
                      ),
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
                                style: AppTypography.bodyMedium(
                                  color: primaryTextColor,
                                ).copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '₹9,640 / ₹40,000',
                                style: AppTypography.bodySmall(
                                  color: AppColors.primary,
                                ).copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: 9640.0 / 40000.0,
                              backgroundColor: AppColors.primary.withValues(
                                alpha: 0.1,
                              ),
                              color: AppColors.primary,
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'You are on track to reach your goal!',
                            style: AppTypography.bodySmall(
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Recent Trips Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Trips',
                          style: AppTypography.headingMedium(
                            color: primaryTextColor,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.read<NavigationBloc>().add(
                              const NavigationTabChanged(1),
                            );
                          },
                          child: Text(
                            'See All',
                            style: AppTypography.bodyMedium(
                              color: AppColors.primary,
                            ).copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildRecentTripItem(
                      'Koramangala, BLR',
                      '₹1960',
                      '2:30 PM',
                      primaryTextColor,
                      secondaryTextColor,
                    ),
                    const SizedBox(height: 12),
                    _buildRecentTripItem(
                      'Kempegowda Airport',
                      '₹3600',
                      '10:15 AM',
                      primaryTextColor,
                      secondaryTextColor,
                    ),
                    const SizedBox(height: 12),
                    _buildRecentTripItem(
                      'MG Road, BLR',
                      '₹1450',
                      'Yesterday',
                      primaryTextColor,
                      secondaryTextColor,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _openCreateRide(context),
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.black87,
              elevation: 4,
              shape: const CircleBorder(),
              tooltip: 'Add',
              child: const Icon(Icons.add, size: 28),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          );
        },
      ),
    );
  }

  void _openCreateRide(BuildContext context) {
    context.push(
      AppRoutes.createRide,
      extra: {'homeBloc': context.read<HomeBloc>(), 'customer': customer},
    );
  }

  Widget _buildRecentTripItem(
    String destination,
    String earnings,
    String time,
    Color primaryText,
    Color secondaryText,
  ) {
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
                  style: AppTypography.bodyMedium(
                    color: primaryText,
                  ).copyWith(fontWeight: FontWeight.bold),
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
            style: AppTypography.bodyMedium(
              color: const Color(0xFF10B981),
            ).copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableRideCard({
    required AvailableRideEntity ride,
    required BuildContext context,
    required HomeState state,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    if (ride.isDriverToDriver) {
      return _buildDriverToDriverBookingCard(
        ride: ride,
        context: context,
        state: state,
        primaryTextColor: primaryTextColor,
        secondaryTextColor: secondaryTextColor,
      );
    } else {
      return _buildUserToDriverBookingCard(
        ride: ride,
        context: context,
        state: state,
        primaryTextColor: primaryTextColor,
        secondaryTextColor: secondaryTextColor,
      );
    }
  }

  /// Professional, dedicated card design for Driver-to-Driver (D-to-D) bookings
  Widget _buildDriverToDriverBookingCard({
    required AvailableRideEntity ride,
    required BuildContext context,
    required HomeState state,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    final isThisRideAccepting = state.acceptingRideId == ride.id;
    final isThisRideDeclining = state.decliningRideId == ride.id;
    final driverName = ride.sourceDriverName;
    final driverId = ride.sourceDriverId;
    final driverPhone = ride.sourceDriverPhone;
    final returnOptions = ride.formattedReturnOptions;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: const Color(0xFF2563EB), width: 1.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header: D-to-D Distinct Badge & Booking ID
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.swap_horizontal_circle_rounded,
                      size: 13,
                      color: Colors.white,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'DRIVER-TO-DRIVER BOOKING',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
              if (ride.bookingId.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Text(
                    ride.bookingId,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E40AF),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Source Driver Profile Info Row
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFEFF6FF),
                child: const Icon(
                  Icons.airline_seat_recline_normal_rounded,
                  color: Color(0xFF2563EB),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driverName,
                      style: AppTypography.headingSmall(
                        color: primaryTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        if (driverId.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: const Color(0xFFBFDBFE),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.badge_rounded,
                                  size: 11,
                                  color: Color(0xFF2563EB),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  'ID: $driverId',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1D4ED8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ],
                    ),
                    if (driverPhone.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone_rounded,
                            size: 12,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            driverPhone,
                            style: TextStyle(
                              fontSize: 11,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Map navigation icon button
              _buildMapButton(ride, context),
            ],
          ),

          // Scheduled Start Time Display
          if (ride.scheduledStartTime.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildScheduleBox(ride),
          ],

          const SizedBox(height: 12),

          // Trip Badges Row
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildBadge(
                ride.vehicleType.toUpperCase(),
                const Color(0xFF2563EB),
                const Color(0xFFEFF6FF),
              ),
              _buildBadge(
                ride.serviceType.toUpperCase(),
                const Color(0xFF7C3AED),
                const Color(0xFFF5F3FF),
              ),
              _buildBadge(
                ride.tripType.replaceAll('_', ' ').toUpperCase(),
                const Color(0xFF059669),
                const Color(0xFFECFDF5),
              ),
              _buildBadge(
                ride.durationDisplay,
                const Color(0xFFD97706),
                const Color(0xFFFFFBEB),
              ),
            ],
          ),

          // Return Options Display (if available)
          // if (returnOptions.isNotEmpty) ...[
          //   const SizedBox(height: 10),
          //   Container(
          //     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          //     decoration: BoxDecoration(
          //       color: const Color(0xFFF0FDF4),
          //       borderRadius: BorderRadius.circular(8),
          //       border: Border.all(color: const Color(0xFFBBF7D0)),
          //     ),
          //     child: Row(
          //       children: [
          //         const Icon(
          //           Icons.commute_rounded,
          //           size: 15,
          //           color: Color(0xFF16A34A),
          //         ),
          //         const SizedBox(width: 6),
          //         const Text(
          //           'Return Options: ',
          //           style: TextStyle(
          //             fontSize: 11,
          //             fontWeight: FontWeight.w600,
          //             color: Color(0xFF166534),
          //           ),
          //         ),
          //         Expanded(
          //           child: Text(
          //             returnOptions,
          //             style: const TextStyle(
          //               fontSize: 11,
          //               fontWeight: FontWeight.bold,
          //               color: Color(0xFF15803D),
          //             ),
          //             overflow: TextOverflow.ellipsis,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ],
          const SizedBox(height: 14),

          // Fare & Financial Container
          _buildFareContainer(
            ride: ride,
            primaryTextColor: primaryTextColor,
            secondaryTextColor: secondaryTextColor,
          ),

          const SizedBox(height: 16),

          // Locations
          _buildRouteSection(ride: ride, primaryTextColor: primaryTextColor),

          const SizedBox(height: 16),

          // Buttons: Decline & Accept
          _buildActionButtons(
            ride: ride,
            context: context,
            isThisRideAccepting: isThisRideAccepting,
            isThisRideDeclining: isThisRideDeclining,
            acceptColor: const Color(0xFF2563EB),
          ),
        ],
      ),
    );
  }

  /// Professional, dedicated card design for User-to-Driver bookings
  Widget _buildUserToDriverBookingCard({
    required AvailableRideEntity ride,
    required BuildContext context,
    required HomeState state,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    final isThisRideAccepting = state.acceptingRideId == ride.id;
    final isThisRideDeclining = state.decliningRideId == ride.id;
    final customerName = ride.customerName;
    final customerPhone = ride.customerPhone;
    final transmission = ride.transmission.trim();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: const Color(0xFF10B981), width: 1.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header: User Booking Request Badge & Booking ID
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person_pin_rounded,
                      size: 13,
                      color: Color(0xFF059669),
                    ),
                    SizedBox(width: 5),
                    Text(
                      'USER BOOKING REQUEST',
                      style: TextStyle(
                        color: Color(0xFF065F46),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (ride.bookingId.isNotEmpty)
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
                    ride.bookingId,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Customer Profile Info Row
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: Text(
                  customerName.isNotEmpty ? customerName[0].toUpperCase() : 'C',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerName,
                      style: AppTypography.headingSmall(
                        color: primaryTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (customerPhone.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone_rounded,
                            size: 12,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            customerPhone,
                            style: TextStyle(
                              fontSize: 11,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Map navigation icon button
              _buildMapButton(ride, context),
            ],
          ),

          // Scheduled Start Time Display
          if (ride.scheduledStartTime.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildScheduleBox(ride),
          ],

          const SizedBox(height: 12),

          // Trip Badges Row
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildBadge(
                ride.vehicleType.toUpperCase(),
                const Color(0xFF2563EB),
                const Color(0xFFEFF6FF),
              ),
              if (transmission.isNotEmpty)
                _buildBadge(
                  transmission.toUpperCase(),
                  const Color(0xFF0284C7),
                  const Color(0xFFE0F2FE),
                ),
              _buildBadge(
                ride.serviceType.toUpperCase(),
                const Color(0xFF7C3AED),
                const Color(0xFFF5F3FF),
              ),
              _buildBadge(
                ride.tripType.replaceAll('_', ' ').toUpperCase(),
                const Color(0xFF059669),
                const Color(0xFFECFDF5),
              ),
              _buildBadge(
                ride.durationDisplay,
                const Color(0xFFD97706),
                const Color(0xFFFFFBEB),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Fare & Financial Container
          _buildFareContainer(
            ride: ride,
            primaryTextColor: primaryTextColor,
            secondaryTextColor: secondaryTextColor,
          ),

          const SizedBox(height: 16),

          // Locations
          _buildRouteSection(ride: ride, primaryTextColor: primaryTextColor),

          const SizedBox(height: 16),

          // Buttons: Decline & Accept
          _buildActionButtons(
            ride: ride,
            context: context,
            isThisRideAccepting: isThisRideAccepting,
            isThisRideDeclining: isThisRideDeclining,
            acceptColor: const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  Widget _buildMapButton(AvailableRideEntity ride, BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: 'Open in Google Maps',
        child: InkWell(
          onTap: () => MapLauncherUtils.openDirections(
            pickupLat: ride.pickupLat,
            pickupLng: ride.pickupLng,
            pickupAddress: ride.pickupAddress,
            dropLat: ride.dropLat,
            dropLng: ride.dropLng,
            dropAddress: ride.dropAddress,
            context: context,
          ),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.map_rounded, size: 16, color: Color(0xFF2563EB)),
                SizedBox(width: 4),
                Text(
                  'Map',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleBox(AvailableRideEntity ride) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.schedule_rounded,
                size: 15,
                color: Color(0xFF2563EB),
              ),
              const SizedBox(width: 6),
              Text(
                'Scheduled: ',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              Expanded(
                child: Text(
                  ride.formattedScheduledTime,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1D4ED8),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (ride.returnDate.isNotEmpty) ...[
            const SizedBox(height: 3),
            Row(
              children: [
                const Icon(
                  Icons.keyboard_return_rounded,
                  size: 14,
                  color: Color(0xFF3B82F6),
                ),
                const SizedBox(width: 6),
                Text(
                  'Return: ',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                Expanded(
                  child: Text(
                    ride.formattedReturnDate,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E40AF),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFareContainer({
    required AvailableRideEntity ride,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (ride.fare > 0)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Amount',
                  style: AppTypography.bodySmall(color: secondaryTextColor),
                ),
                const SizedBox(height: 4),
                Text(
                  ride.formattedFare,
                  style: AppTypography.headingSmall(color: primaryTextColor),
                ),
              ],
            ),
          if (ride.driverFee > 0)
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Trip Earning',
                  style: AppTypography.bodySmall(color: secondaryTextColor),
                ),
                const SizedBox(height: 4),
                Text(
                  ride.formattedDriverFee,
                  style: AppTypography.headingSmall(
                    color: const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Payment Method',
                style: AppTypography.bodySmall(color: secondaryTextColor),
              ),
              const SizedBox(height: 4),
              Text(
                ride.paymentMethod.toUpperCase(),
                style: AppTypography.bodyMedium(
                  color: primaryTextColor,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRouteSection({
    required AvailableRideEntity ride,
    required Color primaryTextColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(
                Icons.my_location_rounded,
                size: 18,
                color: Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                ride.pickupAddress,
                style: AppTypography.bodyMedium(color: primaryTextColor),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(left: 8),
          child: SizedBox(
            height: 14,
            child: VerticalDivider(color: Colors.grey, thickness: 1.5),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(
                Icons.location_on_rounded,
                size: 18,
                color: AppColors.error,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                ride.dropAddress,
                style: AppTypography.bodyMedium(color: primaryTextColor),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons({
    required AvailableRideEntity ride,
    required BuildContext context,
    required bool isThisRideAccepting,
    required bool isThisRideDeclining,
    required Color acceptColor,
  }) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: (isThisRideDeclining || isThisRideAccepting)
                ? null
                : () {
                    context.read<HomeBloc>().add(
                      DeclineRideRequestEvent(ride.id),
                    );
                  },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              disabledForegroundColor: AppColors.error.withValues(alpha: 0.5),
              side: BorderSide(
                color: (isThisRideDeclining || isThisRideAccepting)
                    ? AppColors.error.withValues(alpha: 0.4)
                    : AppColors.error,
                width: 1.5,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: isThisRideDeclining
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.error,
                    ),
                  )
                : Text(
                    'Decline',
                    style: TextStyle(
                      color: (isThisRideDeclining || isThisRideAccepting)
                          ? AppColors.error.withValues(alpha: 0.5)
                          : AppColors.error,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: (isThisRideAccepting || isThisRideDeclining)
                ? null
                : () {
                    context.read<HomeBloc>().add(AcceptRideEvent(ride.id));
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: acceptColor,
              foregroundColor: Colors.white,
              disabledBackgroundColor: acceptColor.withValues(alpha: 0.6),
              disabledForegroundColor: Colors.white.withValues(alpha: 0.8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: isThisRideAccepting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Accept',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _showShareDialog(BuildContext context) {
    const shareText =
        'Join me on the Car Driver app! Earn more with flexible bookings. Download now: https://play.google.com/store/apps/details?id=com.cardriver.app';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Share Car Driver App',
                      style: AppTypography.headingSmall(
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Share the app with fellow drivers and colleagues.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFF25D366),
                      shape: BoxShape.circle,
                    ),
                    child: const FaIcon(
                      FontAwesomeIcons.whatsapp,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  title: const Text(
                    'Share on WhatsApp',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    final waUri = Uri.parse(
                      'whatsapp://send?text=${Uri.encodeComponent(shareText)}',
                    );
                    final webWaUri = Uri.parse(
                      'https://wa.me/?text=${Uri.encodeComponent(shareText)}',
                    );
                    try {
                      if (await canLaunchUrl(waUri)) {
                        await launchUrl(
                          waUri,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        await launchUrl(
                          webWaUri,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    } catch (_) {}
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.copy_rounded,
                      color: Color(0xFF2563EB),
                      size: 18,
                    ),
                  ),
                  title: const Text(
                    'Copy Link',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    Clipboard.setData(const ClipboardData(text: shareText));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('App link copied to clipboard!'),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
