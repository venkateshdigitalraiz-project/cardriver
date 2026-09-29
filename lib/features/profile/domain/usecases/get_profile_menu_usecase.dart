import 'package:flutter/material.dart';
import '../entities/profile_menu_item.dart';

class GetProfileMenuUseCase {
  List<ProfileMenuItem> execute() {
    return const [
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
      ProfileMenuItem(
        title: 'Terms & Conditions',
        subtitle: 'Read our terms of service',
        icon: Icons.description_rounded,
      ),
      ProfileMenuItem(
        title: 'Privacy Policy',
        subtitle: 'Learn how we protect your data',
        icon: Icons.privacy_tip_rounded,
      ),
    ];
  }
}
