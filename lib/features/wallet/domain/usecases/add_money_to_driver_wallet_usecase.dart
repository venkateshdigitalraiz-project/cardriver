import '../entities/driver_wallet_entity.dart';
import '../repositories/driver_wallet_repository.dart';

class AddMoneyToDriverWalletUseCase {
  final DriverWalletRepository repository;

  AddMoneyToDriverWalletUseCase(this.repository);

  Future<DriverWalletEntity> call({
    required double amount,
    String? method,
  }) async {
    return await repository.addMoney(
      amount: amount,
      method: method,
    );
  }
}
