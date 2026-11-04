import '../entities/d_to_d_booking_entity.dart';
import '../repositories/home_repository.dart';

/// Clean Architecture Use Case to fetch paginated Driver-to-Driver bookings.
/// GET /api/driver/d-to-d-bookings?page=1&limit=10
class GetDtoDBookingsUseCase {
  final HomeRepository repository;

  const GetDtoDBookingsUseCase(this.repository);

  Future<DtoDBookingsPaginatedEntity> call({
    int page = 1,
    int limit = 10,
    String? token,
    String? status,
    String? serviceType,
    String? tripType,
    int? durationDays,
    int? durationHours,
  }) {
    return repository.getDtoDBookings(
      page: page,
      limit: limit,
      token: token,
      status: status,
      serviceType: serviceType,
      tripType: tripType,
      durationDays: durationDays,
      durationHours: durationHours,
    );
  }
}

