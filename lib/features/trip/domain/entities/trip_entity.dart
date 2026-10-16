import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import '../../../home/domain/entities/accepted_ride_entity.dart';

/// Represents a driver's booking/trip record from GET /api/driver/bookings.
class TripEntity extends Equatable {
  final String id;
  final String bookingId;
  final String userId;
  final String driverId;
  final String bookingMode;
  final String serviceType;
  final String tripType;
  final String scheduledStartTime;
  final int durationHours;
  final String pickupAddress;
  final double pickupLat;
  final double pickupLng;
  final String dropAddress;
  final double dropLat;
  final double dropLng;
  final String vehicleType;
  final String transmission;
  final String vehicleOwnership;
  final int numberOfPassengers;
  final double baseAmount;
  final double driverFee;
  final double taxAmount;
  final double totalAmount;
  final String paymentMethod;
  final String paymentStatus;
  final String bookingStatus;
  final String startOtp;
  final String createdAt;
  final String customerFirstName;
  final String customerLastName;
  final String customerPhone;
  final String customerEmail;
  final String customerAddress;
  final String custId;
  final double extraKmAmount;
  final double driverAllowance;
  final double platformFee;
  final double discountAmount;
  final String cancellationReason;
  final String userNotes;
  final String adminNotes;
  final String updatedAt;
  final String vehicleNumber;
  final bool isKmBased;
  final double distanceKm;

  const TripEntity({
    required this.id,
    this.bookingId = '',
    this.userId = '',
    this.driverId = '',
    this.bookingMode = 'scheduled',
    this.serviceType = 'local',
    this.tripType = 'round_trip',
    this.scheduledStartTime = '',
    this.durationHours = 0,
    required this.pickupAddress,
    this.pickupLat = 0.0,
    this.pickupLng = 0.0,
    required this.dropAddress,
    this.dropLat = 0.0,
    this.dropLng = 0.0,
    this.vehicleType = 'sedan',
    this.transmission = 'manual',
    this.vehicleOwnership = 'user_vehicle',
    this.numberOfPassengers = 1,
    this.baseAmount = 0.0,
    this.driverFee = 0.0,
    this.taxAmount = 0.0,
    this.totalAmount = 0.0,
    this.paymentMethod = 'online',
    this.paymentStatus = 'pending',
    this.bookingStatus = 'driver_assigned',
    this.startOtp = '',
    this.createdAt = '',
    this.customerFirstName = '',
    this.customerLastName = '',
    this.customerPhone = '',
    this.customerEmail = '',
    this.customerAddress = '',
    this.custId = '',
    this.extraKmAmount = 0.0,
    this.driverAllowance = 0.0,
    this.platformFee = 0.0,
    this.discountAmount = 0.0,
    this.cancellationReason = '',
    this.userNotes = '',
    this.adminNotes = '',
    this.updatedAt = '',
    this.vehicleNumber = '',
    this.isKmBased = false,
    this.distanceKm = 0.0,
  });

  // ================= Backwards Compatibility Getters =================

  /// Trip fare amount
  double get fare => totalAmount > 0 ? totalAmount : baseAmount;

  /// Formatted scheduled or creation date string
  String get date {
    final rawDate = scheduledStartTime.isNotEmpty ? scheduledStartTime : createdAt;
    if (rawDate.isEmpty) return 'Recent';
    try {
      final dt = DateTime.parse(rawDate).toLocal();
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
      return rawDate;
    }
  }

  /// Formatted creation date
  String get formattedCreatedAt {
    if (createdAt.isEmpty) return '';
    try {
      final dt = DateTime.parse(createdAt).toLocal();
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
      return createdAt;
    }
  }

  /// Formatted last updated date
  String get formattedUpdatedAt {
    if (updatedAt.isEmpty) return '';
    try {
      final dt = DateTime.parse(updatedAt).toLocal();
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
      return updatedAt;
    }
  }

  /// Full customer display name
  String get customerName {
    final name = '$customerFirstName $customerLastName'.trim();
    return name.isNotEmpty ? name : 'Customer';
  }

  /// Pickup address alias
  String get pickupLocation => pickupAddress;

  /// Drop address alias
  String get destination => dropAddress;

  /// High-level filter status string: 'Upcoming', 'Completed', 'Cancelled', or other
  String get status {
    final s = bookingStatus.toLowerCase();
    if (s == 'driver_assigned' || s == 'assigned' || s == 'accepted') {
      return 'Upcoming';
    }
    if (s == 'completed') {
      return 'Completed';
    }
    if (s == 'cancelled' || s == 'canceled') {
      return 'Cancelled';
    }
    if (s == 'started' || s == 'in_progress' || s == 'trip_started') {
      return 'In Progress';
    }
    return 'Upcoming';
  }

  // ================= Rich Display Getters =================

  /// Formatted total fare with currency symbol
  String get formattedTotalFare => '₹${fare.toStringAsFixed(0)}';

  /// Formatted driver fee/earnings with currency symbol
  String get formattedDriverFee => '₹${driverFee.toStringAsFixed(0)}';

