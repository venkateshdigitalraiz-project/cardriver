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
  final String returnDate;
  final String bookingMode;
  final int durationDays;
  final String bookingStatus;
  final String paymentStatus;
  final String createdAt;

  // D2D and User details support
  final bool isDriverToDriver;
  final Map<String, dynamic>? sourceDriverDetails;
  final Map<String, dynamic>? userDetails;
  final String transmission;
  final List<String> driverReturnOption;

  const AvailableRideEntity({
    required this.id,
    required this.bookingId,
    required this.riderName,
    required this.riderPhone,
    required this.vehicleType,
    required this.serviceType,
    required this.tripType,
    required this.durationHours,
    this.durationDays = 0,
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
    this.returnDate = '',
    this.bookingMode = '',
    this.bookingStatus = 'pending',
    this.paymentStatus = 'pending',
    this.createdAt = '',
    this.isDriverToDriver = false,
    this.sourceDriverDetails,
    this.userDetails,
    this.transmission = '',
    this.driverReturnOption = const [],
  });

  /// Formatted total fare with rupee symbol and 0 decimal places.
  String get formattedFare => '₹${fare.toStringAsFixed(0)}';

  /// Formatted driver fee with rupee symbol and 0 decimal places.
  String get formattedDriverFee => '₹${driverFee.toStringAsFixed(0)}';

  /// Formatted scheduled time string (e.g. "17 Oct 2026, 11:05 AM")
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
      return '${dt.day} $month ${dt.year}, $hour:$minute $period';
    } catch (_) {
      return scheduledStartTime;
    }
  }

  /// Formatted return date for round trips (e.g. "19 Oct 2026, 11:05 AM")
  String get formattedReturnDate {
    if (returnDate.isEmpty) return '';
    try {
      final dt = DateTime.parse(returnDate).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      final month = months[dt.month - 1];
      final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      final minute = dt.minute.toString().padLeft(2, '0');
      return '${dt.day} $month ${dt.year}, $hour:$minute $period';
    } catch (_) {
      return returnDate;
    }
  }

  /// Formatted duration display based on serviceType:
  /// Condition 1: "serviceType": "outstation" -> display "Duration: X days"
  /// Condition 2: "serviceType": "local" -> display "Duration: X hours"
  String get durationDisplay {
    final sType = serviceType.trim().toLowerCase();
    if (sType == 'outstation') {
      final days = durationDays > 0
          ? durationDays
          : (durationHours > 0 ? (durationHours / 24).ceil() : 1);
      return 'Duration: $days days';
    } else {
      final hours = durationHours > 0
          ? durationHours
          : (durationDays > 0 ? durationDays * 24 : 1);
      return 'Duration: $hours hours';
    }
  }

  /// Alias for durationDisplay
  String get formattedDuration => durationDisplay;

  /// Alias for fare
  double get totalAmount => fare;

  /// Safely extracts source driver name from sourceDriverDetails
  String get sourceDriverName {
    if (sourceDriverDetails != null) {
      final f = sourceDriverDetails!['firstName']?.toString();
      final l = sourceDriverDetails!['lastName']?.toString();
      if (f != null && f.trim().isNotEmpty) {
        return '$f ${l ?? ''}'.trim();
      }
      final name = sourceDriverDetails!['name']?.toString() ??
          sourceDriverDetails!['fullName']?.toString();
      if (name != null && name.trim().isNotEmpty) {
        return name.trim();
      }
    }
    return riderName.isNotEmpty ? riderName : 'Partner Driver';
  }

  /// Safely extracts source driver ID from sourceDriverDetails
  String get sourceDriverId {
    if (sourceDriverDetails != null) {
      final id = sourceDriverDetails!['driverId']?.toString() ??
          sourceDriverDetails!['displayDriverId']?.toString() ??
          sourceDriverDetails!['driver_id']?.toString() ??
          sourceDriverDetails!['id']?.toString() ??
          sourceDriverDetails!['_id']?.toString();
      if (id != null && id.trim().isNotEmpty) {
        return id.trim();
      }
    }
    return '';
  }

  /// Safely extracts source driver phone from sourceDriverDetails
  String get sourceDriverPhone {
    if (sourceDriverDetails != null) {
      final phone = sourceDriverDetails!['phone']?.toString() ??
          sourceDriverDetails!['phoneNumber']?.toString() ??
          sourceDriverDetails!['mobileNumber']?.toString() ??
          sourceDriverDetails!['mobile']?.toString();
      if (phone != null && phone.trim().isNotEmpty) {
        return phone.trim();
      }
    }
    return riderPhone;
  }

  /// Safely extracts customer name from userDetails
  String get customerName {
    if (userDetails != null) {
      final f = userDetails!['firstName']?.toString();
      final l = userDetails!['lastName']?.toString();
      if (f != null && f.trim().isNotEmpty) {
        return '$f ${l ?? ''}'.trim();
      }
      final name = userDetails!['name']?.toString() ??
          userDetails!['fullName']?.toString();
      if (name != null && name.trim().isNotEmpty) {
        return name.trim();
      }
    }
    return riderName.isNotEmpty ? riderName : 'Customer';
  }

  /// Safely extracts customer phone from userDetails
  String get customerPhone {
    if (userDetails != null) {
      final phone = userDetails!['phone']?.toString() ??
          userDetails!['phoneNumber']?.toString() ??
          userDetails!['mobileNumber']?.toString() ??
          userDetails!['mobile']?.toString();
      if (phone != null && phone.trim().isNotEmpty) {
        return phone.trim();
      }
    }
    return riderPhone;
  }

  /// Formatted return options for D-to-D bookings (e.g. "Bus • Train")
  String get formattedReturnOptions {
    if (driverReturnOption.isEmpty) return '';
    return driverReturnOption.map((opt) {
      final cleaned = opt.toLowerCase().replaceAll('ret-', '').replaceAll('_', ' ').trim();
      if (cleaned == 'bus') return 'Bus';
      if (cleaned == 'train') return 'Train';
      if (cleaned == 'flight') return 'Flight';
      if (cleaned == 'cab') return 'Cab';
      if (cleaned == 'rapido') return 'Rapido';
      if (cleaned.contains('food') || cleaned.contains('room')) return 'Food & Room';
      return opt.replaceAll('ret-', '').toUpperCase();
    }).join(' • ');
  }

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
    final durationDays = toI(
      json['durationDays'] ??
          json['duration_days'] ??
          json['days'] ??
          0,
    );
    final durationHours = toI(
      json['durationHours'] ??
          json['duration_hours'] ??
          json['duration'] ??
          json['estimatedDuration'] ??
          (durationDays > 0 ? durationDays * 24 : 1),
    );
    final fare = toD(
      json['fare'] ??
          json['totalAmount'] ??
          json['total_amount'] ??
          json['totalPrice'] ??
          json['total_price'] ??
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

    // D2D and User details parsing
    final rawSourceDriver = json['sourceDriverDetails'] ??
        json['sourceDriver'] ??
        json['driverDetails'];
    final Map<String, dynamic>? sourceDriverDetails = rawSourceDriver is Map
        ? Map<String, dynamic>.from(rawSourceDriver)
        : null;

    final rawUserDetails = json['userDetails'] ??
        json['user'] ??
        json['customer'] ??
        json['rider'];
    final Map<String, dynamic>? userDetails = rawUserDetails is Map
        ? Map<String, dynamic>.from(rawUserDetails)
        : null;

    // Determine whether this is a Driver-to-Driver (D2D) or User-to-Driver booking:
    // If "isDriverToDriver" is false (or bookingType == "user"), it is a User-to-Driver booking.
    // If "isDriverToDriver" is true (or bookingType == "driver_to_driver" / "d_to_d" / "d2d"), it is D2D.
    bool isD2D = false;
    final rawIsD2D = json['isDriverToDriver'] ??
        json['is_driver_to_driver'] ??
        json['isDriver2Driver'];
    final bookingType = toS(json['bookingType']).trim().toLowerCase();

    if (rawIsD2D != null) {
      isD2D = rawIsD2D == true || rawIsD2D.toString().toLowerCase() == 'true';
    } else if (bookingType == 'user') {
      isD2D = false;
    } else if (bookingType == 'driver_to_driver' ||
        bookingType == 'd_to_d' ||
        bookingType == 'd2d' ||
        bookingType == 'driver') {
      isD2D = true;
    } else if (sourceDriverDetails != null &&
        sourceDriverDetails.isNotEmpty &&
        (sourceDriverDetails['name'] != null ||
            sourceDriverDetails['phone'] != null ||
            sourceDriverDetails['driverId'] != null)) {
      isD2D = true;
    }

    final transmission = toS(
      json['transmission'] ??
          json['gearType'] ??
          json['transmissionType'] ??
          '',
    );

    List<String> driverReturnOption = [];
    final rawRetOpt = json['driverReturnOption'] ??
        json['returnOptions'] ??
        json['driver_return_option'];
    if (rawRetOpt is List) {
      driverReturnOption = rawRetOpt.map((e) => e.toString()).toList();
    } else if (rawRetOpt is String && rawRetOpt.trim().isNotEmpty) {
      driverReturnOption = [rawRetOpt.trim()];
    }

    return AvailableRideEntity(
      id: id,
      bookingId: bookingId,
      riderName: riderName,
      riderPhone: riderPhone,
      vehicleType: vehicleType,
      serviceType: serviceType,
      tripType: tripType,
      durationHours: durationHours,
      durationDays: durationDays,
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
      scheduledStartTime: toS(
        json['scheduledStartTime'] ??
            json['scheduled_start_time'] ??
            json['startTime'] ??
            '',
      ),
      returnDate: toS(json['returnDate'] ?? json['return_date'] ?? ''),
      bookingMode: toS(json['bookingMode'] ?? json['booking_mode'] ?? ''),
      bookingStatus: toS(json['bookingStatus'] ?? 'pending'),
      paymentStatus: toS(json['paymentStatus'] ?? 'pending'),
      createdAt: toS(json['createdAt']),
      isDriverToDriver: isD2D,
      sourceDriverDetails: sourceDriverDetails,
      userDetails: userDetails,
      transmission: transmission,
      driverReturnOption: driverReturnOption,
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
        durationDays,
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
        returnDate,
        bookingMode,
        bookingStatus,
        paymentStatus,
        createdAt,
        isDriverToDriver,
        sourceDriverDetails,
        userDetails,
        transmission,
        driverReturnOption,
      ];
}
