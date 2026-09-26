import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/style/app_colors.dart';
import '../../../../core/style/app_spacing.dart';
import '../../../../core/style/app_typography.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/widgets/custom_elevated_button.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/driver_entity.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'login_page.dart';

enum TripState { idle, requestReceived, headingToPickup, onTrip, completed }

class DriverDashboardPage extends StatefulWidget {
  final DriverEntity driver;

  const DriverDashboardPage({
    super.key,
    required this.driver,
  });

  @override
  State<DriverDashboardPage> createState() => _DriverDashboardPageState();
}

class _DriverDashboardPageState extends State<DriverDashboardPage> {
  late bool _isOnline;
  late double _todayEarnings;
  late int _totalTrips;

  TripState _tripState = TripState.idle;
  final double _mockFare = 24.50;

  @override
  void initState() {
    super.initState();
    _isOnline = widget.driver.isOnline;
    _todayEarnings = widget.driver.todayEarnings;
    _totalTrips = widget.driver.totalTrips;
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedLg),
        title: Text(
          'Sign Out',
          style: AppTypography.headingMedium(),
        ),
        content: Text(
          'Are you sure you want to go offline and sign out of your driver account?',
          style: AppTypography.bodyMedium(color: AppColors.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            style: TextButton.styleFrom(
              textStyle: AppTypography.bodyMedium().copyWith(inherit: true),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondaryDark),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AuthBloc>().add(const LogoutEvent());
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _triggerSimulatedRequest() {
    setState(() {
      _tripState = TripState.requestReceived;
    });
    AppSnackBar.showInfo(context, 'New Ride Request nearby (Downtown to Airport)!');
  }

  void _acceptTrip() {
    setState(() {
      _tripState = TripState.headingToPickup;
    });
    AppSnackBar.showSuccess(context, 'Ride Accepted! Navigating to Pickup Point.');
  }

  void _arriveAtPickup() {
    setState(() {
      _tripState = TripState.onTrip;
    });
    AppSnackBar.showInfo(context, 'Passenger boarded. Trip in progress to Airport Terminal 2.');
  }

  void _completeTrip() {
    setState(() {
      _todayEarnings += _mockFare;
      _totalTrips += 1;
      _tripState = TripState.idle;
    });
    AppSnackBar.showSuccess(context, 'Trip completed! +\$$_mockFare added to today\'s balance.');
  }

  void _declineTrip() {
    setState(() {
      _tripState = TripState.idle;
    });
    AppSnackBar.showInfo(context, 'Ride declined. Searching for next request.');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          AppSnackBar.showInfo(context, 'You have signed out successfully.');
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        appBar: AppBar(
          backgroundColor: AppColors.darkSurface,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.local_taxi_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'Driver Console',
                style: AppTypography.headingSmall(),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded, color: AppColors.error),
              tooltip: 'Sign Out',
              onPressed: _handleLogout,
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Driver Profile Header Card
                GlassContainer(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: AppColors.primary,
                        backgroundImage: NetworkImage(widget.driver.avatarUrl),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.driver.name,
                                    style: AppTypography.headingMedium(),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star_rounded, color: AppColors.primary, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.driver.rating.toStringAsFixed(2),
                                        style: AppTypography.bodySmall(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.driver.vehicleModel,
                              style: AppTypography.bodySmall(
                                color: AppColors.textSecondaryDark,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.darkBackground,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: AppColors.darkCardBorder),
                                  ),
                                  child: Text(
                                    widget.driver.vehiclePlate,
                                    style: AppTypography.bodySmall(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    widget.driver.serviceType.name.toUpperCase(),
                                    style: AppTypography.bodySmall(
                                      color: AppColors.secondary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Duty Status Toggle Card
                GlassContainer(
                  gradient: _isOnline
                      ? LinearGradient(
                          colors: [
                            AppColors.driverOnline.withValues(alpha: 0.15),
                            AppColors.darkCard,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  borderColor: _isOnline ? AppColors.driverOnline.withValues(alpha: 0.5) : null,
                  child: Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isOnline ? AppColors.driverOnline : AppColors.driverOffline,
                          boxShadow: _isOnline
                              ? [
                                  BoxShadow(
                                    color: AppColors.driverOnline.withValues(alpha: 0.6),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isOnline ? 'ONLINE & READY FOR DISPATCH' : 'OFFLINE',
                              style: AppTypography.bodyMedium(
                                color: _isOnline ? AppColors.driverOnline : AppColors.textSecondaryDark,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              _isOnline
                                  ? 'Receiving ride & passenger requests nearby'
                                  : 'Switch online to accept new ride requests',
                              style: AppTypography.bodySmall(color: AppColors.textMutedDark),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isOnline,
                        activeThumbColor: AppColors.driverOnline,
                        activeTrackColor: AppColors.driverOnline.withValues(alpha: 0.3),
                        onChanged: (val) {
                          setState(() {
                            _isOnline = val;
                            if (!_isOnline) {
                              _tripState = TripState.idle;
                            }
                          });
                          if (_isOnline) {
                            AppSnackBar.showSuccess(context, 'You are now Online and accepting rides!');
                          } else {
                            AppSnackBar.showInfo(context, 'You are now Offline.');
                          }
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                Text('Today\'s Performance', style: AppTypography.headingMedium()),
                const SizedBox(height: 14),

                // Stats Cards
                Row(
                  children: [
                    Expanded(
                      child: GlassContainer(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary, size: 24),
                            const SizedBox(height: 12),
                            Text('\$${_todayEarnings.toStringAsFixed(2)}', style: AppTypography.statValue()),
                            const SizedBox(height: 4),
                            Text('Today\'s Earnings', style: AppTypography.statLabel()),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlassContainer(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.navigation_rounded, color: AppColors.secondary, size: 24),
                            const SizedBox(height: 12),
                            Text('$_totalTrips', style: AppTypography.statValue()),
                            const SizedBox(height: 4),
                            Text('Total Trips Completed', style: AppTypography.statLabel()),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                Text('Live Dispatch Stream', style: AppTypography.headingMedium()),
                const SizedBox(height: 14),

                // Dynamic Interactive Trip Dispatch Console
                if (!_isOnline)
                  GlassContainer(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(Icons.location_off_rounded, size: 44, color: AppColors.textMutedDark),
                        const SizedBox(height: 10),
                        Text('You are currently offline', style: AppTypography.headingSmall()),
                        const SizedBox(height: 6),
                        Text(
                          'Switch on duty above to receive incoming passenger ride requests.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySmall(color: AppColors.textSecondaryDark),
                        ),
                      ],
                    ),
                  )
                else if (_tripState == TripState.idle)
                  GlassContainer(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(Icons.radar_rounded, size: 44, color: AppColors.primary),
                        const SizedBox(height: 10),
                        Text('Searching for passenger pickups...', style: AppTypography.headingSmall()),
                        const SizedBox(height: 6),
                        Text(
                          'High demand area: 1.4x surge active in Downtown.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySmall(color: AppColors.textSecondaryDark),
                        ),
                        const SizedBox(height: 16),
                        CustomElevatedButton(
                          text: 'Simulate Incoming Passenger Request',
                          icon: Icons.electric_bolt_rounded,
                          height: 46,
                          onPressed: _triggerSimulatedRequest,
                        ),
                      ],
                    ),
                  )
                else if (_tripState == TripState.requestReceived)
                  GlassContainer(
                    borderColor: AppColors.primary,
                    borderWidth: 1.5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'NEW DISPATCH REQUEST',
                                style: AppTypography.badgeText(color: AppColors.primary),
                              ),
                            ),
                            Text(
                              '\$$_mockFare',
                              style: AppTypography.statValue(color: AppColors.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.darkInputFill,
                              child: Icon(Icons.person_rounded, color: AppColors.white),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Sarah Jenkins', style: AppTypography.inputText()),
                                Text('⭐ 4.95 (52 rides)', style: AppTypography.bodySmall()),
                              ],
                            ),
                          ],
                        ),
                        const Divider(height: 24, color: AppColors.darkCardBorder),
                        Row(
                          children: [
                            const Icon(Icons.my_location_rounded, color: AppColors.driverOnline, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text('Pick up: 742 Evergreen Terrace, Downtown (1.2 km away)', style: AppTypography.bodyMedium()),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, color: AppColors.error, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text('Drop off: International Airport Terminal 2', style: AppTypography.bodyMedium()),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                  side: const BorderSide(color: AppColors.error),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                ),
                                onPressed: _declineTrip,
                                child: const Text('Decline'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: CustomElevatedButton(
                                text: 'Accept Ride',
                                icon: Icons.check_circle_outline_rounded,
                                height: 48,
                                onPressed: _acceptTrip,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                else if (_tripState == TripState.headingToPickup)
                  GlassContainer(
                    borderColor: AppColors.secondary,
                    borderWidth: 1.5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.navigation_rounded, color: AppColors.secondary, size: 20),
                            const SizedBox(width: 8),
                            Text('Navigating to Passenger Pickup', style: AppTypography.headingSmall()),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('742 Evergreen Terrace, Downtown • ETA 4 mins', style: AppTypography.bodyMedium(color: AppColors.textSecondaryDark)),
                        const SizedBox(height: 18),
                        CustomElevatedButton(
                          text: 'Arrived at Pickup & Board Passenger',
                          icon: Icons.person_add_alt_1_rounded,
                          height: 48,
                          onPressed: _arriveAtPickup,
                        ),
                      ],
                    ),
                  )
                else if (_tripState == TripState.onTrip)
                  GlassContainer(
                    borderColor: AppColors.driverOnline,
                    borderWidth: 1.5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.route_rounded, color: AppColors.driverOnline, size: 20),
                            const SizedBox(width: 8),
                            Text('Trip in Progress • Heading to Airport', style: AppTypography.headingSmall()),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Est. Distance: 14 km • Est. Fare: \$$_mockFare', style: AppTypography.bodyMedium(color: AppColors.textSecondaryDark)),
                        const SizedBox(height: 18),
                        CustomElevatedButton(
                          text: 'Complete Trip & Collect \$$_mockFare',
                          icon: Icons.task_alt_rounded,
                          height: 48,
                          onPressed: _completeTrip,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
