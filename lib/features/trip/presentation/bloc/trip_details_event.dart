import 'package:cardriver/features/trip/domain/entities/trip_entity.dart';
import 'package:equatable/equatable.dart';

abstract class TripDetailsEvent extends Equatable {
  const TripDetailsEvent();

  @override
  List<Object> get props => [];
}

class LoadTripDetailsEvent extends TripDetailsEvent {
  final TripEntity trip;

  const LoadTripDetailsEvent({required this.trip});

  @override
  List<Object> get props => [trip];
}
