import '../../domain/entities/available_ride_entity.dart';

class AvailableRideModel extends AvailableRideEntity {
  const AvailableRideModel({
    required super.id,
    required super.bookingId,
    required super.riderName,
    required super.riderPhone,
    required super.riderCustId,
    required super.pickupAddress,
    required super.pickupLat,
    required super.pickupLng,
    required super.dropAddress,
    required super.dropLat,
    required super.dropLng,
    required super.fare,
    required super.driverFee,
    required super.serviceType,
    required super.tripType,
    required super.vehicleType,
    required super.durationHours,
    super.durationDays = 0,
    super.returnDate = '',
    super.bookingMode = '',
    required super.distanceKm,
    required super.scheduledStartTime,
    required super.startOtp,
    required super.bookingStatus,
    required super.paymentMethod,
    required super.paymentStatus,
    required super.createdAt,
  });

  factory AvailableRideModel.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic val, [double fallback = 0.0]) {
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? fallback;
      return fallback;
    }

    int toInt(dynamic val, [int fallback = 0]) {
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? fallback;
      return fallback;
    }

    // Pickup Location Parsing
    final pickupMap = json['pickupLocation'] is Map
        ? Map<String, dynamic>.from(json['pickupLocation'] as Map)
        : null;
    final pickupAddress = pickupMap?['address']?.toString() ??
        json['pickupAddress']?.toString() ??
        'Pickup Location';

    double pickupLat = 0.0;
    double pickupLng = 0.0;
    if (pickupMap != null) {
      if (pickupMap['location'] is Map) {
        final loc = Map<String, dynamic>.from(pickupMap['location'] as Map);
        if (loc['coordinates'] is List && (loc['coordinates'] as List).length >= 2) {
          pickupLng = toDouble((loc['coordinates'] as List)[0]);
          pickupLat = toDouble((loc['coordinates'] as List)[1]);
        }
      }
      if (pickupLat == 0.0 && pickupLng == 0.0) {
        pickupLat = toDouble(pickupMap['lat'] ?? pickupMap['latitude']);
        pickupLng = toDouble(pickupMap['lng'] ?? pickupMap['longitude']);
      }
    }
    if (pickupLat == 0.0 && pickupLng == 0.0) {
      pickupLat = toDouble(json['pickupLat'] ?? json['pickupLatitude']);
      pickupLng = toDouble(json['pickupLng'] ?? json['pickupLongitude']);
    }

    // Drop Location Parsing
    final dropMap = json['dropLocation'] is Map
        ? Map<String, dynamic>.from(json['dropLocation'] as Map)
        : null;
    final dropAddress = dropMap?['address']?.toString() ??
        json['dropAddress']?.toString() ??
        'Drop Location';

    double dropLat = 0.0;
    double dropLng = 0.0;
    if (dropMap != null) {
      if (dropMap['location'] is Map) {
        final loc = Map<String, dynamic>.from(dropMap['location'] as Map);
        if (loc['coordinates'] is List && (loc['coordinates'] as List).length >= 2) {
          dropLng = toDouble((loc['coordinates'] as List)[0]);
          dropLat = toDouble((loc['coordinates'] as List)[1]);
        }
      }
      if (dropLat == 0.0 && dropLng == 0.0) {
        dropLat = toDouble(dropMap['lat'] ?? dropMap['latitude']);
        dropLng = toDouble(dropMap['lng'] ?? dropMap['longitude']);
      }
    }
    if (dropLat == 0.0 && dropLng == 0.0) {
      dropLat = toDouble(json['dropLat'] ?? json['dropLatitude']);
      dropLng = toDouble(json['dropLng'] ?? json['dropLongitude']);
    }

    // User Details Parsing
    final userDetails = json['userDetails'] is Map
        ? Map<String, dynamic>.from(json['userDetails'] as Map)
        : (json['user'] is Map
            ? Map<String, dynamic>.from(json['user'] as Map)
            : null);

    final firstName = userDetails?['firstName']?.toString() ?? '';
    final lastName = userDetails?['lastName']?.toString() ?? '';
    final fullName = '$firstName $lastName'.trim();
    final directName = userDetails?['name']?.toString() ??
        json['riderName']?.toString() ??
        json['customerName']?.toString() ??
        '';
    final riderName = fullName.isNotEmpty
        ? fullName
        : (directName.isNotEmpty ? directName : 'Passenger');

    final riderPhone = userDetails?['phone']?.toString() ??
        json['riderPhone']?.toString() ??
        json['customerPhone']?.toString() ??
        '';
    final riderCustId = userDetails?['custId']?.toString() ??
        json['riderCustId']?.toString() ??
        json['customerId']?.toString() ??
        '';

    final id = json['_id']?.toString() ??
        json['id']?.toString() ??
        json['bookingId']?.toString() ??
        json['booking_id']?.toString() ??
        json['rideId']?.toString() ??
        json['ride_id']?.toString() ??
        '';
    final bookingId = json['bookingId']?.toString() ??
        json['booking_id']?.toString() ??
        json['rideId']?.toString() ??
        json['ride_id']?.toString() ??
        (id.isNotEmpty
            ? 'BKG-${id.substring(0, id.length > 8 ? 8 : id.length).toUpperCase()}'
            : 'BKG-${DateTime.now().millisecondsSinceEpoch}');

    final durationDays = toInt(
      json['durationDays'] ?? json['duration_days'] ?? json['days'],
      0,
    );
    final durationHours = toInt(
      json['durationHours'] ?? json['duration_hours'] ?? json['duration'],
      durationDays > 0 ? durationDays * 24 : 1,
    );
    final scheduledStartTime = json['scheduledStartTime']?.toString() ??
        json['scheduled_start_time']?.toString() ??
        json['startTime']?.toString() ??
        '';
    final returnDate = json['returnDate']?.toString() ??
        json['return_date']?.toString() ??
        '';
    final bookingMode = json['bookingMode']?.toString() ??
        json['booking_mode']?.toString() ??
        '';

    return AvailableRideModel(
      id: id,
      bookingId: bookingId,
      riderName: riderName,
      riderPhone: riderPhone,
      riderCustId: riderCustId,
      pickupAddress: pickupAddress,
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      dropAddress: dropAddress,
      dropLat: dropLat,
      dropLng: dropLng,
      fare: toDouble(
        json['totalAmount'] ?? json['total_amount'] ?? json['baseAmount'] ?? json['fare'] ?? json['amount'],
      ),
      driverFee: toDouble(
        json['driverFee'] ?? json['driver_fee'] ?? json['driverPrice'] ?? json['driver_price'],
      ),
      serviceType: json['serviceType']?.toString() ?? json['service_type']?.toString() ?? 'local',
      tripType: json['tripType']?.toString() ?? json['trip_type']?.toString() ?? 'round_trip',
      vehicleType: json['vehicleType']?.toString() ?? json['vehicle_type']?.toString() ?? 'standard',
      durationHours: durationHours,
      durationDays: durationDays,
      returnDate: returnDate,
      bookingMode: bookingMode,
      distanceKm: toDouble(
        json['distanceKm'] ?? json['distance_km'] ?? json['estimatedDistance'] ?? json['estimated_distance'],
      ),
      scheduledStartTime: scheduledStartTime,
      startOtp: json['startOtp']?.toString() ?? json['start_otp']?.toString() ?? json['otp']?.toString() ?? '',
      bookingStatus: json['bookingStatus']?.toString() ?? json['booking_status']?.toString() ?? 'pending',
      paymentMethod: json['paymentMethod']?.toString() ?? json['payment_method']?.toString() ?? 'online',
      paymentStatus: json['paymentStatus']?.toString() ?? json['payment_status']?.toString() ?? 'pending',
      createdAt: json['createdAt']?.toString() ?? json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'bookingId': bookingId,
      'userDetails': {
        'firstName': riderName,
        'phone': riderPhone,
        'custId': riderCustId,
      },
      'pickupLocation': {
        'address': pickupAddress,
        'location': {
          'type': 'Point',
          'coordinates': [pickupLng, pickupLat],
        },
      },
      'dropLocation': {
        'address': dropAddress,
        'location': {
          'type': 'Point',
          'coordinates': [dropLng, dropLat],
        },
      },
      'totalAmount': totalAmount,
      'driverFee': driverFee,
      'serviceType': serviceType,
      'tripType': tripType,
      'vehicleType': vehicleType,
      'durationHours': durationHours,
      'durationDays': durationDays,
      'distanceKm': distanceKm,
      'scheduledStartTime': scheduledStartTime,
      'returnDate': returnDate,
      'bookingMode': bookingMode,
      'startOtp': startOtp,
      'bookingStatus': bookingStatus,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'createdAt': createdAt,
    };
  }
}
