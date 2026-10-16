import 'package:equatable/equatable.dart';

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched to fetch available subscription plans from the API.
class LoadSubscriptionPlansEvent extends SubscriptionEvent {
  final String? token;
  final bool silent;

  const LoadSubscriptionPlansEvent({this.token, this.silent = false});

  @override
  List<Object?> get props => [token, silent];
}

/// Dispatched when the driver taps to select a specific plan.
class SelectSubscriptionPlanEvent extends SubscriptionEvent {
  final String planId;

  const SelectSubscriptionPlanEvent(this.planId);

  @override
  List<Object?> get props => [planId];
}

/// Dispatched on pull-to-refresh to silently update the plans list.
class RefreshSubscriptionPlansEvent extends SubscriptionEvent {
  final String? token;

  const RefreshSubscriptionPlansEvent({this.token});

  @override
  List<Object?> get props => [token];
}

/// Dispatched when the driver confirms purchase/activation of a subscription plan.
class ActivateSubscriptionEvent extends SubscriptionEvent {
  final String planId;
  final String paymentMethod;
  final String? token;

  const ActivateSubscriptionEvent({
    required this.planId,
    this.paymentMethod = 'UPI',
    this.token,
  });

  @override
  List<Object?> get props => [planId, paymentMethod, token];
}

/// Dispatched to clear activation result after UI modal has handled it.
class ClearSubscriptionActivationEvent extends SubscriptionEvent {}
