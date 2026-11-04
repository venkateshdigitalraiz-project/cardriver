import 'package:equatable/equatable.dart';

/// Clean Architecture Entity representing a Driver-to-Driver (D-to-D) Booking.
class DtoDBookingEntity extends Equatable {
  final String id;
  final String bookingId;
  final String serviceType;
  final String tripType;
  final String bookingMode;
  final String scheduledStartTime;
  final int? durationDays;
  final int? durationHours;
  final String? returnDate;
  final String pickupAddress;
  final List<double> pickupCoordinates;
  final String dropAddress;
  final List<double> dropCoordinates;
  final String vehicleType;
  final String transmission;
  final String vehicleNumber;
  final int numberOfPassengers;
  final List<String> driverReturnOption;
  final String baseAmount;
  final String driverFee;
  final String taxAmount;
  final dynamic totalAmount;
  final String estimatedDistance;
  final String userNotes;
  final String status;
  final String message;
  final String? createdAt;
  final Map<String, dynamic>? rawData;

  const DtoDBookingEntity({
    this.id = '',
    this.bookingId = '',
    required this.serviceType,
    required this.tripType,
    this.bookingMode = 'scheduled',
    required this.scheduledStartTime,
    this.durationDays,
    this.durationHours,
    this.returnDate,
    required this.pickupAddress,
    this.pickupCoordinates = const [],
    required this.dropAddress,
    this.dropCoordinates = const [],
    this.vehicleType = '',
    this.transmission = '',
    this.vehicleNumber = '',
    this.numberOfPassengers = 4,
    this.driverReturnOption = const [],
    this.baseAmount = '',
    this.driverFee = '',
    this.taxAmount = '',
    required this.totalAmount,
    this.estimatedDistance = '',
    this.userNotes = '',
    this.status = 'confirmed',
    this.message = '',
    this.createdAt,
    this.rawData,
  });

  @override
  List<Object?> get props => [
        id,
        bookingId,
        serviceType,
        tripType,
        bookingMode,
        scheduledStartTime,
        durationDays,
        durationHours,
        returnDate,
        pickupAddress,
        pickupCoordinates,
        dropAddress,
        dropCoordinates,
        vehicleType,
        transmission,
        vehicleNumber,
        numberOfPassengers,
        driverReturnOption,
        baseAmount,
        driverFee,
        taxAmount,
        totalAmount,
        estimatedDistance,
        userNotes,
        status,
        message,
        createdAt,
      ];
}

/// Paginated list entity for D-to-D bookings
class DtoDBookingsPaginatedEntity extends Equatable {
  final List<DtoDBookingEntity> bookings;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasMore;

  const DtoDBookingsPaginatedEntity({
    this.bookings = const [],
    this.total = 0,
    this.page = 1,
    this.limit = 10,
    this.totalPages = 1,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [bookings, total, page, limit, totalPages, hasMore];
}

