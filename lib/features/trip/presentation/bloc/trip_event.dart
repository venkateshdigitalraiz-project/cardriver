import 'package:equatable/equatable.dart';

abstract class TripEvent extends Equatable {
  const TripEvent();

  @override
  List<Object?> get props => [];
}

class LoadTripsEvent extends TripEvent {
  final String? token;
  final bool silent;

  const LoadTripsEvent({this.token, this.silent = false});

  @override
  List<Object?> get props => [token, silent];
}

class RefreshTripsEvent extends TripEvent {
  final String? token;

  const RefreshTripsEvent({this.token});

  @override
  List<Object?> get props => [token];
}

class FilterTripsEvent extends TripEvent {
  final String filterType;

  const FilterTripsEvent(this.filterType);

  @override
  List<Object?> get props => [filterType];
}

class SearchTripsEvent extends TripEvent {
  final String query;

  const SearchTripsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class UpdateTripStatusEvent extends TripEvent {
  final String bookingId;
  final String action;
  final String? otp;
  final double? actualDistance;
  final String? token;

  const UpdateTripStatusEvent({
    required this.bookingId,
    required this.action,
    this.otp,
    this.actualDistance,
    this.token,
  });

  @override
  List<Object?> get props => [bookingId, action, otp, actualDistance, token];
}

class DismissTripCompletionDialogEvent extends TripEvent {
  const DismissTripCompletionDialogEvent();

  @override
  List<Object?> get props => [];
}


