import 'package:equatable/equatable.dart';
import 'driver_wallet_transaction_entity.dart';

class DriverWalletEntity extends Equatable {
  final double balance;
  final double todayEarnings;
  final double totalWithdrawn;
  final String currency;
  final String bankAccountInfo;
  final DateTime lastUpdated;
  final List<DriverWalletTransactionEntity> transactions;

  const DriverWalletEntity({
    required this.balance,
    this.todayEarnings = 0.0,
    this.totalWithdrawn = 0.0,
    this.currency = '₹',
    this.bankAccountInfo = 'State Bank of India (••4092)',
    required this.lastUpdated,
    this.transactions = const [],
  });

  DriverWalletEntity copyWith({
    double? balance,
    double? todayEarnings,
    double? totalWithdrawn,
    String? currency,
    String? bankAccountInfo,
    DateTime? lastUpdated,
    List<DriverWalletTransactionEntity>? transactions,
  }) {
    return DriverWalletEntity(
      balance: balance ?? this.balance,
      todayEarnings: todayEarnings ?? this.todayEarnings,
      totalWithdrawn: totalWithdrawn ?? this.totalWithdrawn,
      currency: currency ?? this.currency,
      bankAccountInfo: bankAccountInfo ?? this.bankAccountInfo,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      transactions: transactions ?? this.transactions,
    );
  }

  @override
  List<Object?> get props => [
    balance,
    todayEarnings,
    totalWithdrawn,
    currency,
    bankAccountInfo,
    lastUpdated,
    transactions,
  ];
}
