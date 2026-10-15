import 'package:equatable/equatable.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/available_ride_entity.dart';
import '../repositories/home_repository.dart';

class GetAvailableRidesParams extends Equatable {
  final String? token;

  const GetAvailableRidesParams({this.token});

  @override
  List<Object?> get props => [token];
}

class GetAvailableRidesUseCase
    implements UseCase<List<AvailableRideEntity>, GetAvailableRidesParams> {
  final HomeRepository repository;

  GetAvailableRidesUseCase(this.repository);

  @override
  Future<List<AvailableRideEntity>> call(GetAvailableRidesParams params) async {
    return await repository.getAvailableRides(token: params.token);
  }

  Stream<List<AvailableRideEntity>> monitor(
    GetAvailableRidesParams params, {
    Duration interval = const Duration(seconds: 4),
  }) {
    return repository.monitorAvailableRides(
      token: params.token,
      interval: interval,
    );
  }
}
