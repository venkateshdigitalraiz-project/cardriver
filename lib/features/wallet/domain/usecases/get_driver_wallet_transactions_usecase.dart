import '../entities/driver_wallet_transaction_entity.dart';
import '../repositories/driver_wallet_repository.dart';

class GetDriverWalletTransactionsUseCase {
  final DriverWalletRepository repository;

  GetDriverWalletTransactionsUseCase(this.repository);

  Future<List<DriverWalletTransactionEntity>> call() async {
    return await repository.getTransactions();
  }
}
