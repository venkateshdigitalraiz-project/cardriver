import 'package:equatable/equatable.dart';
import '../../domain/entities/trip_entity.dart';

abstract class TripDetailsState extends Equatable {
  const TripDetailsState();

  @override
  List<Object?> get props => [];
}

class TripDetailsInitial extends TripDetailsState {}

class TripDetailsLoading extends TripDetailsState {
  final TripEntity? cachedTrip;

  const TripDetailsLoading({this.cachedTrip});

  @override
  List<Object?> get props => [cachedTrip];
}

class TripDetailsLoaded extends TripDetailsState {
  final TripEntity trip;
  final bool isRefreshing;

  const TripDetailsLoaded({
    required this.trip,
    this.isRefreshing = false,
  });

  @override
  List<Object?> get props => [trip, isRefreshing];
}

class TripDetailsError extends TripDetailsState {
  final String message;
  final TripEntity? cachedTrip;

  const TripDetailsError({
    required this.message,
    this.cachedTrip,
  });

  @override
  List<Object?> get props => [message, cachedTrip];
}
