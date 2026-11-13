import 'package:flutter/material.dart';
import '../entities/profile_menu_item.dart';

class GetProfileMenuUseCase {
  List<ProfileMenuItem> execute() {
    return const [
      ProfileMenuItem(
        title: 'Review',
        subtitle: 'Rating Customer | Trip Experience',
        icon: Icons.star_rounded,
      ),
      ProfileMenuItem(
        title: 'Refer & Earn',
        subtitle: 'Invite driver & friends to earn wallet',
        icon: Icons.card_giftcard_rounded,
      ),
      ProfileMenuItem(
        title: 'My Booking',
        subtitle: 'View & Manage D-to-D Bookings',
        icon: Icons.calendar_month_rounded,
      ),
      ProfileMenuItem(
        title: 'Driver Jobs',
        subtitle: 'View & Apply for Full-Time Jobs',
        icon: Icons.work_rounded,
      ),
      ProfileMenuItem(
        title: 'Subscription',
        subtitle: 'Manage Your Plan & Benefits',
        icon: Icons.stars_rounded,
      ),
      ProfileMenuItem(
        title: 'Subscription History',
        subtitle: 'View All Subscription Transactions',
        icon: Icons.history_rounded,
      ),
      ProfileMenuItem(
        title: 'Wallet',
        subtitle: 'Balance: ₹1,250 • Payouts & Settlement',
        icon: Icons.account_balance_wallet_rounded,
      ),
      ProfileMenuItem(
        title: 'Notifications',
        subtitle: 'Alert, Updates and Message',
        icon: Icons.notifications_none,
      ),
      ProfileMenuItem(
        title: 'Rewards',
        subtitle: 'Insurance and Discounts',
        icon: Icons.card_giftcard_rounded,
      ),

      ProfileMenuItem(
        title: 'Documents',
        subtitle: 'License, RC,Insurance',
        icon: Icons.document_scanner_sharp,
      ),
      ProfileMenuItem(
        title: 'My Tickets',
        subtitle: 'Track Your Support Requests',
        icon: Icons.confirmation_number_outlined,
      ),
      // ProfileMenuItem(
      //   title: 'Terms & Conditions',
      //   subtitle: 'Read our terms of service',
      //   icon: Icons.description_rounded,
      // ),
      // ProfileMenuItem(
      //   title: 'Privacy Policy',
      //   subtitle: 'Learn how we protect your data',
      //   icon: Icons.privacy_tip_rounded,
      // ),
    ];
  }
}