  /// Human-friendly status badge label
  String get statusBadgeLabel {
    switch (bookingStatus.toLowerCase()) {
      case 'driver_assigned':
        return 'Driver Assigned';
      case 'started':
      case 'in_progress':
        return 'Trip In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return bookingStatus.replaceAll('_', ' ').toUpperCase();
    }
  }

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

  /// Converts this trip entity directly into an AcceptedRideEntity for navigation
  AcceptedRideEntity toAcceptedRideEntity() {
    return AcceptedRideEntity(
      bookingId: bookingId.isNotEmpty ? bookingId : id,
      bookingStatus: bookingStatus,
      scheduledStartTime: scheduledStartTime,
      pickupAddress: pickupAddress,
      pickupLat: pickupLat,
      pickupLng: pickupLng,
      dropAddress: dropAddress,
      dropLat: dropLat,
      dropLng: dropLng,
      totalAmount: totalAmount,
      message: 'Active trip loaded',
    );
  }

  // ================= Factory JSON Deserialization =================

  factory TripEntity.fromJson(Map<String, dynamic> json) {
    double toD(dynamic v) {
      if (v is num) return v.toDouble();
      return double.tryParse('$v') ?? 0.0;
    }

    int toI(dynamic v) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse('$v') ?? 0;
    }

    String toS(dynamic v) => v?.toString() ?? '';

    // Pickup location parsing
    final pickup = json['pickupLocation'] ?? json['pickup'] ?? const {};
    final pickupMap = pickup is Map ? pickup : const {};
    final pAddress = toS(pickupMap['address'] ?? json['pickupAddress']);

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

    // Drop location parsing
    final drop = json['dropLocation'] ?? json['drop'] ?? const {};
    final dropMap = drop is Map ? drop : const {};
    final dAddress = toS(dropMap['address'] ?? json['dropAddress']);

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

    // User details parsing
    final user = json['userDetails'] ?? const {};
    final userMap = user is Map ? user : const {};

    return TripEntity(
      id: toS(json['_id'] ?? json['id'] ?? json['bookingId']),
      bookingId: toS(json['bookingId']),
      userId: toS(json['userId']),
      driverId: toS(json['driverId']),
      bookingMode: toS(json['bookingMode'] ?? 'scheduled'),
      serviceType: toS(json['serviceType'] ?? 'local'),
      tripType: toS(json['tripType'] ?? 'round_trip'),
      scheduledStartTime: toS(json['scheduledStartTime']),
      durationHours: toI(json['durationHours']),
      pickupAddress: pAddress.isNotEmpty ? pAddress : 'Pickup Location',
      pickupLat: pLat,
      pickupLng: pLng,
      dropAddress: dAddress.isNotEmpty ? dAddress : 'Drop Location',
      dropLat: dLat,
      dropLng: dLng,
      vehicleType: toS(json['vehicleType'] ?? 'sedan'),
      transmission: toS(json['transmission'] ?? 'manual'),
      vehicleOwnership: toS(json['vehicleOwnership'] ?? 'user_vehicle'),
      numberOfPassengers: toI(json['numberOfPassengers'] ?? 1),
      baseAmount: toD(json['baseAmount']),
      driverFee: toD(json['driverFee']),
      taxAmount: toD(json['taxAmount']),
      totalAmount: toD(json['totalAmount']),
      paymentMethod: toS(json['paymentMethod'] ?? 'online'),
      paymentStatus: toS(json['paymentStatus'] ?? 'pending'),
      bookingStatus: toS(json['bookingStatus'] ?? 'driver_assigned'),
      startOtp: toS(json['startOtp']),
      createdAt: toS(json['createdAt']),
      customerFirstName: toS(userMap['firstName']),
      customerLastName: toS(userMap['lastName']),
      customerPhone: toS(userMap['phone']),
      customerEmail: toS(userMap['email']),
      customerAddress: toS(userMap['address']),
      custId: toS(userMap['custId']),
      extraKmAmount: toD(json['extraKmAmount']),
      driverAllowance: toD(json['driverAllowance']),
      platformFee: toD(json['platformFee']),
      discountAmount: toD(json['discountAmount']),
      cancellationReason: toS(json['cancellationReason']),
      userNotes: toS(json['userNotes']),
      adminNotes: toS(json['adminNotes']),
      updatedAt: toS(json['updatedAt']),
      vehicleNumber: toS(json['vehicleNumber']),
      isKmBased: json['isKmBased'] == true,
      distanceKm: toD(json['distanceKm']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        bookingId,
        userId,
        driverId,
        bookingMode,
        serviceType,
        tripType,
        scheduledStartTime,
        durationHours,
        pickupAddress,
        pickupLat,
        pickupLng,
        dropAddress,
        dropLat,
        dropLng,
        vehicleType,
        transmission,
        vehicleOwnership,
        numberOfPassengers,
        baseAmount,
        driverFee,
        taxAmount,
        totalAmount,
        paymentMethod,
        paymentStatus,
        bookingStatus,
        startOtp,
        createdAt,
        customerFirstName,
        customerLastName,
        customerPhone,
        customerEmail,
        customerAddress,
        custId,
        extraKmAmount,
        driverAllowance,
        platformFee,
        discountAmount,
        cancellationReason,
        userNotes,
        adminNotes,
        updatedAt,
        vehicleNumber,
        isKmBased,
        distanceKm,
      ];
}
