import '../../data/models/d_to_d_booking_model.dart';
import '../entities/d_to_d_booking_entity.dart';
import '../repositories/home_repository.dart';

/// Clean Architecture Use Case to initiate and create a Driver-to-Driver booking.
class CreateDtoDBookingUseCase {
  final HomeRepository repository;

  const CreateDtoDBookingUseCase(this.repository);

  Future<DtoDBookingEntity> call({
    required DtoDBookingRequestModel request,
    String? token,
  }) {
    return repository.createDtoDBooking(
      request: request,
      token: token,
    );
  }
}

