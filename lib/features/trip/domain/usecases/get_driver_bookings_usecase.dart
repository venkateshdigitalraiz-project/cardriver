import 'package:equatable/equatable.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/trip_entity.dart';
import '../repositories/trip_repository.dart';

class GetDriverBookingsParams extends Equatable {
  final String? token;

  const GetDriverBookingsParams({this.token});

  @override
  List<Object?> get props => [token];
}

class GetDriverBookingsUseCase
    implements UseCase<List<TripEntity>, GetDriverBookingsParams> {
  final TripRepository repository;

  GetDriverBookingsUseCase(this.repository);

  @override
  Future<List<TripEntity>> call(GetDriverBookingsParams params) async {
    return await repository.getDriverBookings(token: params.token);
  }
}
