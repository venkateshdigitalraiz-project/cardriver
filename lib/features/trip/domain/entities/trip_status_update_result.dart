import 'package:equatable/equatable.dart';

/// Entity representing the response from POST /api/driver/bookings/trip-status
class TripStatusUpdateResult extends Equatable {
  final bool success;
  final String message;
  final String bookingId;
  final String bookingStatus;
  final String? tripStartedAt;
  final String? tripCompletedAt;
  final double? actualDistance;
  final double? totalAmount;

  const TripStatusUpdateResult({
    required this.success,
    required this.message,
    required this.bookingId,
    required this.bookingStatus,
    this.tripStartedAt,
    this.tripCompletedAt,
    this.actualDistance,
    this.totalAmount,
  });

  factory TripStatusUpdateResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map ? json['data'] as Map : {};

    double? toD(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse('$v');
    }

    return TripStatusUpdateResult(
      success: json['success'] == true,
      message: json['message']?.toString() ?? 'Status updated successfully',
      bookingId: (data['bookingId'] ?? json['bookingId'] ?? '').toString(),
      bookingStatus:
          (data['bookingStatus'] ?? json['bookingStatus'] ?? '').toString(),
      tripStartedAt: data['tripStartedAt']?.toString(),
      tripCompletedAt: data['tripCompletedAt']?.toString(),
      actualDistance: toD(data['actualDistance']),
      totalAmount: toD(data['totalAmount']),
    );
  }

  @override
  List<Object?> get props => [
        success,
        message,
        bookingId,
        bookingStatus,
        tripStartedAt,
        tripCompletedAt,
        actualDistance,
        totalAmount,
      ];
}

