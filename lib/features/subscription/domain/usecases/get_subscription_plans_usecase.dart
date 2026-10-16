import 'package:equatable/equatable.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/subscription_plan_entity.dart';
import '../repositories/subscription_repository.dart';

class GetSubscriptionPlansParams extends Equatable {
  final String? token;

  const GetSubscriptionPlansParams({this.token});

  @override
  List<Object?> get props => [token];
}

class GetSubscriptionPlansUseCase
    implements UseCase<List<SubscriptionPlanEntity>, GetSubscriptionPlansParams> {
  final SubscriptionRepository repository;

  GetSubscriptionPlansUseCase(this.repository);

  @override
  Future<List<SubscriptionPlanEntity>> call(
    GetSubscriptionPlansParams params,
  ) async {
    return await repository.getSubscriptionPlans(token: params.token);
  }
}
