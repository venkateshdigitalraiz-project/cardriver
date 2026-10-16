import '../../domain/entities/subscription_history_response_entity.dart';
import '../../domain/repositories/subscription_history_repository.dart';
import '../datasources/subscription_history_remote_data_source.dart';

class SubscriptionHistoryRepositoryImpl
    implements SubscriptionHistoryRepository {
  final SubscriptionHistoryRemoteDataSource remoteDataSource;

  SubscriptionHistoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<SubscriptionHistoryResponseEntity> getSubscriptionHistory({
    String? token,
  }) async {
    return await remoteDataSource.getSubscriptionHistory(token: token);
  }
}
