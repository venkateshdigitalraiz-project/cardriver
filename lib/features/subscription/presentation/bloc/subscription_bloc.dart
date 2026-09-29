import 'package:flutter_bloc/flutter_bloc.dart';
import 'subscription_event.dart';
import 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  SubscriptionBloc() : super(const SubscriptionInitial()) {
    on<SelectSubscriptionPlanEvent>((event, emit) {
      if (state is SubscriptionInitial) {
        final currentState = state as SubscriptionInitial;
        emit(SubscriptionInitial(
          selectedPlanId: event.planId,
          currentPlanId: currentState.currentPlanId,
        ));
      }
    });
  }
}
