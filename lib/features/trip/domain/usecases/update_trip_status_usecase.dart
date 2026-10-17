import 'package:equatable/equatable.dart';
import '../entities/trip_status_update_result.dart';
import '../repositories/trip_repository.dart';

class UpdateTripStatusUseCase {
  final TripRepository repository;

  UpdateTripStatusUseCase(this.repository);

  Future<TripStatusUpdateResult> call(UpdateTripStatusParams params) async {
    return await repository.updateTripStatus(
      bookingId: params.bookingId,
      action: params.action,
      otp: params.otp,
      actualDistance: params.actualDistance,
      token: params.token,
    );
  }
}

class UpdateTripStatusParams extends Equatable {
  final String bookingId;
  final String action;
  final String? otp;
  final double? actualDistance;
  final String? token;

  const UpdateTripStatusParams({
    required this.bookingId,
    required this.action,
    this.otp,
    this.actualDistance,
    this.token,
  });

  @override
  List<Object?> get props => [bookingId, action, otp, actualDistance, token];
}
