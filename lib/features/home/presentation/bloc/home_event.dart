import 'package:equatable/equatable.dart';
import '../../data/models/d_to_d_booking_model.dart';
import '../../domain/entities/available_ride_entity.dart';
import '../../domain/entities/d_to_d_booking_entity.dart';

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
  final String serviceType;
  final String tripType;
  final int duration;
  final String vehicleType;

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
    this.serviceType = 'local',
    this.tripType = 'one_way',
    this.duration = 2,
    this.vehicleType = 'Sedan',
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
        serviceType,
        tripType,
        duration,
        vehicleType,
      ];
}

/// Dispatched when the driver taps the WhatsApp support icon in the HomePage AppBar.
class OpenWhatsAppSupportEvent extends HomeEvent {
  final String? message;

  const OpenWhatsAppSupportEvent({this.message});

  @override
  List<Object?> get props => [message];
}

/// Dispatched when submitting a Driver-to-Driver booking to the API:
/// POST http://localhost:3000/api/driver/d-to-d-bookings
class CreateDtoDBookingEvent extends HomeEvent {
  final DtoDBookingRequestModel request;
  final String? token;
  final void Function(DtoDBookingEntity booking)? onSuccess;
  final void Function(String error)? onError;

  const CreateDtoDBookingEvent({
    required this.request,
    this.token,
    this.onSuccess,
    this.onError,
  });

  @override
  List<Object?> get props => [request, token];
}

/// Clears D-to-D booking success/error state.
class ClearDtoDBookingStatusEvent extends HomeEvent {}

/// Dispatched to load common charges from GET /api/common/charges.
class LoadCommonChargesEvent extends HomeEvent {
  final String? token;
  final bool silent;

  const LoadCommonChargesEvent({this.token, this.silent = false});

  @override
  List<Object?> get props => [token, silent];
}

/// Dispatched to clear general error message from HomeState.
class ClearHomeErrorEvent extends HomeEvent {}

