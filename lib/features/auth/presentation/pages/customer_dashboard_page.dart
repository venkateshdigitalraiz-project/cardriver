import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/style/app_colors.dart';
import '../../../../core/style/app_spacing.dart';
import '../../../../core/style/app_typography.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/widgets/custom_elevated_button.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/customer_entity.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'login_page.dart';

enum RideBookingState { idle, searchingDriver, driverMatched, rideInProgress }

class CustomerDashboardPage extends StatefulWidget {
  final CustomerEntity customer;

  const CustomerDashboardPage({
    super.key,
    required this.customer,
  });

  @override
  State<CustomerDashboardPage> createState() => _CustomerDashboardPageState();
}

class _CustomerDashboardPageState extends State<CustomerDashboardPage> {
  final _pickupController = TextEditingController(text: '742 Evergreen Terrace, Downtown');
  final _destinationController = TextEditingController(text: 'International Airport Terminal 2');

  int _selectedCabIndex = 0;
  RideBookingState _bookingState = RideBookingState.idle;

  final List<Map<String, dynamic>> _cabTypes = [
    {
      'title': 'Economy Sedan',
      'eta': '3 mins away',
      'price': 15.50,
      'icon': Icons.directions_car_rounded,
      'color': Color(0xFF10B981),
    },
    {
      'title': 'Green EV',
      'eta': '2 mins away',
      'price': 18.00,
      'icon': Icons.electric_car_rounded,
      'color': AppColors.secondary,
    },
    {
      'title': 'Comfort SUV',
      'eta': '4 mins away',
      'price': 22.50,
      'icon': Icons.airport_shuttle_rounded,
      'color': AppColors.primary,
    },
    {
      'title': 'Luxury Black',
      'eta': '5 mins away',
      'price': 35.00,
      'icon': Icons.star_rounded,
      'color': Color(0xFF64748B),
    },
  ];

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  void _handleLogout() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedLg),
        title: Text(
          'Sign Out',
          style: AppTypography.headingMedium(color: isDark ? AppColors.white : AppColors.textPrimaryLight),
        ),
        content: Text(
          'Are you sure you want to sign out of your passenger account?',
          style: AppTypography.bodyMedium(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            style: TextButton.styleFrom(
              textStyle: AppTypography.bodyMedium().copyWith(inherit: true),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
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

  void _requestRide() async {
    setState(() {
      _bookingState = RideBookingState.searchingDriver;
    });
    AppSnackBar.showInfo(context, 'Matching with nearby driver...');

    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      setState(() {
        _bookingState = RideBookingState.driverMatched;
      });
      AppSnackBar.showSuccess(context, 'Driver Alex Martinez accepted your ride! ETA 3 mins.');
    }
  }

  void _cancelRide() {
    setState(() {
      _bookingState = RideBookingState.idle;
    });
    AppSnackBar.showInfo(context, 'Ride request cancelled.');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? AppColors.white : AppColors.textPrimaryLight;
    final secondaryTextColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final mutedTextColor = isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final dividerColor = isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder;
    final selectedCab = _cabTypes[_selectedCabIndex];

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          AppSnackBar.showInfo(context, 'Signed out successfully.');
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.directions_car_filled_rounded, color: Color(0xFF10B981), size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'Passenger App',
                style: AppTypography.headingSmall(color: primaryTextColor),
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
                // Customer Profile Header Card
                GlassContainer(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: const Color(0xFF10B981),
                        backgroundImage: NetworkImage(widget.customer.avatarUrl),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, ${widget.customer.name} 👋',
                              style: AppTypography.headingMedium(color: primaryTextColor),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, color: AppColors.primary, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.customer.rating.toStringAsFixed(2)} Passenger Rating',
                                  style: AppTypography.bodySmall(
                                    color: secondaryTextColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '• ${widget.customer.totalRides} rides',
                                  style: AppTypography.bodySmall(
                                    color: mutedTextColor,
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

                const SizedBox(height: 20),

                // Pickup & Destination Location Card
                GlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.my_location_rounded, color: Color(0xFF10B981), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _pickupController,
                              style: AppTypography.inputText(color: primaryTextColor),
                              decoration: InputDecoration(
                                hintText: 'Current Location / Pickup',
                                hintStyle: AppTypography.inputHint(color: mutedTextColor),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 9),
                        child: SizedBox(
                          height: 16,
                          child: VerticalDivider(color: dividerColor, thickness: 1.5),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded, color: AppColors.error, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _destinationController,
                              style: AppTypography.inputText(color: primaryTextColor),
                              decoration: InputDecoration(
                                hintText: 'Where to? Enter Destination',
                                hintStyle: AppTypography.inputHint(color: mutedTextColor),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // Cab Category Selection Header
                Text('Available Cab Fleet Nearby', style: AppTypography.headingMedium(color: primaryTextColor)),
                const SizedBox(height: 12),

                // Cab List Selector
                Column(
                  children: List.generate(_cabTypes.length, (index) {
                    final cab = _cabTypes[index];
                    final isSelected = _selectedCabIndex == index;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedCabIndex = index;
                          });
                        },
                        borderRadius: AppSpacing.roundedMd,
                        child: GlassContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          borderColor: isSelected ? const Color(0xFF10B981) : null,
                          borderWidth: isSelected ? 1.8 : 1.0,
                          backgroundColor: isSelected
                              ? (isDark ? const Color(0x3310B981) : const Color(0x1F10B981))
                              : null,
                          child: Row(
                            children: [
                              Icon(cab['icon'] as IconData, size: 28, color: cab['color'] as Color),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cab['title'] as String,
                                      style: AppTypography.inputText(
                                        color: primaryTextColor,
                                      ).copyWith(fontWeight: FontWeight.w700),
                                    ),
                                    Text(
                                      cab['eta'] as String,
                                      style: AppTypography.bodySmall(
                                        color: secondaryTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '\$${(cab['price'] as double).toStringAsFixed(2)}',
                                style: AppTypography.statValue(
                                  color: isSelected ? const Color(0xFF10B981) : primaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 16),

                // Action Area Based on Booking State
                if (_bookingState == RideBookingState.idle)
                  CustomElevatedButton(
                    text: 'Confirm & Book ${selectedCab['title']}',
                    icon: Icons.local_taxi_rounded,
                    backgroundColor: const Color(0xFF10B981),
                    useGradient: false,
                    onPressed: _requestRide,
                  )
                else if (_bookingState == RideBookingState.searchingDriver)
                  GlassContainer(
                    child: Column(
                      children: [
                        const SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text('Contacting nearest driver...', style: AppTypography.headingSmall(color: primaryTextColor)),
                        const SizedBox(height: 4),
                        Text('Searching within 1.5 miles of pickup point', style: AppTypography.bodySmall(color: secondaryTextColor)),
                        const SizedBox(height: 14),
                        OutlinedButton(
                          onPressed: _cancelRide,
                          style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                          child: const Text('Cancel Request'),
                        ),
                      ],
                    ),
                  )
                else if (_bookingState == RideBookingState.driverMatched)
                  GlassContainer(
                    borderColor: const Color(0xFF10B981),
                    borderWidth: 1.5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 22,
                              backgroundImage: NetworkImage(
                                'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400&auto=format&fit=crop&q=80',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Alex Martinez (Driver)', style: AppTypography.headingSmall(color: primaryTextColor)),
                                  Text('Toyota Camry Hybrid • CAB-8924', style: AppTypography.bodySmall(color: const Color(0xFF10B981))),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text('ETA 3 min', style: AppTypography.badgeText(color: const Color(0xFF10B981))),
                            ),
                          ],
                        ),
                        Divider(height: 24, color: dividerColor),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Estimated Fare: \$${(selectedCab['price'] as double).toStringAsFixed(2)}', style: AppTypography.bodyMedium(color: primaryTextColor)),
                            Text('Payment: Card (•••• 4242)', style: AppTypography.bodySmall(color: secondaryTextColor)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.call_rounded, size: 18),
                                label: const Text('Call Driver'),
                                style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF10B981)),
                                onPressed: () {
                                  AppSnackBar.showInfo(context, 'Calling Alex Martinez (+1 555-019-2834)...');
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: CustomElevatedButton(
                                text: 'Cancel Ride',
                                height: 44,
                                backgroundColor: AppColors.error,
                                useGradient: false,
                                onPressed: _cancelRide,
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
        ),
      ),
    );
  }
}
