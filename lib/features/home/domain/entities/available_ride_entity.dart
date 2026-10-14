import 'package:equatable/equatable.dart';

class AvailableRideEntity extends Equatable {
  final String id;
  final String bookingId;
  final String riderName;
  final String riderPhone;
  final String riderCustId;
  final String pickupAddress;
  final double pickupLat;
  final double pickupLng;
  final String dropAddress;
  final double dropLat;
  final double dropLng;
  final double totalAmount;
  final double driverFee;
  final String serviceType;
  final String tripType;
  final String vehicleType;
  final int durationHours;
  final double distanceKm;
  final String scheduledStartTime;
  final String startOtp;
  final String bookingStatus;
  final String paymentMethod;
  final String paymentStatus;
  final String createdAt;

  const AvailableRideEntity({
    required this.id,
    required this.bookingId,
    required this.riderName,
    required this.riderPhone,
    required this.riderCustId,
    required this.pickupAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.dropAddress,
    required this.dropLat,
    required this.dropLng,
    required this.totalAmount,
    required this.driverFee,
    required this.serviceType,
    required this.tripType,
    required this.vehicleType,
    required this.durationHours,
    required this.distanceKm,
    required this.scheduledStartTime,
    required this.startOtp,
    required this.bookingStatus,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.createdAt,
  });

  String get formattedFare => '₹${totalAmount.toStringAsFixed(0)}';
  String get formattedDriverFee => '₹${driverFee.toStringAsFixed(0)}';

  @override
  List<Object?> get props => [
        id,
        bookingId,
        riderName,
        riderPhone,
        riderCustId,
        pickupAddress,
        pickupLat,
        pickupLng,
        dropAddress,
        dropLat,
        dropLng,
        totalAmount,
        driverFee,
        serviceType,
        tripType,
        vehicleType,
        durationHours,
        distanceKm,
        scheduledStartTime,
        startOtp,
        bookingStatus,
        paymentMethod,
        paymentStatus,
        createdAt,
      ];
}
