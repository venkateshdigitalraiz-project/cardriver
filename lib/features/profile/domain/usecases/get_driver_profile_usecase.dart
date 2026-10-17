import 'package:equatable/equatable.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/driver_profile_entity.dart';
import '../repositories/profile_repository.dart';

class GetDriverProfileParams extends Equatable {
  final String? token;

  const GetDriverProfileParams({this.token});

  @override
  List<Object?> get props => [token];
}

class GetDriverProfileUseCase
    implements UseCase<DriverProfileEntity, GetDriverProfileParams> {
  final ProfileRepository repository;

  GetDriverProfileUseCase(this.repository);

  @override
  Future<DriverProfileEntity> call(GetDriverProfileParams params) async {
    return await repository.getDriverProfile(token: params.token);
  }
}
