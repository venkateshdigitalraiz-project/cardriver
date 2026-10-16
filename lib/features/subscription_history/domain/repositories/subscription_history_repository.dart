import '../entities/subscription_history_response_entity.dart';

abstract class SubscriptionHistoryRepository {
  Future<SubscriptionHistoryResponseEntity> getSubscriptionHistory({
    String? token,
  });
}
