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

  const ProfileLoaded({
    this.driverProfile,
    required this.menuItems,
    this.isRefreshing = false,
    this.errorMessage,
  });

  bool get hasSubscription => driverProfile?.hasSubscription ?? false;

  DriverActiveSubscriptionEntity? get activeSubscription =>
      driverProfile?.activeSubscription;

  ProfileLoaded copyWith({
    DriverProfileEntity? driverProfile,
    List<ProfileMenuItem>? menuItems,
    bool? isRefreshing,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProfileLoaded(
      driverProfile: driverProfile ?? this.driverProfile,
      menuItems: menuItems ?? this.menuItems,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        driverProfile,
        menuItems,
        isRefreshing,
        errorMessage,
      ];
}

class ProfileError extends ProfileState {
  final String message;
  final List<ProfileMenuItem> menuItems;

  const ProfileError({
    required this.message,
    this.menuItems = const [],
  });

  @override
  List<Object?> get props => [message, menuItems];
}
