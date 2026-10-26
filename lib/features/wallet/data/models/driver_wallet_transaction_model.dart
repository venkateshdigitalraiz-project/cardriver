import '../../domain/entities/driver_wallet_transaction_entity.dart';

class DriverWalletTransactionModel extends DriverWalletTransactionEntity {
  const DriverWalletTransactionModel({
    required super.id,
    required super.title,
    required super.description,
    required super.amount,
    required super.timestamp,
    required super.type,
    super.status,
  });

  factory DriverWalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return DriverWalletTransactionModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Transaction',
      description: json['description'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      type: json['type'] == 'debit'
          ? DriverTransactionType.debit
          : DriverTransactionType.credit,
      status: json['status'] ?? 'Completed',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'timestamp': timestamp.toIso8601String(),
      'type': type == DriverTransactionType.debit ? 'debit' : 'credit',
      'status': status,
    };
  }
}
