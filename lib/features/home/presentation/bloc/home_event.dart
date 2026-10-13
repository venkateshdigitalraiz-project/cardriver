import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class ToggleOnlineStatusEvent extends HomeEvent {}

class DeclineRideRequestEvent extends HomeEvent {
  final String requestId;

  const DeclineRideRequestEvent(this.requestId);

  @override
  List<Object> get props => [requestId];
}
