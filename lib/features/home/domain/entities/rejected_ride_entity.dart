import 'package:equatable/equatable.dart';

/// Represents the response returned after a driver successfully declines/rejects a ride.
class RejectedRideEntity extends Equatable {
  final String bookingId;
  final String bookingStatus;
  final String rejectedByDriverId;
  final String reason;
  final String message;

  const RejectedRideEntity({
    required this.bookingId,
    required this.bookingStatus,
    required this.rejectedByDriverId,
    required this.reason,
    this.message = 'Ride rejected successfully.',
  });

  /// Formatted indicator message: e.g. "BKG-859805: Driver declined the ride"
  String get toastMessage {
    if (bookingId.isNotEmpty && reason.isNotEmpty) {
      return '$bookingId: $reason';
    } else if (bookingId.isNotEmpty) {
      return '$bookingId: $message';
    } else {
      return reason.isNotEmpty ? reason : message;
    }
  }

  factory RejectedRideEntity.fromJson(
    Map<String, dynamic> json, {
    String? defaultMessage,
  }) {
    final dynamic data = json['data'];
    final Map<String, dynamic> map =
        (data is Map) ? Map<String, dynamic>.from(data) : json;

    return RejectedRideEntity(
      bookingId: (map['bookingId'] ?? map['_id'] ?? '').toString(),
      bookingStatus: (map['bookingStatus'] ?? 'rejected').toString(),
      rejectedByDriverId:
          (map['rejectedByDriverId'] ?? map['driverId'] ?? '').toString(),
      reason: (map['reason'] ?? 'Driver declined the ride').toString(),
      message: (json['message'] ??
              defaultMessage ??
              'Ride rejected successfully.')
          .toString(),
    );
  }

  @override
  List<Object?> get props => [
        bookingId,
        bookingStatus,
        rejectedByDriverId,
        reason,
        message,
      ];
}
