import 'package:equatable/equatable.dart';

abstract class SubscriptionHistoryEvent extends Equatable {
  const SubscriptionHistoryEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched to load driver subscription details from API
class LoadSubscriptionHistory extends SubscriptionHistoryEvent {
  final String? token;
  final bool silent;

  const LoadSubscriptionHistory({this.token, this.silent = false});

  @override
  List<Object?> get props => [token, silent];
}

/// Dispatched to filter subscription history list by status ("All", "Active", "Expired", "Cancelled")
class FilterSubscriptionHistory extends SubscriptionHistoryEvent {
  final String status;

  const FilterSubscriptionHistory(this.status);

  @override
  List<Object?> get props => [status];
}

/// Dispatched on pull-to-refresh
class RefreshSubscriptionHistory extends SubscriptionHistoryEvent {
  final String? token;

  const RefreshSubscriptionHistory({this.token});

  @override
  List<Object?> get props => [token];
}
