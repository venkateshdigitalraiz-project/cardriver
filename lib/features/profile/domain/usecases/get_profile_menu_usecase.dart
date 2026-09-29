import 'package:flutter/material.dart';
import '../entities/profile_menu_item.dart';

class GetProfileMenuUseCase {
  List<ProfileMenuItem> execute() {
    return const [
      // ProfileMenuItem(
      //   title: 'Earnings',
      //   subtitle: 'Transfer Money to Bank, History',
      //   icon: Icons.account_balance_wallet_outlined,
      // ),
      ProfileMenuItem(
        title: 'Rewards',
        subtitle: 'Insurance and Discounts',
        icon: Icons.card_giftcard_rounded,
      ),
      ProfileMenuItem(
        title: 'My Tickets',
        subtitle: 'Track Your Support Requests',
        icon: Icons.confirmation_number_outlined,
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
    ];
  }
}
