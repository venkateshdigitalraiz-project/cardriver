import '../entities/driver_wallet_entity.dart';
import '../entities/driver_wallet_transaction_entity.dart';

abstract class DriverWalletRepository {
  Future<DriverWalletEntity> getWallet();
  Future<DriverWalletEntity> withdrawFunds({
    required double amount,
    String? bankOrUpi,
  });
  Future<DriverWalletEntity> addMoney({
    required double amount,
    String? method,
  });
  Future<List<DriverWalletTransactionEntity>> getTransactions();
}
