import '../entities/driver_profile_entity.dart';

abstract class ProfileRepository {
  Future<DriverProfileEntity> getDriverProfile({String? token});
}
