import 'package:equatable/equatable.dart';
import '../../domain/entities/trip_entity.dart';

abstract class TripDetailsEvent extends Equatable {
  const TripDetailsEvent();

  @override
  List<Object?> get props => [];
}

class LoadTripDetailsEvent extends TripDetailsEvent {
  final TripEntity? trip;
  final String bookingId;
  final String? token;

  LoadTripDetailsEvent({
    this.trip,
    String? bookingId,
    this.token,
  }) : bookingId = bookingId ?? trip?.id ?? trip?.bookingId ?? '';

  @override
  List<Object?> get props => [trip, bookingId, token];
}

class RefreshTripDetailsEvent extends TripDetailsEvent {
  final String bookingId;
  final String? token;

  const RefreshTripDetailsEvent({
    required this.bookingId,
    this.token,
  });

  @override
  List<Object?> get props => [bookingId, token];
}
