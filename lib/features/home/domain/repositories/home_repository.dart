import '../entities/accepted_ride_entity.dart';
import '../entities/available_ride_entity.dart';
import '../entities/rejected_ride_entity.dart';

abstract class HomeRepository {
  Future<List<AvailableRideEntity>> getAvailableRides({String? token});
  Stream<List<AvailableRideEntity>> monitorAvailableRides({
    String? token,
    Duration interval = const Duration(seconds: 4),
  });
  Future<AcceptedRideEntity> acceptRide({
    required String rideId,
    required String token,
  });
  Future<RejectedRideEntity> rejectRide({
    required String rideId,
    required String token,
    String? reason,
  });
}
