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
    required super.totalAmount,
    required super.driverFee,
    required super.serviceType,
    required super.tripType,
    required super.vehicleType,
    required super.durationHours,
    required super.distanceKm,
    required super.scheduledStartTime,
    required super.startOtp,
    required super.bookingStatus,
    required super.paymentMethod,
    required super.paymentStatus,
    required super.createdAt,
  });

  factory AvailableRideModel.fromJson(Map<String, dynamic> json) {
    // Pickup Location Parsing
    final pickupMap = json['pickupLocation'] as Map<String, dynamic>?;
    final pickupAddress = pickupMap?['address']?.toString() ?? 'Pickup Location';
    double pickupLat = 0.0;
    double pickupLng = 0.0;
    if (pickupMap?['location'] is Map<String, dynamic>) {
      final loc = pickupMap!['location'] as Map<String, dynamic>;
      if (loc['coordinates'] is List && (loc['coordinates'] as List).length >= 2) {
        pickupLng = ((loc['coordinates'] as List)[0] as num).toDouble();
        pickupLat = ((loc['coordinates'] as List)[1] as num).toDouble();
      }
    }

    // Drop Location Parsing
    final dropMap = json['dropLocation'] as Map<String, dynamic>?;
    final dropAddress = dropMap?['address']?.toString() ?? 'Drop Location';
    double dropLat = 0.0;
    double dropLng = 0.0;
    if (dropMap?['location'] is Map<String, dynamic>) {
      final loc = dropMap!['location'] as Map<String, dynamic>;
      if (loc['coordinates'] is List && (loc['coordinates'] as List).length >= 2) {
        dropLng = ((loc['coordinates'] as List)[0] as num).toDouble();
        dropLat = ((loc['coordinates'] as List)[1] as num).toDouble();
      }
    }

    // User Details Parsing
    final userDetails = json['userDetails'] as Map<String, dynamic>?;
    final firstName = userDetails?['firstName']?.toString() ?? '';
    final lastName = userDetails?['lastName']?.toString() ?? '';
    final fullName = '$firstName $lastName'.trim();
    final riderName = fullName.isNotEmpty ? fullName : 'Passenger';
    final riderPhone = userDetails?['phone']?.toString() ?? '';
    final riderCustId = userDetails?['custId']?.toString() ?? '';

    return AvailableRideModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      bookingId: json['bookingId']?.toString() ?? 'BKG-${DateTime.now().millisecondsSinceEpoch}',
      riderName: riderName,
      riderPhone: riderPhone,
      riderCustId: riderCustId,
      pickupAddress: pickupAddress,
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      dropAddress: dropAddress,
      dropLat: dropLat,
      dropLng: dropLng,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? (json['baseAmount'] as num?)?.toDouble() ?? 0.0,
      driverFee: (json['driverFee'] as num?)?.toDouble() ?? 0.0,
      serviceType: json['serviceType']?.toString() ?? 'local',
      tripType: json['tripType']?.toString() ?? 'round_trip',
      vehicleType: json['vehicleType']?.toString() ?? 'standard',
      durationHours: (json['durationHours'] as num?)?.toInt() ?? 1,
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? (json['estimatedDistance'] as num?)?.toDouble() ?? 0.0,
      scheduledStartTime: json['scheduledStartTime']?.toString() ?? '',
      startOtp: json['startOtp']?.toString() ?? '',
      bookingStatus: json['bookingStatus']?.toString() ?? 'pending',
      paymentMethod: json['paymentMethod']?.toString() ?? 'online',
      paymentStatus: json['paymentStatus']?.toString() ?? 'pending',
      createdAt: json['createdAt']?.toString() ?? '',
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
      'distanceKm': distanceKm,
      'scheduledStartTime': scheduledStartTime,
      'startOtp': startOtp,
      'bookingStatus': bookingStatus,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'createdAt': createdAt,
    };
  }
}
