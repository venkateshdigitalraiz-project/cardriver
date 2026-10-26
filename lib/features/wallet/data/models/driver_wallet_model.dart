import '../../domain/entities/driver_wallet_entity.dart';
import 'driver_wallet_transaction_model.dart';

class DriverWalletModel extends DriverWalletEntity {
  const DriverWalletModel({
    required super.balance,
    super.todayEarnings,
    super.totalWithdrawn,
    super.currency,
    super.bankAccountInfo,
    required super.lastUpdated,
    super.transactions,
  });

  factory DriverWalletModel.fromJson(Map<String, dynamic> json) {
    var rawTxns = json['transactions'];
    List<DriverWalletTransactionModel> txns = [];
    if (rawTxns is List) {
      txns = rawTxns
          .whereType<Map<String, dynamic>>()
          .map((e) => DriverWalletTransactionModel.fromJson(e))
          .toList();
    }

    return DriverWalletModel(
      balance: (json['balance'] as num?)?.toDouble() ?? 1250.0,
      todayEarnings: (json['todayEarnings'] as num?)?.toDouble() ?? 850.0,
      totalWithdrawn: (json['totalWithdrawn'] as num?)?.toDouble() ?? 4500.0,
      currency: json['currency'] ?? '₹',
      bankAccountInfo:
          json['bankAccountInfo'] ?? 'State Bank of India (••4092)',
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.tryParse(json['lastUpdated'].toString()) ?? DateTime.now()
          : DateTime.now(),
      transactions: txns,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
      'todayEarnings': todayEarnings,
      'totalWithdrawn': totalWithdrawn,
      'currency': currency,
      'bankAccountInfo': bankAccountInfo,
      'lastUpdated': lastUpdated.toIso8601String(),
      'transactions': transactions
          .map((e) => (e is DriverWalletTransactionModel
              ? e
              : DriverWalletTransactionModel(
                  id: e.id,
                  title: e.title,
                  description: e.description,
                  amount: e.amount,
                  timestamp: e.timestamp,
                  type: e.type,
                  status: e.status,
                )).toJson())
          .toList(),
    };
  }
}
