import 'package:equatable/equatable.dart';

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched to fetch available subscription plans and driver subscription status.
class LoadSubscriptionPlansEvent extends SubscriptionEvent {
  final String? token;
  final bool silent;
  final bool? hasSubscription;

  const LoadSubscriptionPlansEvent({
    this.token,
    this.silent = false,
    this.hasSubscription,
  });

  @override
  List<Object?> get props => [token, silent, hasSubscription];
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
  final bool? hasSubscription;

  const RefreshSubscriptionPlansEvent({this.token, this.hasSubscription});

  @override
  List<Object?> get props => [token, hasSubscription];
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
