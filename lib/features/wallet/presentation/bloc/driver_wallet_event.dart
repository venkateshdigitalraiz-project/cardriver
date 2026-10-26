import 'package:equatable/equatable.dart';

abstract class DriverWalletEvent extends Equatable {
  const DriverWalletEvent();

  @override
  List<Object?> get props => [];
}

class LoadDriverWalletEvent extends DriverWalletEvent {
  const LoadDriverWalletEvent();
}

class RefreshDriverWalletEvent extends DriverWalletEvent {
  const RefreshDriverWalletEvent();
}

class WithdrawDriverWalletFundsEvent extends DriverWalletEvent {
  final double amount;
  final String? destination;

  const WithdrawDriverWalletFundsEvent({
    required this.amount,
    this.destination,
  });

  @override
  List<Object?> get props => [amount, destination];
}

class AddMoneyToDriverWalletEvent extends DriverWalletEvent {
  final double amount;
  final String? method;

  const AddMoneyToDriverWalletEvent({
    required this.amount,
    this.method,
  });

  @override
  List<Object?> get props => [amount, method];
}
