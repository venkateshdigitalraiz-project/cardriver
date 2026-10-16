import '../../domain/entities/trip_entity.dart';
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
}
