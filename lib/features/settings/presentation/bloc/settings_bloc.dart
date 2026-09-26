import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsInitial()) {
    on<LoadSettingsEvent>(_onLoadSettings);
  }

  void _onLoadSettings(
    LoadSettingsEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading());

    await Future.delayed(const Duration(milliseconds: 400));

    emit(
      SettingsLoaded(
        driverName: 'Ramesh Kumar',
        vehicleName: 'Toyota Innova',
        isOnline: true,
        menuItems: [
          // SettingsMenuItem(
          //   icon: Icons.settings,
          //   title: 'Driver Settings',
          //   subtitle: 'Manage your driving preferences',
          //   isPrimary: true,
          // ),
          SettingsMenuItem(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Alerts, updates and messages',
          ),
          SettingsMenuItem(
            icon: Icons.security,
            title: 'Account & Security',
            subtitle: 'Change password, 2FA, devices',
          ),
          // SettingsMenuItem(
          //   icon: Icons.directions_car,
          //   title: 'Vehicle Information',
          //   subtitle: 'Manage your vehicle details',
          // ),
          SettingsMenuItem(
            icon: Icons.description,
            title: 'Documents',
            subtitle: 'License, RC, Insurance',
          ),
          // SettingsMenuItem(
          //   icon: Icons.location_on,
          //   title: 'Service Area',
          //   subtitle: 'Set your preferred service area',
          // ),
          // SettingsMenuItem(
          //   icon: Icons.headset_mic,
          //   title: 'Help & Support',
          //   subtitle: 'FAQs, contact us',
          // ),
          SettingsMenuItem(
            icon: Icons.logout,
            title: 'Log Out',
            subtitle: 'Sign out from your account',
          ),
        ],
      ),
    );
  }
}
