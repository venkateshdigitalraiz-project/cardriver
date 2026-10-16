import 'package:equatable/equatable.dart';
import '../../domain/entities/driver_subscription_entity.dart';

abstract class SubscriptionHistoryState extends Equatable {
  const SubscriptionHistoryState();

  @override
  List<Object?> get props => [];
}

class SubscriptionHistoryLoading extends SubscriptionHistoryState {
  final bool isSilent;

  const SubscriptionHistoryLoading({this.isSilent = false});

  @override
  List<Object?> get props => [isSilent];
}

class SubscriptionHistoryLoaded extends SubscriptionHistoryState {
  final bool hasActiveSubscription;
  final DriverSubscriptionEntity? activeSubscription;
  final List<DriverSubscriptionEntity> allSubscriptions;
  final List<DriverSubscriptionEntity> filteredSubscriptions;
  final String currentFilter;
  final bool isRefreshing;

  const SubscriptionHistoryLoaded({
    required this.hasActiveSubscription,
    this.activeSubscription,
    required this.allSubscriptions,
    required this.filteredSubscriptions,
    this.currentFilter = 'All',
    this.isRefreshing = false,
  });

  SubscriptionHistoryLoaded copyWith({
    bool? hasActiveSubscription,
    DriverSubscriptionEntity? activeSubscription,
    List<DriverSubscriptionEntity>? allSubscriptions,
    List<DriverSubscriptionEntity>? filteredSubscriptions,
    String? currentFilter,
    bool? isRefreshing,
  }) {
    return SubscriptionHistoryLoaded(
      hasActiveSubscription:
          hasActiveSubscription ?? this.hasActiveSubscription,
      activeSubscription: activeSubscription ?? this.activeSubscription,
      allSubscriptions: allSubscriptions ?? this.allSubscriptions,
      filteredSubscriptions:
          filteredSubscriptions ?? this.filteredSubscriptions,
      currentFilter: currentFilter ?? this.currentFilter,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [
        hasActiveSubscription,
        activeSubscription,
        allSubscriptions,
        filteredSubscriptions,
        currentFilter,
        isRefreshing,
      ];
}

class SubscriptionHistoryError extends SubscriptionHistoryState {
  final String message;

  const SubscriptionHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}
