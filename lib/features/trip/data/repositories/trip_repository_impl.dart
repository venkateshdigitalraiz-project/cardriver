import '../../domain/entities/trip_entity.dart';
import '../../domain/entities/trip_status_update_result.dart';
import '../../domain/repositories/trip_repository.dart';
import '../datasources/trip_remote_data_source.dart';

class TripRepositoryImpl implements TripRepository {
  final TripRemoteDataSource remoteDataSource;

  TripRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<TripEntity>> getDriverBookings({String? token}) async {
    return await remoteDataSource.getDriverBookings(token: token);
  }

  @override
  Future<TripEntity> getDriverBookingDetails({
    required String bookingId,
    String? token,
  }) async {
    return await remoteDataSource.getDriverBookingDetails(
      bookingId: bookingId,
      token: token,
    );
  }

  @override
  Future<TripStatusUpdateResult> updateTripStatus({
    required String bookingId,
    required String action,
    String? otp,
    double? actualDistance,
    String? token,
  }) async {
    return await remoteDataSource.updateTripStatus(
      bookingId: bookingId,
      action: action,
      otp: otp,
      actualDistance: actualDistance,
      token: token,
    );
  }
}
