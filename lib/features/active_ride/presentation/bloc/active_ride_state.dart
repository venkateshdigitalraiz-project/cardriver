import 'package:equatable/equatable.dart';
import '../../domain/entities/route_entity.dart';

abstract class ActiveRideState extends Equatable {
  const ActiveRideState();

  @override
  List<Object?> get props => [];
}

class ActiveRideInitial extends ActiveRideState {}

class ActiveRideLoading extends ActiveRideState {}

class ActiveRideLoaded extends ActiveRideState {
  final RouteEntity route;

  const ActiveRideLoaded({required this.route});

  @override
  List<Object?> get props => [route];
}

class ActiveRideError extends ActiveRideState {
  final String message;

  const ActiveRideError({required this.message});

  @override
  List<Object?> get props => [message];
}
