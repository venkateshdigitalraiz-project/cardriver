import 'package:flutter/material.dart';
import '../entities/profile_menu_item.dart';

class GetProfileMenuUseCase {
  List<ProfileMenuItem> execute() {
    return const [
      ProfileMenuItem(
        title: 'Earnings',
        subtitle: 'Transfer Money to Bank, History',
        icon: Icons.account_balance_wallet_outlined,
      ),
      ProfileMenuItem(
        title: 'Incentives and More',
        subtitle: 'Know how you get paid',
        icon: Icons.money,
      ),
      ProfileMenuItem(
        title: 'Rewards',
        subtitle: 'Insurance and Discounts',
        icon: Icons.card_giftcard_rounded,
      ),
      ProfileMenuItem(
        title: 'Service Manager',
        subtitle: 'Food Delivery & more',
        icon: Icons.grid_view_rounded,
      ),
      ProfileMenuItem(
        title: 'Demand Planner',
        subtitle: 'Past High Demand Areas & More',
        icon: Icons.hexagon_outlined,
      ),
      ProfileMenuItem(
        title: 'Help',
        subtitle: 'Get support, Accident Insurance',
        icon: Icons.headset_mic_outlined,
      ),
    ];
  }
}
