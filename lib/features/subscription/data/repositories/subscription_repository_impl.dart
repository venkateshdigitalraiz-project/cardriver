import '../../domain/entities/subscription_activation_entity.dart';
import '../../domain/entities/subscription_plan_entity.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_remote_data_source.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionRemoteDataSource remoteDataSource;

  SubscriptionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<SubscriptionPlanEntity>> getSubscriptionPlans({
    String? token,
  }) async {
    return await remoteDataSource.getSubscriptionPlans(token: token);
  }

  @override
  Future<SubscriptionActivationEntity> activateSubscription({
    required String planId,
    required String paymentMethod,
    String? token,
  }) async {
    return await remoteDataSource.activateSubscription(
      planId: planId,
      paymentMethod: paymentMethod,
      token: token,
    );
  }
}
