import 'package:equatable/equatable.dart';
import '../../domain/entities/driver_active_subscription_entity.dart';
import '../../domain/entities/driver_profile_entity.dart';
import '../../domain/entities/profile_menu_item.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {
  final List<ProfileMenuItem> menuItems;

  const ProfileLoading({this.menuItems = const []});

  @override
  List<Object?> get props => [menuItems];
}

class ProfileLoaded extends ProfileState {
  final DriverProfileEntity? driverProfile;
  final List<ProfileMenuItem> menuItems;
  final bool isRefreshing;
  final String? errorMessage;
  final int? statusCode;
  final bool isSessionExpired;

  const ProfileLoaded({
    this.driverProfile,
    required this.menuItems,
    this.isRefreshing = false,
    this.errorMessage,
    this.statusCode,
    this.isSessionExpired = false,
  });

  bool get hasSubscription => driverProfile?.hasSubscription ?? false;

  DriverActiveSubscriptionEntity? get activeSubscription =>
      driverProfile?.activeSubscription;

  ProfileLoaded copyWith({
    DriverProfileEntity? driverProfile,
    List<ProfileMenuItem>? menuItems,
    bool? isRefreshing,
    String? errorMessage,
    int? statusCode,
    bool? isSessionExpired,
    bool clearError = false,
  }) {
    return ProfileLoaded(
      driverProfile: driverProfile ?? this.driverProfile,
      menuItems: menuItems ?? this.menuItems,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      statusCode: clearError ? null : (statusCode ?? this.statusCode),
      isSessionExpired:
          clearError ? false : (isSessionExpired ?? this.isSessionExpired),
    );
  }

  @override
  List<Object?> get props => [
        driverProfile,
        menuItems,
        isRefreshing,
        errorMessage,
        statusCode,
        isSessionExpired,
      ];
}

class ProfileError extends ProfileState {
  final String message;
  final List<ProfileMenuItem> menuItems;
  final int? statusCode;
  final bool isSessionExpired;

  const ProfileError({
    required this.message,
    this.menuItems = const [],
    this.statusCode,
    this.isSessionExpired = false,
  });

  @override
  List<Object?> get props => [message, menuItems, statusCode, isSessionExpired];
}
