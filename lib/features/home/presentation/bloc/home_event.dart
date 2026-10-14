import 'package:equatable/equatable.dart';
import '../../domain/entities/available_ride_entity.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class ToggleOnlineStatusEvent extends HomeEvent {
  final bool? forceStatus;

  const ToggleOnlineStatusEvent({this.forceStatus});

  @override
  List<Object?> get props => [forceStatus];
}

class StartMonitoringRidesEvent extends HomeEvent {
  final String? token;

  const StartMonitoringRidesEvent({this.token});

  @override
  List<Object?> get props => [token];
}

class StopMonitoringRidesEvent extends HomeEvent {}

class RidesUpdatedEvent extends HomeEvent {
  final List<AvailableRideEntity> rides;

  const RidesUpdatedEvent(this.rides);

  @override
  List<Object?> get props => [rides];
}

class DeclineRideRequestEvent extends HomeEvent {
  final String requestId;

  const DeclineRideRequestEvent(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

class ClearNewRideAlertEvent extends HomeEvent {}
