import 'package:equatable/equatable.dart';

enum DriverTransactionType { credit, debit }

class DriverWalletTransactionEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final double amount;
  final DateTime timestamp;
  final DriverTransactionType type;
  final String status; // 'Completed', 'Processing', 'Failed'

  const DriverWalletTransactionEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.timestamp,
    required this.type,
    this.status = 'Completed',
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    amount,
    timestamp,
    type,
    status,
  ];
}
