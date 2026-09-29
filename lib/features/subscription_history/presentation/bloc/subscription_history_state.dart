import 'package:equatable/equatable.dart';
import '../../domain/entities/subscription_transaction.dart';

abstract class SubscriptionHistoryState extends Equatable {
  const SubscriptionHistoryState();
  
  @override
  List<Object> get props => [];
}

class SubscriptionHistoryLoading extends SubscriptionHistoryState {}

class SubscriptionHistoryLoaded extends SubscriptionHistoryState {
  final List<SubscriptionTransaction> allTransactions;
  final List<SubscriptionTransaction> filteredTransactions;
  final String currentFilter;

  const SubscriptionHistoryLoaded({
    required this.allTransactions,
    required this.filteredTransactions,
    required this.currentFilter,
  });

  @override
  List<Object> get props => [allTransactions, filteredTransactions, currentFilter];
}

class SubscriptionHistoryError extends SubscriptionHistoryState {
  final String message;

  const SubscriptionHistoryError(this.message);

  @override
  List<Object> get props => [message];
}
