import '../entities/available_ride_entity.dart';

abstract class HomeRepository {
  Future<List<AvailableRideEntity>> getAvailableRides({String? token});
  Stream<List<AvailableRideEntity>> monitorAvailableRides({
    String? token,
    Duration interval = const Duration(seconds: 4),
  });
}
