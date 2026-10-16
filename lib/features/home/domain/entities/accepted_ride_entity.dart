import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

/// Represents a successfully accepted ride booking returned by the server.
class AcceptedRideEntity extends Equatable {
  final String bookingId;
  final String bookingStatus;
  final String scheduledStartTime;
  final String pickupAddress;
  final double pickupLat;
  final double pickupLng;
  final String dropAddress;
  final double dropLat;
  final double dropLng;
  final double totalAmount;
  final String message;

  const AcceptedRideEntity({
    required this.bookingId,
    required this.bookingStatus,
    required this.scheduledStartTime,
    required this.pickupAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropAddress,
    required this.dropLat,
    required this.dropLng,
    required this.totalAmount,
    this.message = 'Ride accepted successfully',
  });

  /// Formatted total amount with Rupee symbol
  String get formattedTotalAmount => '₹${totalAmount.toStringAsFixed(0)}';

  /// LatLng coordinate for pickup location
  LatLng get pickupCoord => LatLng(
        pickupLat != 0.0 ? pickupLat : 28.6139,
        pickupLng != 0.0 ? pickupLng : 77.2090,
      );

  /// LatLng coordinate for drop location
  LatLng get dropCoord => LatLng(
        dropLat != 0.0 ? dropLat : 28.6239,
        dropLng != 0.0 ? dropLng : 77.2190,
      );

  /// Human-friendly display status (e.g. 'Driver Assigned')
  String get statusDisplayName {
    switch (bookingStatus.toLowerCase()) {
      case 'driver_assigned':
        return 'Driver Assigned';
      case 'on_the_way':
      case 'en_route':
        return 'En Route to Pickup';
      case 'arrived':
        return 'Arrived at Pickup';
      case 'in_progress':
      case 'started':
        return 'Trip in Progress';
      case 'completed':
        return 'Completed';
      default:
        return bookingStatus.replaceAll('_', ' ').toUpperCase();
    }
  }

  /// Formatted scheduled time string (e.g. "26 Sep 2026 • 10:00 AM")
  String get formattedScheduledTime {
    if (scheduledStartTime.isEmpty) return 'Immediate';
    try {
      final dt = DateTime.parse(scheduledStartTime).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      final month = months[dt.month - 1];
      final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      final minute = dt.minute.toString().padLeft(2, '0');
      return '${dt.day} $month ${dt.year} • $hour:$minute $period';
    } catch (_) {
      return scheduledStartTime;
    }
  }

  /// Factory constructor to parse backend response
  factory AcceptedRideEntity.fromJson(Map<String, dynamic> json, {String? defaultMessage}) {
    double toD(dynamic v) {
      if (v is num) return v.toDouble();
      return double.tryParse('$v') ?? 0.0;
    }

    String toS(dynamic v) => v?.toString() ?? '';

    // Handle pickupLocation parsing (GeoJSON [lng, lat] or lat/lng fields)
    final pickup = json['pickupLocation'] ?? json['pickup'] ?? const {};
    final pickupMap = pickup is Map ? pickup : const {};
    final pickupAddress = toS(pickupMap['address'] ?? json['pickupAddress']);

    double pLat = 0.0;
    double pLng = 0.0;

    final pLoc = pickupMap['location'];
    if (pLoc is Map && pLoc['coordinates'] is List) {
      final coords = pLoc['coordinates'] as List;
      if (coords.length >= 2) {
        // GeoJSON Point: [longitude, latitude]
        pLng = toD(coords[0]);
        pLat = toD(coords[1]);
      }
    } else {
      pLat = toD(pickupMap['lat'] ?? pickupMap['latitude']);
      pLng = toD(pickupMap['lng'] ?? pickupMap['longitude']);
    }

    // Handle dropLocation parsing (GeoJSON [lng, lat] or lat/lng fields)
    final drop = json['dropLocation'] ?? json['drop'] ?? const {};
    final dropMap = drop is Map ? drop : const {};
    final dropAddress = toS(dropMap['address'] ?? json['dropAddress']);

    double dLat = 0.0;
    double dLng = 0.0;

    final dLoc = dropMap['location'];
    if (dLoc is Map && dLoc['coordinates'] is List) {
      final coords = dLoc['coordinates'] as List;
      if (coords.length >= 2) {
        // GeoJSON Point: [longitude, latitude]
        dLng = toD(coords[0]);
        dLat = toD(coords[1]);
      }
    } else {
      dLat = toD(dropMap['lat'] ?? dropMap['latitude']);
      dLng = toD(dropMap['lng'] ?? dropMap['longitude']);
    }

    return AcceptedRideEntity(
      bookingId: toS(json['bookingId'] ?? json['id'] ?? json['_id']),
      bookingStatus: toS(json['bookingStatus'] ?? 'driver_assigned'),
      scheduledStartTime: toS(json['scheduledStartTime'] ?? json['startTime']),
      pickupAddress: pickupAddress.isNotEmpty ? pickupAddress : 'Pickup Location',
      pickupLat: pLat,
      pickupLng: pLng,
      dropAddress: dropAddress.isNotEmpty ? dropAddress : 'Drop Location',
      dropLat: dLat,
      dropLng: dLng,
      totalAmount: toD(json['totalAmount'] ?? json['fare'] ?? json['amount']),
      message: toS(json['message'] ?? defaultMessage ?? 'Ride accepted successfully'),
    );
  }

  @override
  List<Object?> get props => [
        bookingId,
        bookingStatus,
        scheduledStartTime,
        pickupAddress,
        pickupLat,
        pickupLng,
        dropAddress,
        dropLat,
        dropLng,
        totalAmount,
        message,
      ];
}
