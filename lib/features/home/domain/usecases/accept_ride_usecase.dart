import 'package:equatable/equatable.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/accepted_ride_entity.dart';
import '../repositories/home_repository.dart';

class AcceptRideParams extends Equatable {
  final String rideId;
  final String token;

  const AcceptRideParams({
    required this.rideId,
    required this.token,
  });

  @override
  List<Object?> get props => [rideId, token];
}

class AcceptRideUseCase implements UseCase<AcceptedRideEntity, AcceptRideParams> {
  final HomeRepository repository;

  AcceptRideUseCase(this.repository);

  @override
  Future<AcceptedRideEntity> call(AcceptRideParams params) async {
    return await repository.acceptRide(
      rideId: params.rideId,
      token: params.token,
    );
  }
}
