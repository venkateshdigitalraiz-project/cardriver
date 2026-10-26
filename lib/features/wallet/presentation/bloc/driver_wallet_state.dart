import 'package:equatable/equatable.dart';
import '../../domain/entities/driver_wallet_entity.dart';

abstract class DriverWalletState extends Equatable {
  const DriverWalletState();

  @override
  List<Object?> get props => [];
}

class DriverWalletInitial extends DriverWalletState {
  const DriverWalletInitial();
}

class DriverWalletLoading extends DriverWalletState {
  final DriverWalletEntity? currentWallet;
  const DriverWalletLoading({this.currentWallet});

  @override
  List<Object?> get props => [currentWallet];
}

class DriverWalletLoaded extends DriverWalletState {
  final DriverWalletEntity wallet;
  final String? successMessage;

  const DriverWalletLoaded({
    required this.wallet,
    this.successMessage,
  });

  @override
  List<Object?> get props => [wallet, successMessage];
}

class DriverWalletError extends DriverWalletState {
  final String message;
  final DriverWalletEntity? currentWallet;

  const DriverWalletError({
    required this.message,
    this.currentWallet,
  });

  @override
  List<Object?> get props => [message, currentWallet];
}
