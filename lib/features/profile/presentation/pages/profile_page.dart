import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/router/app_router.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/driver_active_subscription_entity.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../legal/presentation/pages/legal_page.dart';

class ProfilePage extends StatelessWidget {
  final String userName;
  final String? driverToken;

  const ProfilePage({super.key, required this.userName, this.driverToken});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          InjectionContainer.createProfileBloc(driverToken: driverToken)
            ..add(LoadProfileEvent(token: driverToken)),
      child: _ProfileView(userName: userName, driverToken: driverToken),
    );
  }
}

class _ProfileView extends StatelessWidget {
  final String userName;
  final String? driverToken;

  const _ProfileView({required this.userName, this.driverToken});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      },
      builder: (context, state) {
        final profile = (state is ProfileLoaded) ? state.driverProfile : null;
        final displayName = profile?.fullName ?? userName;
        final driverId = profile?.displayDriverId ?? '';
        final isVerified = profile?.isVerified ?? true;
        final hasSubscription = (state is ProfileLoaded)
            ? state.hasSubscription
            : false;
        final activeSub = (state is ProfileLoaded)
            ? state.activeSubscription
            : null;

        return Container(
          color: const Color(0xFF0066FF), // Dark blue background for header
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<ProfileBloc>().add(
                RefreshProfileEvent(token: driverToken),
              );
            },
            color: const Color(0xFF0066FF),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Header App Bar
                  Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 16,
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        const Text(
                          'Driver Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          tooltip: 'Refresh Profile',
                          icon: const Icon(
                            Icons.refresh_rounded,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            context.read<ProfileBloc>().add(
                              RefreshProfileEvent(token: driverToken),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // Profile Details (Image, Name, Rating)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar with Camera icon
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const CircleAvatar(
                                radius: 40,
                                backgroundImage: NetworkImage(
                                  'https://randomuser.me/api/portraits/men/32.jpg',
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981), // Green
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ],
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
                                      displayName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (isVerified)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            color: Colors.white,
                                            size: 12,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Verified',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              if (driverId.isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Text(
                                  'ID: $driverId',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 6),

                              //   children: [
                              //     const Icon(Icons.star,
                              //         color: Colors.amber, size: 18),
                              //     const SizedBox(width: 4),
                              //     const Text(
                              //       '4.8',
                              //       style: TextStyle(
                              //         color: Colors.white,
                              //         fontWeight: FontWeight.bold,
                              //         fontSize: 16,
                              //       ),
                              //     ),
                              //     const SizedBox(width: 4),
                              //     Text(
                              //       '(124 rides)',
                              //       style: TextStyle(
                              //         color: Colors.white70,
                              //         fontSize: 12,
                              //       ),
                              //     ),
                              //   ],
                              // ),
                              // const SizedBox(height: 6),
                              // const Text(
                              //   'Safe Rides  •  Punctual  •  Professional',
                              //   style: TextStyle(
                              //     color: Colors.white70,
                              //     fontSize: 12,
                              //   ),
                              // ),
                            ],
                          ),
                        ), // Row(
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // White Content Area
                  // Expanded(
                  //   child:
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC), // light grey/white background
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // Menu List (BlocBuilder)
                        BlocBuilder<ProfileBloc, ProfileState>(
                          builder: (context, menuState) {
                            final items = (menuState is ProfileLoaded)
                                ? menuState.menuItems
                                : (state is ProfileLoaded)
                                ? state.menuItems
                                : const [];

                            if (items.isNotEmpty) {
                              return Column(
                                children: items.map((item) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Material(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      clipBehavior: Clip.antiAlias,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey.shade200,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: ListTile(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 4,
                                              ),
                                          leading: Icon(
                                            item.icon,
                                            color: const Color(0xFF0066FF),
                                          ),
                                          title: Text(
                                            item.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1E293B),
                                            ),
                                          ),
                                          subtitle: Text(
                                            item.subtitle,
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 12,
                                            ),
                                          ),
                                          trailing: const Icon(
                                            Icons.chevron_right,
                                            color: Colors.grey,
                                          ),
                                          onTap: () {
                                            if (item.title == 'Documents') {
                                              context.push(
                                                AppRoutes.documents,
                                                extra: {
                                                  'documents':
                                                      profile?.documents,
                                                  'profile': profile,
                                                },
                                              );
                                            } else if (item.title ==
                                                'Notifications') {
                                              context.push(
                                                AppRoutes.notifications,
                                              );
                                            } else if (item.title ==
                                                'Rewards') {
                                              context.push(AppRoutes.rewards);
                                            } else if (item.title ==
                                                'Subscription') {
                                              context
                                                  .push(
                                                    AppRoutes.subscription,
                                                    extra: {
                                                      'hasSubscription':
                                                          hasSubscription,
                                                      'driverToken':
                                                          driverToken,
                                                    },
                                                  )
                                                  .then((_) {
                                                    context
                                                        .read<ProfileBloc>()
                                                        .add(
                                                          RefreshProfileEvent(
                                                            token: driverToken,
                                                          ),
                                                        );
                                                  });
                                            } else if (item.title ==
                                                'Subscription History') {
                                              context
                                                  .push(
                                                    AppRoutes
                                                        .subscriptionHistory,
                                                    extra: driverToken,
                                                  )
                                                  .then((_) {
                                                    context
                                                        .read<ProfileBloc>()
                                                        .add(
                                                          RefreshProfileEvent(
                                                            token: driverToken,
                                                          ),
                                                        );
                                                  });
                                            } else if (item.title ==
                                                'My Tickets') {
                                              _showMyTicketsSheet(context);
                                            } else if (item.title ==
                                                'Terms & Conditions') {
                                              context.push(
                                                AppRoutes.legal,
                                                extra: LegalPageType.terms,
                                              );
                                            } else if (item.title ==
                                                'Privacy Policy') {
                                              context.push(
                                                AppRoutes.legal,
                                                extra: LegalPageType.privacy,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            }
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 12),

                        // Account Status
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4), // Light green bg
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFF10B981),
                                size: 32,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Account Status',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF064E3B),
                                      ),
                                    ),
                                    Text(
                                      'Your profile is verified and active',
                                      style: TextStyle(
                                        color: Colors.green.shade700,
                                        fontSize: 12,
                                      ),
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
                                  color: const Color(0xFFD1FAE5),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Active',
                                  style: TextStyle(
                                    color: Color(0xFF059669),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Quick Actions
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Quick Actions',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildActionCard(
                              Icons.account_balance_wallet,
                              'View\nEarnings',
                              Colors.blue,
                              onTap: () {
                                context.push(AppRoutes.earnings);
                              },
                            ),
                            _buildActionCard(
                              Icons.history,
                              'Ride\nHistory',
                              Colors.purple,
                              onTap: () {
                                context.push(AppRoutes.rideHistory);
                              },
                            ),
                            _buildActionCard(
                              Icons.headset_mic,
                              'Help &\nSupport',
                              Colors.orange,
                              onTap: () {
                                context.push(AppRoutes.support);
                              },
                            ),
                            _buildActionCard(
                              Icons.logout,
                              'Logout',
                              Colors.red,
                              onTap: () => _handleLogout(context),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Edit Profile Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context.push(AppRoutes.editProfile);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0066FF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.edit, color: Colors.white),
                            label: const Text(
                              'Edit Profile',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                  // ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubscriptionCard(
    BuildContext context, {
    required bool hasSubscription,
    DriverActiveSubscriptionEntity? sub,
    String? driverToken,
  }) {
    if (hasSubscription) {
      final planName = sub?.planName.isNotEmpty == true
          ? sub!.planName
          : 'Gold Pro Pass';
      final daysLeft = sub?.daysLeft ?? 29;
      final expiry = sub?.formattedDateRange ?? '';

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF021B45), Color(0xFF0B2C6F), Color(0xFF1E3E62)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF021B45).withValues(alpha: 0.22),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.workspace_premium_rounded,
                        color: Colors.white,
                        size: 13,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'ACTIVE PASS',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 9,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$daysLeft Days Left',
                    style: const TextStyle(
                      color: Color(0xFFFCD34D),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              planName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Zero commission on rides • Priority ride dispatch',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 12,
              ),
            ),
            if (expiry.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                expiry,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 11,
                ),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 38,
              child: ElevatedButton(
                onPressed: () {
                  context
                      .push(
                        AppRoutes.subscription,
                        extra: {
                          'hasSubscription': true,
                          'driverToken': driverToken,
                        },
                      )
                      .then((_) {
                        context.read<ProfileBloc>().add(
                          RefreshProfileEvent(token: driverToken),
                        );
                      });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFCD34D),
                  foregroundColor: const Color(0xFF0F172A),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Manage Subscription Pass',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.stars_rounded,
                color: Color(0xFF0066FF),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Driver Pass Subscription',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '0% commission & unlimited rides',
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                context
                    .push(
                      AppRoutes.subscription,
                      extra: {
                        'hasSubscription': false,
                        'driverToken': driverToken,
                      },
                    )
                    .then((_) {
                      context.read<ProfileBloc>().add(
                        RefreshProfileEvent(token: driverToken),
                      );
                    });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0066FF),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Get Pass',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Sign Out'),
          ],
        ),
        content: const Text(
          'Are you sure you want to sign out? Your session and device push token will be refreshed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AuthBloc>().add(const LogoutEvent());
              context.go(AppRoutes.login);
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF0066FF), size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? const Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    IconData icon,
    String label,
    MaterialColor color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 100, // Fixed height ensures all cards are exactly the same size
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMyTicketsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const _MyTicketsSheet();
      },
    );
  }
}

