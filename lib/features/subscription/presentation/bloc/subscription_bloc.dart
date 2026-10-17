import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../profile/domain/entities/driver_active_subscription_entity.dart';
import '../../../profile/domain/entities/driver_profile_entity.dart';
import '../../../profile/domain/usecases/get_driver_profile_usecase.dart';
import '../../data/datasources/subscription_remote_data_source.dart';
import '../../domain/usecases/activate_subscription_usecase.dart';
import '../../domain/usecases/get_subscription_plans_usecase.dart';
import 'subscription_event.dart';
import 'subscription_state.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final GetSubscriptionPlansUseCase getSubscriptionPlansUseCase;
  final ActivateSubscriptionUseCase activateSubscriptionUseCase;
  final GetDriverProfileUseCase? getDriverProfileUseCase;
  final String? driverToken;

  SubscriptionBloc({
    required this.getSubscriptionPlansUseCase,
    required this.activateSubscriptionUseCase,
    this.getDriverProfileUseCase,
    this.driverToken,
    bool initialHasSubscription = false,
  }) : super(SubscriptionState(
          isLoading: true,
          hasSubscription: initialHasSubscription,
        )) {
    on<LoadSubscriptionPlansEvent>(_onLoadSubscriptionPlans);
    on<SelectSubscriptionPlanEvent>(_onSelectSubscriptionPlan);
    on<RefreshSubscriptionPlansEvent>(_onRefreshSubscriptionPlans);
    on<ActivateSubscriptionEvent>(_onActivateSubscription);
    on<ClearSubscriptionActivationEvent>(_onClearSubscriptionActivation);
  }

  Future<void> _onLoadSubscriptionPlans(
    LoadSubscriptionPlansEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    if (!event.silent) {
      emit(state.copyWith(
        isLoading: true,
        clearError: true,
        hasSubscription: event.hasSubscription ?? state.hasSubscription,
      ));
    }

    try {
      final token = event.token ??
          driverToken ??
          SubscriptionRemoteDataSourceImpl.defaultDriverToken;

      final plansFuture = getSubscriptionPlansUseCase(
        GetSubscriptionPlansParams(token: token),
      );

      final profileFuture = getDriverProfileUseCase != null
          ? getDriverProfileUseCase!(GetDriverProfileParams(token: token))
          : null;

      final plans = await plansFuture;

      DriverProfileEntity? profile;
      if (profileFuture != null) {
        try {
          profile = await profileFuture;
        } catch (e) {
          log('⚠️ [SubscriptionBloc] Could not fetch profile status: $e');
        }
      }

      final bool hasSub = profile?.hasSubscription ??
          event.hasSubscription ??
          state.hasSubscription;
      final DriverActiveSubscriptionEntity? activeSub =
          profile?.activeSubscription ?? state.activeSubscription;

      String? selectedId = state.selectedPlanId;
      if (selectedId == null || !plans.any((p) => p.id == selectedId)) {
        if (activeSub != null && plans.any((p) => p.id == activeSub.planId)) {
          selectedId = activeSub.planId;
        } else if (plans.isNotEmpty) {
          final firstActive = plans.firstWhere(
            (p) => p.isActive,
            orElse: () => plans.first,
          );
          selectedId = firstActive.id;
        }
      }

      emit(
        state.copyWith(
          isLoading: false,
          isRefreshing: false,
          plans: plans,
          selectedPlanId: selectedId,
          hasSubscription: hasSub,
          activeSubscription: activeSub,
          clearError: true,
        ),
      );
    } catch (e) {
      log('❌ [SubscriptionBloc] Failed to load subscription plans: $e');
      emit(
        state.copyWith(
          isLoading: false,
          isRefreshing: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  void _onSelectSubscriptionPlan(
    SelectSubscriptionPlanEvent event,
    Emitter<SubscriptionState> emit,
  ) {
    emit(state.copyWith(selectedPlanId: event.planId));
  }

  Future<void> _onRefreshSubscriptionPlans(
    RefreshSubscriptionPlansEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(state.copyWith(isRefreshing: true, clearError: true));
    add(LoadSubscriptionPlansEvent(
      token: event.token,
      silent: true,
      hasSubscription: event.hasSubscription,
    ));
  }

  Future<void> _onActivateSubscription(
    ActivateSubscriptionEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(state.copyWith(
      isActivating: true,
      clearActivationError: true,
      clearActivationResult: true,
    ));

    try {
      final token = event.token ??
          driverToken ??
          SubscriptionRemoteDataSourceImpl.defaultDriverToken;

      final result = await activateSubscriptionUseCase(
        ActivateSubscriptionParams(
          planId: event.planId,
          paymentMethod: event.paymentMethod,
          token: token,
        ),
      );

      // Once activation succeeds, hasSubscription is true so "Activate Pass" is disabled
      emit(state.copyWith(
        clearIsActivating: true,
        activationResult: result,
        hasSubscription: true,
        clearActivationError: true,
      ));
    } catch (e) {
      log('❌ [SubscriptionBloc] Activation error: $e');
      emit(state.copyWith(
        clearIsActivating: true,
        activationErrorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  void _onClearSubscriptionActivation(
    ClearSubscriptionActivationEvent event,
    Emitter<SubscriptionState> emit,
  ) {
    emit(state.copyWith(
      clearActivationResult: true,
      clearActivationError: true,
    ));
  }
}
