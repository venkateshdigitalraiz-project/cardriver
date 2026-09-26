import 'package:equatable/equatable.dart';

abstract class TripEvent extends Equatable {
  const TripEvent();

  @override
  List<Object?> get props => [];
}

class LoadTripsEvent extends TripEvent {}

class FilterTripsEvent extends TripEvent {
  final String filterType;

  const FilterTripsEvent(this.filterType);

  @override
  List<Object?> get props => [filterType];
}
