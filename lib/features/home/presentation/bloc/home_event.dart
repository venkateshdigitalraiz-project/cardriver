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

/// Declines / rejects a ride request from the server.
class DeclineRideRequestEvent extends HomeEvent {
  final String rideId;
  final String? reason;

  const DeclineRideRequestEvent(this.rideId, {this.reason});

  /// Backwards-compatible getter
  String get requestId => rideId;

  @override
  List<Object?> get props => [rideId, reason];
}

/// Dispatched when the driver accepts an available ride.
class AcceptRideEvent extends HomeEvent {
  final String rideId;

  const AcceptRideEvent(this.rideId);

  @override
  List<Object?> get props => [rideId];
}

/// Clears the accepted ride state after navigation has handled it.
class ClearAcceptedRideEvent extends HomeEvent {}

/// Clears the rejected ride notification indicator state.
class ClearRejectedRideEvent extends HomeEvent {}

/// Dispatched when a ride is accepted by another driver or no longer available.
class RemoveRideEvent extends HomeEvent {
  final String rideId;
  final String? bookingId;

  const RemoveRideEvent({required this.rideId, this.bookingId});

  @override
  List<Object?> get props => [rideId, bookingId];
}

/// Dispatched when creating a new manual ride entry.
class CreateManualRideEvent extends HomeEvent {
  final String userName;
  final String mobileNumber;
  final String fromAddress;
  final String toAddress;
  final double price;
  final DateTime dateTime;
  final double? pickupLat;
  final double? pickupLng;
  final double? dropLat;
  final double? dropLng;

  const CreateManualRideEvent({
    required this.userName,
    required this.mobileNumber,
    required this.fromAddress,
    required this.toAddress,
    required this.price,
    required this.dateTime,
    this.pickupLat,
    this.pickupLng,
    this.dropLat,
    this.dropLng,
  });

  @override
  List<Object?> get props => [
        userName,
        mobileNumber,
        fromAddress,
        toAddress,
        price,
        dateTime,
        pickupLat,
        pickupLng,
        dropLat,
        dropLng,
      ];
}
