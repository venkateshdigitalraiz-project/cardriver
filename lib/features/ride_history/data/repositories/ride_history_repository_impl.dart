import '../../domain/entities/ride_history_entity.dart';
import '../../domain/repositories/ride_history_repository.dart';
import '../datasources/ride_history_remote_datasource.dart';

class RideHistoryRepositoryImpl implements RideHistoryRepository {
  final RideHistoryRemoteDataSource remoteDataSource;

  RideHistoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<RideHistoryEntity>> getRideHistory() async {
    return await remoteDataSource.fetchRideHistory();
  }
}
