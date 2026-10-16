import '../entities/subscription_activation_entity.dart';
import '../entities/subscription_plan_entity.dart';

abstract class SubscriptionRepository {
  Future<List<SubscriptionPlanEntity>> getSubscriptionPlans({String? token});

  Future<SubscriptionActivationEntity> activateSubscription({
    required String planId,
    required String paymentMethod,
    String? token,
  });
}
