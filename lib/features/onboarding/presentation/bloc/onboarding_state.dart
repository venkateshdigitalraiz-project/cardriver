import 'package:equatable/equatable.dart';

enum OnboardingStatus { initial, inProgress, complete }

class OnboardingState extends Equatable {
  final int currentStep;
  final OnboardingStatus status;

  const OnboardingState({
    this.currentStep = 0,
    this.status = OnboardingStatus.initial,
  });

  OnboardingState copyWith({
    int? currentStep,
    OnboardingStatus? status,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [currentStep, status];
}
