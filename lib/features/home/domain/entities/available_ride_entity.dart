import 'package:equatable/equatable.dart';

/// Represents an available ride request dispatched to the driver.
class AvailableRideEntity extends Equatable {
  final String id;
  final String bookingId;
  final String riderName;
  final String riderPhone;
  final String vehicleType;
  final String serviceType;
  final String tripType;
  final int durationHours;
  final double fare;
  final double driverFee;
  final String paymentMethod;
  final String pickupAddress;
  final String dropAddress;
  final double pickupLat;
  final double pickupLng;
  final double dropLat;
  final double dropLng;
  final String startOtp;

  // Legacy/extended fields for model compatibility
  final String riderCustId;
  final double distanceKm;
  final String scheduledStartTime;
  final String bookingStatus;
  final String paymentStatus;
  final String createdAt;

  const AvailableRideEntity({
    required this.id,
    required this.bookingId,
    required this.riderName,
    required this.riderPhone,
    required this.vehicleType,
    required this.serviceType,
    required this.tripType,
    required this.durationHours,
    required this.fare,
    required this.driverFee,
    required this.paymentMethod,
    required this.pickupAddress,
    required this.dropAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropLat,
    required this.dropLng,
    required this.startOtp,
    this.riderCustId = '',
    this.distanceKm = 0.0,
    this.scheduledStartTime = '',
    this.bookingStatus = 'pending',
    this.paymentStatus = 'pending',
    this.createdAt = '',
  });

  /// Formatted total fare with rupee symbol and 0 decimal places.
  String get formattedFare => '₹${fare.toStringAsFixed(0)}';

  /// Formatted driver fee with rupee symbol and 0 decimal places.
  String get formattedDriverFee => '₹${driverFee.toStringAsFixed(0)}';

  /// Alias for fare
  double get totalAmount => fare;

  /// Tolerant factory constructor that handles multiple backend schemas and never throws on missing keys.
  factory AvailableRideEntity.fromJson(Map<String, dynamic> json) {
    double toD(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse('$v') ?? 0.0;
    int toI(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
    String toS(dynamic v) => v?.toString() ?? '';

    // Handle nested rider / customer / user
    final rider = json['rider'] ?? json['customer'] ?? json['user'] ?? json['userDetails'] ?? json['passenger'];
    final riderMap = rider is Map ? rider : const {};

    // Handle nested pickup location
    final pickup = json['pickup'] ?? json['pickupLocation'] ?? json['origin'];
    final pickupMap = pickup is Map ? pickup : const {};

    // Handle nested drop / destination location
    final drop = json['drop'] ?? json['dropLocation'] ?? json['destination'];
    final dropMap = drop is Map ? drop : const {};

    final id = toS(
      json['_id'] ??
          json['id'] ??
          json['bookingId'] ??
          json['booking_id'] ??
          json['rideId'] ??
          json['ride_id'],
    );
    final bookingId = toS(
      json['bookingId'] ??
          json['booking_id'] ??
          json['rideId'] ??
          json['ride_id'] ??
          id,
    );
    final riderName = toS(
      json['riderName'] ??
          json['customerName'] ??
          json['passengerName'] ??
          json['userName'] ??
          riderMap['name'] ??
          riderMap['fullName'] ??
          (riderMap['firstName'] != null
              ? '${riderMap['firstName']} ${riderMap['lastName'] ?? ''}'.trim()
              : 'Passenger'),
    );
    final riderPhone = toS(
      json['riderPhone'] ??
          json['customerPhone'] ??
          json['phone'] ??
          riderMap['phone'] ??
          riderMap['mobileNumber'] ??
          '',
    );
    final vehicleType = toS(
      json['vehicleType'] ?? json['carType'] ?? 'Sedan',
    );
    final serviceType = toS(
      json['serviceType'] ?? json['type'] ?? 'ride',
    );
    final tripType = toS(
      json['tripType'] ?? 'one_way',
    );
    final durationHours = toI(
      json['durationHours'] ?? json['duration'] ?? json['estimatedDuration'] ?? 1,
    );
    final fare = toD(
      json['fare'] ??
          json['totalAmount'] ??
          json['estimatedFare'] ??
          json['totalFare'] ??
          json['amount'] ??
          json['price'],
    );
    final driverFee = toD(
      json['driverFee'] ??
          json['driver_fee'] ??
          json['driverEarnings'] ??
          (fare * 0.8),
    );
    final paymentMethod = toS(
      json['paymentMethod'] ?? json['payment_method'] ?? 'cash',
    );
    final pickupAddress = toS(
      json['pickupAddress'] ??
          pickupMap['address'] ??
          pickupMap['formattedAddress'] ??
          'Pickup Location',
    );
    final dropAddress = toS(
      json['dropAddress'] ??
          dropMap['address'] ??
          dropMap['formattedAddress'] ??
          'Drop Location',
    );
    final pickupLat = toD(
      json['pickupLat'] ?? pickupMap['lat'] ?? pickupMap['latitude'] ??
          (pickupMap['location'] is Map && pickupMap['location']['coordinates'] is List && (pickupMap['location']['coordinates'] as List).length >= 2
              ? pickupMap['location']['coordinates'][1]
              : null),
    );
    final pickupLng = toD(
      json['pickupLng'] ?? pickupMap['lng'] ?? pickupMap['longitude'] ??
          (pickupMap['location'] is Map && pickupMap['location']['coordinates'] is List && (pickupMap['location']['coordinates'] as List).length >= 2
              ? pickupMap['location']['coordinates'][0]
              : null),
    );
    final dropLat = toD(
      json['dropLat'] ?? dropMap['lat'] ?? dropMap['latitude'] ??
          (dropMap['location'] is Map && dropMap['location']['coordinates'] is List && (dropMap['location']['coordinates'] as List).length >= 2
              ? dropMap['location']['coordinates'][1]
              : null),
    );
    final dropLng = toD(
      json['dropLng'] ?? dropMap['lng'] ?? dropMap['longitude'] ??
          (dropMap['location'] is Map && dropMap['location']['coordinates'] is List && (dropMap['location']['coordinates'] as List).length >= 2
              ? dropMap['location']['coordinates'][0]
              : null),
    );
    final startOtp = toS(
      json['startOtp'] ?? json['otp'] ?? '',
    );

    return AvailableRideEntity(
      id: id,
      bookingId: bookingId,
      riderName: riderName,
      riderPhone: riderPhone,
      vehicleType: vehicleType,
      serviceType: serviceType,
      tripType: tripType,
      durationHours: durationHours,
      fare: fare,
      driverFee: driverFee,
      paymentMethod: paymentMethod,
      pickupAddress: pickupAddress,
      dropAddress: dropAddress,
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      dropLat: dropLat,
      dropLng: dropLng,
      startOtp: startOtp,
      riderCustId: toS(riderMap['custId'] ?? json['riderCustId']),
      distanceKm: toD(json['distanceKm']),
      scheduledStartTime: toS(json['scheduledStartTime']),
      bookingStatus: toS(json['bookingStatus'] ?? 'pending'),
      paymentStatus: toS(json['paymentStatus'] ?? 'pending'),
      createdAt: toS(json['createdAt']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        bookingId,
        riderName,
        riderPhone,
        vehicleType,
        serviceType,
        tripType,
        durationHours,
        fare,
        driverFee,
        paymentMethod,
        pickupAddress,
        dropAddress,
        pickupLat,
        pickupLng,
        dropLat,
        dropLng,
        startOtp,
        riderCustId,
        distanceKm,
        scheduledStartTime,
        bookingStatus,
        paymentStatus,
        createdAt,
      ];
}
