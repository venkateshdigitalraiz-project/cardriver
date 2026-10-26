import '../entities/driver_wallet_entity.dart';
import '../repositories/driver_wallet_repository.dart';

class WithdrawWalletFundsUseCase {
  final DriverWalletRepository repository;

  WithdrawWalletFundsUseCase(this.repository);

  Future<DriverWalletEntity> call({
    required double amount,
    String? bankOrUpi,
  }) async {
    return await repository.withdrawFunds(
      amount: amount,
      bankOrUpi: bankOrUpi,
    );
  }
}
