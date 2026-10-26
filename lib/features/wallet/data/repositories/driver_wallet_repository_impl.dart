import '../../domain/entities/driver_wallet_entity.dart';
import '../../domain/entities/driver_wallet_transaction_entity.dart';
import '../../domain/repositories/driver_wallet_repository.dart';
import '../datasources/driver_wallet_local_datasource.dart';

class DriverWalletRepositoryImpl implements DriverWalletRepository {
  final DriverWalletLocalDataSource localDataSource;

  DriverWalletRepositoryImpl({required this.localDataSource});

  @override
  Future<DriverWalletEntity> getWallet() async {
    return await localDataSource.getWallet();
  }

  @override
  Future<DriverWalletEntity> withdrawFunds({
    required double amount,
    String? bankOrUpi,
  }) async {
    return await localDataSource.withdrawFunds(amount, bankOrUpi);
  }

  @override
  Future<DriverWalletEntity> addMoney({
    required double amount,
    String? method,
  }) async {
    return await localDataSource.addMoney(amount, method);
  }

  @override
  Future<List<DriverWalletTransactionEntity>> getTransactions() async {
    return await localDataSource.getTransactions();
  }
}
