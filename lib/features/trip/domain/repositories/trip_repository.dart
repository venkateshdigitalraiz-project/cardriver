import '../entities/trip_entity.dart';
import '../entities/trip_status_update_result.dart';

abstract class TripRepository {
  /// Fetches driver bookings from GET /api/driver/bookings
  Future<List<TripEntity>> getDriverBookings({String? token});

  /// Fetches single booking details from GET /api/driver/bookings/{bookingId}
  Future<TripEntity> getDriverBookingDetails({
    required String bookingId,
    String? token,
  });

  /// Updates booking trip status via POST /api/driver/bookings/trip-status
  Future<TripStatusUpdateResult> updateTripStatus({
    required String bookingId,
    required String action,
    String? otp,
    double? actualDistance,
    String? token,
  });
}

