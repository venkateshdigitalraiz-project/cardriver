import 'package:latlong2/latlong.dart';
import 'package:equatable/equatable.dart';

class RouteEntity extends Equatable {
  final List<LatLng> polylinePoints;
  final LatLng startLocation;
  final LatLng endLocation;
  final String duration;
  final String distance;

  const RouteEntity({
    required this.polylinePoints,
    required this.startLocation,
    required this.endLocation,
    required this.duration,
    required this.distance,
  });

  @override
  List<Object?> get props => [
        polylinePoints,
        startLocation,
        endLocation,
        duration,
        distance,
      ];
}
