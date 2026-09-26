import 'package:equatable/equatable.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class NextStepEvent extends OnboardingEvent {}

class PreviousStepEvent extends OnboardingEvent {}

class StepTappedEvent extends OnboardingEvent {
  final int step;
  const StepTappedEvent(this.step);

  @override
  List<Object?> get props => [step];
}

class CompleteOnboardingEvent extends OnboardingEvent {}
