import 'package:equatable/equatable.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/trip_entity.dart';
import '../repositories/trip_repository.dart';

class GetDriverBookingDetailsParams extends Equatable {
  final String bookingId;
  final String? token;

  const GetDriverBookingDetailsParams({
    required this.bookingId,
    this.token,
  });

  @override
  List<Object?> get props => [bookingId, token];
}

class GetDriverBookingDetailsUseCase
    implements UseCase<TripEntity, GetDriverBookingDetailsParams> {
  final TripRepository repository;

  GetDriverBookingDetailsUseCase(this.repository);

  @override
  Future<TripEntity> call(GetDriverBookingDetailsParams params) async {
    return await repository.getDriverBookingDetails(
      bookingId: params.bookingId,
      token: params.token,
    );
  }
}
