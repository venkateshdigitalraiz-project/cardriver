import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/style/app_colors.dart';
import '../../../../core/style/app_typography.dart';
import '../../domain/usecases/get_route_usecase.dart';
import '../bloc/active_ride_bloc.dart';
import '../bloc/active_ride_event.dart';
import '../bloc/active_ride_state.dart';

class ActiveRidePage extends StatelessWidget {
  final LatLng startLocation;
  final LatLng endLocation;
  final String startLocationName;
  final String endLocationName;
  final String cost;

  const ActiveRidePage({
    super.key,
    required this.startLocation,
    required this.endLocation,
    required this.startLocationName,
    required this.endLocationName,
    required this.cost,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ActiveRideBloc(getRouteUseCase: GetRouteUseCase())
        ..add(
          LoadRouteEvent(
            startLocation: startLocation,
            endLocation: endLocation,
          ),
        ),
      child: _ActiveRideView(
        startLocationName: startLocationName,
        endLocationName: endLocationName,
        cost: cost,
      ),
    );
  }
}

class _ActiveRideView extends StatelessWidget {
  final String startLocationName;
  final String endLocationName;
  final String cost;

  const _ActiveRideView({
    required this.startLocationName,
    required this.endLocationName,
    required this.cost,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.circle,
                  color: Color(0xFF10B981), // Green for start
                  size: 12,
                ),
                Container(
                  width: 2,
                  height: 18,
                  color: Colors.grey.shade400,
                  margin: const EdgeInsets.symmetric(vertical: 2),
                ),
                const Icon(
                  Icons.location_on,
                  color: AppColors.error, // Red for end
                  size: 16,
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'From: $startLocationName',
                    style: AppTypography.bodySmall(color: Colors.black),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'To: $endLocationName',
                    style: AppTypography.bodySmall(color: Colors.black),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.lightSurface,
      ),
      body: BlocBuilder<ActiveRideBloc, ActiveRideState>(
        builder: (context, state) {
          if (state is ActiveRideLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ActiveRideError) {
            return Center(child: Text(state.message));
          }
          if (state is ActiveRideLoaded) {
            final route = state.route;
            // Calculate map bounds
            final bounds = LatLngBounds.fromPoints(route.polylinePoints);

            return Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCameraFit: CameraFit.bounds(
                      bounds: bounds,
                      padding: const EdgeInsets.all(50.0),
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.cardriver',
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: route.polylinePoints,
                          color: Colors.blue,
                          strokeWidth: 4.0,
                        ),
                      ],
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: route.startLocation,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.my_location_rounded,
                            color: Color(0xFF10B981),
                            size: 30,
                          ),
                        ),
                        Marker(
                          point: route.endLocation,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: AppColors.error,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Overlay for duration and distance
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Distance',
                                  style: AppTypography.bodySmall(
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  route.distance,
                                  style: AppTypography.bodySmall(
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey.shade300,
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Est. Time',
                                  style: AppTypography.bodySmall(
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  route.duration,
                                  style: AppTypography.bodySmall(
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey.shade300,
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Cost',
                                  style: AppTypography.bodySmall(
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  cost,
                                  style: AppTypography.bodySmall(
                                    color: const Color(0xFF10B981),
                                  ).copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Accept action logic here
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Accept Ride',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