class _MyTicketsSheet extends StatefulWidget {
  const _MyTicketsSheet();

  @override
  State<_MyTicketsSheet> createState() => _MyTicketsSheetState();
}

class _MyTicketsSheetState extends State<_MyTicketsSheet> {
  XFile? _selectedImage;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Photo Source',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.blue,
                  ),
                  title: const Text(
                    'Take a photo',
                    style: TextStyle(color: Color(0xFF0F172A)),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_rounded,
                    color: Colors.green,
                  ),
                  title: const Text(
                    'Choose from gallery',
                    style: TextStyle(color: Color(0xFF0F172A)),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE0E7FF), Color(0xFFC7D2FE)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.confirmation_number_rounded,
                    color: Color(0xFF4F46E5),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Submit a Ticket',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Create a new support request',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Ticket Title',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'e.g. Missing payment for trip',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.blue.shade400,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Description',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Please provide details so we can help you faster...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.blue.shade400,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Attachments',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _selectedImage == null
                ? InkWell(
                    onTap: _showImagePickerOptions,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.add_a_photo_rounded,
                            color: Colors.blue.shade600,
                            size: 28,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Upload photo from Camera or Gallery',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(_selectedImage!.path),
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Image Attached',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedImage!.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedImage = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ticket submitted successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Submit Ticket',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
