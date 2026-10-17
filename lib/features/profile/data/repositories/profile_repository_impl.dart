import '../../domain/entities/driver_profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<DriverProfileEntity> getDriverProfile({String? token}) async {
    return await remoteDataSource.getDriverProfile(token: token);
  }
}
