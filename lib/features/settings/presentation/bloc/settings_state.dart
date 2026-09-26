import 'package:flutter/material.dart';

abstract class SettingsState {}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final String driverName;
  final String vehicleName;
  final bool isOnline;
  final List<SettingsMenuItem> menuItems;

  SettingsLoaded({
    required this.driverName,
    required this.vehicleName,
    required this.isOnline,
    required this.menuItems,
  });
}

class SettingsMenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isPrimary;

  SettingsMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isPrimary = false,
  });
}
