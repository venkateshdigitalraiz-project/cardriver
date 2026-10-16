import 'package:equatable/equatable.dart';
import '../../domain/entities/subscription_activation_entity.dart';
import '../../domain/entities/subscription_plan_entity.dart';

class SubscriptionState extends Equatable {
  final bool isLoading;
  final bool isRefreshing;
  final List<SubscriptionPlanEntity> plans;
  final String? selectedPlanId;
  final String? currentPlanId;
  final String? errorMessage;
  final bool isActivating;
  final SubscriptionActivationEntity? activationResult;
  final String? activationErrorMessage;

  const SubscriptionState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.plans = const [],
    this.selectedPlanId,
    this.currentPlanId,
    this.errorMessage,
    this.isActivating = false,
    this.activationResult,
    this.activationErrorMessage,
  });

  /// Returns the currently selected plan object, or the first plan if available
  SubscriptionPlanEntity? get selectedPlan {
    if (plans.isEmpty) return null;
    return plans.firstWhere(
      (p) => p.id == selectedPlanId,
      orElse: () => plans.first,
    );
  }

  /// Checks if any plans were loaded
  bool get hasPlans => plans.isNotEmpty;

  SubscriptionState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    List<SubscriptionPlanEntity>? plans,
    String? selectedPlanId,
    String? currentPlanId,
    String? errorMessage,
    bool clearError = false,
    bool? isActivating,
    bool clearIsActivating = false,
    SubscriptionActivationEntity? activationResult,
    bool clearActivationResult = false,
    String? activationErrorMessage,
    bool clearActivationError = false,
  }) {
    return SubscriptionState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      plans: plans ?? this.plans,
      selectedPlanId: selectedPlanId ?? this.selectedPlanId,
      currentPlanId: currentPlanId ?? this.currentPlanId,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isActivating:
          clearIsActivating ? false : (isActivating ?? this.isActivating),
      activationResult: clearActivationResult
          ? null
          : (activationResult ?? this.activationResult),
      activationErrorMessage: clearActivationError
          ? null
          : (activationErrorMessage ?? this.activationErrorMessage),
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isRefreshing,
        plans,
        selectedPlanId,
        currentPlanId,
        errorMessage,
        isActivating,
        activationResult,
        activationErrorMessage,
      ];
}
