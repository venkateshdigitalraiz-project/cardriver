import '../entities/driver_wallet_entity.dart';
import '../repositories/driver_wallet_repository.dart';

class GetDriverWalletUseCase {
  final DriverWalletRepository repository;

  GetDriverWalletUseCase(this.repository);

  Future<DriverWalletEntity> call() async {
    return await repository.getWallet();
  }
}
