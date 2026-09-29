import 'package:equatable/equatable.dart';

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object> get props => [];
}

class SubscriptionInitial extends SubscriptionState {
  final String selectedPlanId;
  final String currentPlanId;

  const SubscriptionInitial({
    this.selectedPlanId = 'premium',
    this.currentPlanId = 'premium',
  });

  @override
  List<Object> get props => [selectedPlanId, currentPlanId];
}
