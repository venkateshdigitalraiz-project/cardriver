import 'package:equatable/equatable.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/subscription_activation_entity.dart';
import '../repositories/subscription_repository.dart';

class ActivateSubscriptionParams extends Equatable {
  final String planId;
  final String paymentMethod;
  final String? token;

  const ActivateSubscriptionParams({
    required this.planId,
    this.paymentMethod = 'UPI',
    this.token,
  });

  @override
  List<Object?> get props => [planId, paymentMethod, token];
}

class ActivateSubscriptionUseCase
    implements
        UseCase<SubscriptionActivationEntity, ActivateSubscriptionParams> {
  final SubscriptionRepository repository;

  ActivateSubscriptionUseCase(this.repository);

  @override
  Future<SubscriptionActivationEntity> call(
    ActivateSubscriptionParams params,
  ) async {
    return await repository.activateSubscription(
      planId: params.planId,
      paymentMethod: params.paymentMethod,
      token: params.token,
    );
  }
}
