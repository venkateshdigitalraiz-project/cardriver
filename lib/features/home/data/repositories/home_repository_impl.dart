import 'dart:async';
import '../../domain/entities/accepted_ride_entity.dart';
import '../../domain/entities/available_ride_entity.dart';
import '../../domain/entities/rejected_ride_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  Future<List<AvailableRideEntity>>? _inFlightRequest;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<AvailableRideEntity>> getAvailableRides({String? token}) async {
    // If a request is already in progress, reuse the same future to prevent duplicate hits
    if (_inFlightRequest != null) {
      return await _inFlightRequest!;
    }

    _inFlightRequest = remoteDataSource.getAvailableRides(token: token);
    try {
      final rides = await _inFlightRequest!;
      return rides;
    } finally {
      _inFlightRequest = null;
    }
  }

  @override
  Future<AcceptedRideEntity> acceptRide({
    required String rideId,
    required String token,
  }) async {
    return await remoteDataSource.acceptRide(
      rideId: rideId,
      token: token,
    );
  }

  @override
  Future<RejectedRideEntity> rejectRide({
    required String rideId,
    required String token,
    String? reason,
  }) async {
    return await remoteDataSource.rejectRide(
      rideId: rideId,
      token: token,
      reason: reason,
    );
  }

  @override
  Stream<List<AvailableRideEntity>> monitorAvailableRides({
    String? token,
    Duration interval = const Duration(seconds: 4),
  }) async* {
    // Fetch once when monitoring starts — do not repeatedly poll in an infinite loop
    try {
      final rides = await getAvailableRides(token: token);
      yield rides;
    } catch (_) {
      yield <AvailableRideEntity>[];
    }
  }
}

