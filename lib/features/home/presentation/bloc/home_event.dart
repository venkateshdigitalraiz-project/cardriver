import 'package:equatable/equatable.dart';
import '../../domain/entities/available_ride_entity.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Toggles driver online / offline status.
class ToggleOnlineStatusEvent extends HomeEvent {
  final bool? forceStatus;

  const ToggleOnlineStatusEvent({this.forceStatus});

  @override
  List<Object?> get props => [forceStatus];
}

/// Loads available rides from the REST API.
class LoadAvailableRidesEvent extends HomeEvent {
  final bool silent;

  const LoadAvailableRidesEvent({this.silent = false});

  @override
  List<Object?> get props => [silent];
}

/// Dispatched when a real-time ride arrives over Socket.IO.
class NewRideReceivedEvent extends HomeEvent {
  final AvailableRideEntity ride;

  const NewRideReceivedEvent(this.ride);

  @override
  List<Object?> get props => [ride];
}

/// Clears the prominent new ride notification alert banner.
class ClearNewRideAlertEvent extends HomeEvent {}

/// Declines / removes a ride request from the driver's list.
class DeclineRideRequestEvent extends HomeEvent {
  final String rideId;

  const DeclineRideRequestEvent(this.rideId);

  /// Backwards-compatible getter
  String get requestId => rideId;

  @override
  List<Object?> get props => [rideId];
}
