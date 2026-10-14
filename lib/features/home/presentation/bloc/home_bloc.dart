import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/available_ride_entity.dart';
import '../../domain/usecases/get_available_rides_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetAvailableRidesUseCase? getAvailableRidesUseCase;
  final String? driverToken;

  StreamSubscription<List<AvailableRideEntity>>? _monitoringSubscription;

  static const String defaultFallbackToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjZhY2YyZDY1NGViY2UxNDlhMzZlOWI1ZCIsInJvbGUiOiJkcml2ZXIiLCJpYXQiOjE3OTE5NzEyODQsImV4cCI6MTc5MjU3NjA4NH0.L4T_-AyHasOEXO5onMJOI2ynFBu7rpUCoz5971nz3jk';

  HomeBloc({
    this.getAvailableRidesUseCase,
    this.driverToken,
  }) : super(const HomeState(todaysEarnings: 9640, todaysTrips: 8, rating: 4.8)) {
    on<ToggleOnlineStatusEvent>(_onToggleOnlineStatus);
    on<StartMonitoringRidesEvent>(_onStartMonitoringRides);
    on<StopMonitoringRidesEvent>(_onStopMonitoringRides);
    on<RidesUpdatedEvent>(_onRidesUpdated);
    on<DeclineRideRequestEvent>(_onDeclineRideRequest);
    on<ClearNewRideAlertEvent>(_onClearNewRideAlert);
  }

  Future<void> _onToggleOnlineStatus(
    ToggleOnlineStatusEvent event,
    Emitter<HomeState> emit,
  ) async {
    final nextOnline = event.forceStatus ?? !state.isOnline;

    if (nextOnline) {
      emit(state.copyWith(
        isOnline: true,
        isLoadingRides: true,
        clearError: true,
      ));
      _startLiveMonitoring();
    } else {
      _stopLiveMonitoring();
      emit(state.copyWith(
        isOnline: false,
        availableRides: const [],
        activeRequestIds: const [],
        hasRideRequest: false,
        isLoadingRides: false,
        clearNewRideAlert: true,
      ));
    }
  }

  void _onStartMonitoringRides(
    StartMonitoringRidesEvent event,
    Emitter<HomeState> emit,
  ) {
    if (state.isOnline) {
      _startLiveMonitoring(token: event.token);
    }
  }

  void _onStopMonitoringRides(
    StopMonitoringRidesEvent event,
    Emitter<HomeState> emit,
  ) {
    _stopLiveMonitoring();
  }

  void _onRidesUpdated(
    RidesUpdatedEvent event,
    Emitter<HomeState> emit,
  ) {
    final filteredRides = event.rides
        .where((ride) => !state.declinedRideIds.contains(ride.id))
        .toList();

    // Check for newly arrived rides (Rapid Capital style alert)
    AvailableRideEntity? newestRide;
    final existingIds = state.availableRides.map((r) => r.id).toSet();
    for (final ride in filteredRides) {
      if (!existingIds.contains(ride.id)) {
        newestRide = ride;
        break;
      }
    }

    emit(state.copyWith(
      availableRides: filteredRides,
      activeRequestIds: filteredRides.map((r) => r.id).toList(),
      hasRideRequest: filteredRides.isNotEmpty,
      isLoadingRides: false,
      newRideAlert: newestRide ?? state.newRideAlert,
    ));
  }

  void _onDeclineRideRequest(
    DeclineRideRequestEvent event,
    Emitter<HomeState> emit,
  ) {
    final updatedDeclined = Set<String>.from(state.declinedRideIds)..add(event.requestId);
    final updatedRides = state.availableRides
        .where((ride) => ride.id != event.requestId)
        .toList();

    emit(state.copyWith(
      declinedRideIds: updatedDeclined,
      availableRides: updatedRides,
      activeRequestIds: updatedRides.map((r) => r.id).toList(),
      hasRideRequest: updatedRides.isNotEmpty,
      clearNewRideAlert: state.newRideAlert?.id == event.requestId,
    ));
  }

  void _onClearNewRideAlert(
    ClearNewRideAlertEvent event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(clearNewRideAlert: true));
  }

  void _startLiveMonitoring({String? token}) {
    _monitoringSubscription?.cancel();

    if (getAvailableRidesUseCase == null) {
      return;
    }

    final effectiveToken = token ?? driverToken ?? defaultFallbackToken;
    final stream = getAvailableRidesUseCase!.monitor(
      GetAvailableRidesParams(token: effectiveToken),
      interval: const Duration(seconds: 4),
    );

    _monitoringSubscription = stream.listen(
      (rides) {
        add(RidesUpdatedEvent(rides));
      },
      onError: (error) {
        // Continue monitoring on error; no fatal crash
      },
    );
  }

  void _stopLiveMonitoring() {
    _monitoringSubscription?.cancel();
    _monitoringSubscription = null;
  }

  @override
  Future<void> close() {
    _stopLiveMonitoring();
    return super.close();
  }
}
