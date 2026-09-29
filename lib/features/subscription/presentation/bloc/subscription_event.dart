import 'package:equatable/equatable.dart';

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object> get props => [];
}

class SelectSubscriptionPlanEvent extends SubscriptionEvent {
  final String planId;

  const SelectSubscriptionPlanEvent(this.planId);

  @override
  List<Object> get props => [planId];
}
