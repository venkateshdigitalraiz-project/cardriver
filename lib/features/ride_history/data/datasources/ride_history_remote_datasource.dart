import '../models/ride_history_model.dart';

abstract class RideHistoryRemoteDataSource {
  Future<List<RideHistoryModel>> fetchRideHistory();
}

class RideHistoryRemoteDataSourceImpl implements RideHistoryRemoteDataSource {
  @override
  Future<List<RideHistoryModel>> fetchRideHistory() async {
    // Mocking network delay
    await Future.delayed(const Duration(seconds: 1));
    
    return [
      RideHistoryModel(
        id: '1',
        pickupLocation: 'Downtown',
        dropLocation: 'Airport',
        fare: 450.0,
        date: DateTime.now().subtract(const Duration(days: 1)),
        status: 'Completed',
      ),
      RideHistoryModel(
        id: '2',
        pickupLocation: 'City Center',
        dropLocation: 'Central Station',
        fare: 155.5,
        date: DateTime.now().subtract(const Duration(days: 2)),
        status: 'Completed',
      ),
      RideHistoryModel(
        id: '3',
        pickupLocation: 'Mall',
        dropLocation: 'Home',
        fare: 220.0,
        date: DateTime.now().subtract(const Duration(days: 3)),
        status: 'Cancelled',
      ),
    ];
  }
}
