import 'package:equatable/equatable.dart';

abstract class SubscriptionHistoryEvent extends Equatable {
  const SubscriptionHistoryEvent();

  @override
  List<Object> get props => [];
}

class LoadSubscriptionHistory extends SubscriptionHistoryEvent {}

class FilterSubscriptionHistory extends SubscriptionHistoryEvent {
  final String status; // "All", "Active", "Expired", "Cancelled"

  const FilterSubscriptionHistory(this.status);

  @override
  List<Object> get props => [status];
}
