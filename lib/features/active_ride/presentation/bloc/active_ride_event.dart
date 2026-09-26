import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

abstract class ActiveRideEvent extends Equatable {
  const ActiveRideEvent();

  @override
  List<Object?> get props => [];
}

class LoadRouteEvent extends ActiveRideEvent {
  final LatLng startLocation;
  final LatLng endLocation;

  const LoadRouteEvent({
    required this.startLocation,
    required this.endLocation,
  });

  @override
  List<Object?> get props => [startLocation, endLocation];
}
