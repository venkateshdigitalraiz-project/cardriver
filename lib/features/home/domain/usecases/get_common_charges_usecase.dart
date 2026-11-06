import '../entities/common_charges_entity.dart';
import '../repositories/home_repository.dart';

/// Clean Architecture UseCase to fetch common charges.
/// Endpoint: GET /api/common/charges
class GetCommonChargesUseCase {
  final HomeRepository repository;

  const GetCommonChargesUseCase(this.repository);

  Future<List<CommonChargesEntity>> call({String? token}) async {
    return await repository.getCommonCharges(token: token);
  }
}

