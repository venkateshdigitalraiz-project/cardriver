import '../entities/ride_history_entity.dart';
import '../repositories/ride_history_repository.dart';

class GetRideHistoryUseCase {
  final RideHistoryRepository repository;

  GetRideHistoryUseCase(this.repository);

  Future<List<RideHistoryEntity>> call() async {
    return await repository.getRideHistory();
  }
}
