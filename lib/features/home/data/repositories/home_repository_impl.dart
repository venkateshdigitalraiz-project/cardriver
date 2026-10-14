import 'dart:async';
import '../../domain/entities/available_ride_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<AvailableRideEntity>> getAvailableRides({String? token}) async {
    return await remoteDataSource.getAvailableRides(token: token);
  }

  @override
  Stream<List<AvailableRideEntity>> monitorAvailableRides({
    String? token,
    Duration interval = const Duration(seconds: 4),
  }) async* {
    // Immediate initial fetch
    try {
      final initialRides = await remoteDataSource.getAvailableRides(token: token);
      yield initialRides;
    } catch (_) {
      // Continue to periodic monitoring even if initial fetch failed
    }

    // Continuous real-time monitoring loop (Rapid Capital style socket-like stream)
    while (true) {
      await Future.delayed(interval);
      try {
        final rides = await remoteDataSource.getAvailableRides(token: token);
        yield rides;
      } catch (e) {
        // Yield empty or silently wait for next tick to avoid disconnecting stream
      }
    }
  }
}
