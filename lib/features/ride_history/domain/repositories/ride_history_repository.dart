import '../entities/ride_history_entity.dart';

abstract class RideHistoryRepository {
  Future<List<RideHistoryEntity>> getRideHistory();
}
