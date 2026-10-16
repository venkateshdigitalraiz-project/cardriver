import '../entities/trip_entity.dart';

abstract class TripRepository {
  /// Fetches driver bookings from GET /api/driver/bookings
  Future<List<TripEntity>> getDriverBookings({String? token});

  /// Fetches single booking details from GET /api/driver/bookings/{bookingId}
  Future<TripEntity> getDriverBookingDetails({
    required String bookingId,
    String? token,
  });
}
