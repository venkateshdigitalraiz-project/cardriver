import 'package:flutter_bloc/flutter_bloc.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final int totalSteps = 6; // 0 to 5

  OnboardingBloc() : super(const OnboardingState()) {
    on<NextStepEvent>((event, emit) {
      if (state.currentStep < totalSteps - 1) {
        emit(state.copyWith(currentStep: state.currentStep + 1));
      } else {
        emit(state.copyWith(status: OnboardingStatus.complete));
      }
    });

    on<PreviousStepEvent>((event, emit) {
      if (state.currentStep > 0) {
        emit(state.copyWith(currentStep: state.currentStep - 1));
      }
    });

    on<StepTappedEvent>((event, emit) {
      emit(state.copyWith(currentStep: event.step));
    });

    on<CompleteOnboardingEvent>((event, emit) {
      emit(state.copyWith(status: OnboardingStatus.complete));
    });
  }
}
