import '../entities/route_entity.dart';
import 'package:latlong2/latlong.dart';

class GetRouteUseCase {
  // In a real app, this would use a repository to fetch data from an API
  // Here we mock a route for demonstration
  Future<RouteEntity> execute(LatLng start, LatLng end) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // Mocking polyline points between start and end
    final points = [
      start,
      LatLng(start.latitude + (end.latitude - start.latitude) * 0.25, start.longitude + (end.longitude - start.longitude) * 0.1),
      LatLng(start.latitude + (end.latitude - start.latitude) * 0.5, start.longitude + (end.longitude - start.longitude) * 0.6),
      LatLng(start.latitude + (end.latitude - start.latitude) * 0.75, start.longitude + (end.longitude - start.longitude) * 0.8),
      end,
    ];

    return RouteEntity(
      polylinePoints: points,
      startLocation: start,
      endLocation: end,
      duration: '15 mins',
      distance: '5.2 km',
    );
  }
}
