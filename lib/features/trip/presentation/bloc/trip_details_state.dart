import 'package:cardriver/features/trip/domain/entities/trip_entity.dart';
import 'package:equatable/equatable.dart';

abstract class TripDetailsState extends Equatable {
  const TripDetailsState();

  @override
  List<Object?> get props => [];
}

class TripDetailsInitial extends TripDetailsState {}

class TripDetailsLoading extends TripDetailsState {}

class TripDetailsLoaded extends TripDetailsState {
  final TripEntity trip;

  const TripDetailsLoaded({required this.trip});

  @override
  List<Object?> get props => [trip];
}

class TripDetailsError extends TripDetailsState {
  final String message;

  const TripDetailsError({required this.message});

  @override
  List<Object?> get props => [message];
}
