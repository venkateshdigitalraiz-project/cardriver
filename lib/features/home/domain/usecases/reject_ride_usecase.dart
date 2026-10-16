import 'package:equatable/equatable.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/rejected_ride_entity.dart';
import '../repositories/home_repository.dart';

class RejectRideParams extends Equatable {
  final String rideId;
  final String token;
  final String? reason;

  const RejectRideParams({
    required this.rideId,
    required this.token,
    this.reason,
  });

  @override
  List<Object?> get props => [rideId, token, reason];
}

class RejectRideUseCase
    implements UseCase<RejectedRideEntity, RejectRideParams> {
  final HomeRepository repository;

  RejectRideUseCase(this.repository);

  @override
  Future<RejectedRideEntity> call(RejectRideParams params) async {
    return await repository.rejectRide(
      rideId: params.rideId,
      token: params.token,
      reason: params.reason,
    );
  }
}
