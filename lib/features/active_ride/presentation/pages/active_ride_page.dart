import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/style/app_colors.dart';
import '../../../../core/style/app_typography.dart';
import '../../../home/domain/entities/accepted_ride_entity.dart';

class ActiveRidePage extends StatefulWidget {
  final AcceptedRideEntity? acceptedRide;
  final LatLng? startLocation;
  final LatLng? endLocation;
  final String? startLocationName;
  final String? endLocationName;
  final String? cost;

  const ActiveRidePage({
    super.key,
    this.acceptedRide,
    this.startLocation,
    this.endLocation,
    this.startLocationName,
    this.endLocationName,
    this.cost,
  });

  @override
  State<ActiveRidePage> createState() => _ActiveRidePageState();
}

class _ActiveRidePageState extends State<ActiveRidePage> {
  late final MapController _mapController;
  int _currentStepIndex = 0; // 0: Driver Assigned, 1: Arrived, 2: Trip Started, 3: Completed

  static const List<String> _stepTitles = [
    'DRIVER ASSIGNED',
    'ARRIVED AT PICKUP',
    'TRIP IN PROGRESS',
    'TRIP COMPLETED',
  ];

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  LatLng get _pickupCoord {
    if (widget.acceptedRide != null) {
      return widget.acceptedRide!.pickupCoord;
    }
    return widget.startLocation ?? const LatLng(28.6139, 77.2090);
  }

  LatLng get _dropCoord {
    if (widget.acceptedRide != null) {
      return widget.acceptedRide!.dropCoord;
    }
    return widget.endLocation ?? const LatLng(28.6239, 77.2190);
  }

  String get _pickupAddress {
    if (widget.acceptedRide != null) {
      return widget.acceptedRide!.pickupAddress;
    }
    return widget.startLocationName ?? 'Pickup Location';
  }

  String get _dropAddress {
    if (widget.acceptedRide != null) {
      return widget.acceptedRide!.dropAddress;
    }
    return widget.endLocationName ?? 'Drop Location';
  }

  String get _totalFare {
    if (widget.acceptedRide != null) {
      return widget.acceptedRide!.formattedTotalAmount;
    }
    return widget.cost ?? '₹0';
  }

  String get _bookingId {
    if (widget.acceptedRide != null && widget.acceptedRide!.bookingId.isNotEmpty) {
      return widget.acceptedRide!.bookingId;
    }
    return 'BKG-ACTIVE';
  }

  String get _scheduledTime {
    if (widget.acceptedRide != null) {
      return widget.acceptedRide!.formattedScheduledTime;
    }
    return 'Now';
  }

  void _recenterMap() {
    final bounds = LatLngBounds(_pickupCoord, _dropCoord);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(50),
      ),
    );
  }

  void _advanceStep() {
    if (_currentStepIndex < _stepTitles.length - 1) {
      setState(() {
        _currentStepIndex++;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status updated to: ${_stepTitles[_currentStepIndex]}'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final centerLat = (_pickupCoord.latitude + _dropCoord.latitude) / 2;
    final centerLng = (_pickupCoord.longitude + _dropCoord.longitude) / 2;
    final centerCoord = LatLng(centerLat, centerLng);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Active Trip',
              style: AppTypography.headingSmall(color: AppColors.textPrimaryLight)
                  .copyWith(fontSize: 16),
            ),
            Row(
              children: [
                Text(
                  'ID: $_bookingId',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: _bookingId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Booking ID copied to clipboard'),
                        duration: Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Icon(Icons.copy_rounded, size: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _stepTitles[_currentStepIndex],
                  style: const TextStyle(
                    color: Color(0xFF047857),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Live Interactive Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: centerCoord,
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.cardriver.app',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [_pickupCoord, _dropCoord],
                    strokeWidth: 4.5,
                    color: const Color(0xFF10B981),
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  // Pickup Marker
                  Marker(
                    point: _pickupCoord,
                    width: 44,
                    height: 44,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withValues(alpha: 0.4),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.my_location_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  // Drop Marker
                  Marker(
                    point: _dropCoord,
                    width: 44,
                    height: 44,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.error.withValues(alpha: 0.4),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.flag_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 2. Floating Map Action Buttons
          Positioned(
            top: 16,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'recenter_btn',
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.textPrimaryLight,
                  onPressed: _recenterMap,
                  child: const Icon(Icons.crop_free_rounded),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'traffic_btn',
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF10B981),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('GPS Route active'),
                        duration: Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Icon(Icons.navigation_rounded),
                ),
              ],
            ),
          ),

          // 3. Bottom Ride Sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fare and Time Summary Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Fare',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _totalFare,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Scheduled For',
                              style: TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _scheduledTime,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Route Addresses Timeline
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF10B981), width: 3),
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            width: 2,
                            height: 40,
                            color: Colors.grey.shade300,
                            margin: const EdgeInsets.symmetric(vertical: 3),
                          ),
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.error, width: 3),
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PICKUP',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            Text(
                              _pickupAddress,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'DROP OFF',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            Text(
                              _dropAddress,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Quick Action Call / Message Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Connecting call to rider...'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: const Icon(Icons.call_rounded, size: 16),
                          label: const Text('Call Rider'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimaryLight,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Opening chat with rider...'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                          label: const Text('Message'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimaryLight,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Main Status Progression Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _advanceStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentStepIndex == _stepTitles.length - 1
                            ? Colors.black87
                            : const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentStepIndex == 0
                            ? 'ARRIVED AT PICKUP'
                            : (_currentStepIndex == 1
                                ? 'START TRIP'
                                : (_currentStepIndex == 2
                                    ? 'COMPLETE TRIP'
                                    : 'BACK TO HOME')),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
