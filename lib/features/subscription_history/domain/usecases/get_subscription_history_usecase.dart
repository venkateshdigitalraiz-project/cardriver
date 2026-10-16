import 'package:equatable/equatable.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/subscription_history_response_entity.dart';
import '../repositories/subscription_history_repository.dart';

class GetSubscriptionHistoryParams extends Equatable {
  final String? token;

  const GetSubscriptionHistoryParams({this.token});

  @override
  List<Object?> get props => [token];
}

class GetSubscriptionHistoryUseCase
    implements
        UseCase<SubscriptionHistoryResponseEntity,
            GetSubscriptionHistoryParams> {
  final SubscriptionHistoryRepository repository;

  GetSubscriptionHistoryUseCase(this.repository);

  @override
  Future<SubscriptionHistoryResponseEntity> call(
    GetSubscriptionHistoryParams params,
  ) async {
    return await repository.getSubscriptionHistory(token: params.token);
  }
}
