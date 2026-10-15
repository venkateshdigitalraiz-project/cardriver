import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/socket_service.dart';
import '../../data/datasources/available_rides_remote_data_source.dart';
import '../../domain/entities/available_ride_entity.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AvailableRidesRemoteDataSource remoteDataSource;
  final SocketService socketService;
  final String driverToken;

  StreamSubscription<void>? _connectedSubscription;
  late final void Function(dynamic) _onNewAvailableRideHandler;
  late final void Function(String, dynamic) _onAnySocketHandler;

  static const List<String> _socketEvents = [
    'ride:new_available',
    'ride:available',
    'new_ride',
    'new_ride_available',
    'newRide',
    'newRideAvailable',
    'ride_request',
    'rideRequest',
    'new_booking',
    'newBooking',
    'booking:new',
    'booking_request',
    'bookingRequest',
    'driver:ride_request',
    'ride:requested',
    'ride_created',
    'booking_created',
    'ride',
    'booking',
  ];

  HomeBloc({
    required this.remoteDataSource,
    required this.socketService,
    required this.driverToken,
  }) : super(const HomeState()) {
    // 1. Maintain a single, stable handler reference for socket off/on
    _onNewAvailableRideHandler = _handleSocketRidePayload;
    _onAnySocketHandler = (event, data) {
      final ev = event.toLowerCase();
      if (ev.contains('ride') || ev.contains('booking') || ev.contains('request')) {
        _handleSocketRidePayload(data);
      }
    };

    // 2. Register Bloc event handlers
    on<ToggleOnlineStatusEvent>(_onToggleOnlineStatus);
    on<LoadAvailableRidesEvent>(_onLoadAvailableRides);
    on<NewRideReceivedEvent>(_onNewRideReceived);
    on<ClearNewRideAlertEvent>(_onClearNewRideAlert);
    on<DeclineRideRequestEvent>(_onDeclineRideRequest);

    // 3. Re-attach socket listener and refresh on connect / reconnect
    _connectedSubscription = socketService.onConnected.listen((_) {
      if (state.isOnline) {
        log('🔄 [HomeBloc] Socket connected/reconnected while online. Re-subscribing and fetching.');
        _attachSocketListener();
        add(const LoadAvailableRidesEvent(silent: true));
      }
    });
  }

  void _attachSocketListener() {
    log('🔌 [HomeBloc] Attaching listeners for: $_socketEvents');
    for (final event in _socketEvents) {
      socketService.off(event, _onNewAvailableRideHandler);
      socketService.on(event, _onNewAvailableRideHandler);
    }
    socketService.offAny(_onAnySocketHandler);
    socketService.onAny(_onAnySocketHandler);
  }

  void _detachSocketListener() {
    log('🔌 [HomeBloc] Detaching listeners for: $_socketEvents');
    for (final event in _socketEvents) {
      socketService.off(event, _onNewAvailableRideHandler);
    }
    socketService.offAny(_onAnySocketHandler);
  }

  void _handleSocketRidePayload(dynamic data) {
    try {
      log('📥 [HomeBloc] Socket ride event received: $data');
      if (data == null) return;

      dynamic payload = data;

      // Handle stringified JSON payload
      if (payload is String) {
        try {
          payload = jsonDecode(payload);
        } catch (_) {
          log('⚠️ [HomeBloc] Could not decode JSON string payload');
          return;
        }
      }

      // Handle direct list of rides
      if (payload is List) {
        for (final item in payload) {
          if (item is Map) {
            _dispatchRideIfValid(Map<String, dynamic>.from(item));
          }
        }
        return;
      }

      // Handle wrapped payloads
      if (payload is Map) {
        if (payload['rides'] is List) {
          for (final item in payload['rides'] as List) {
            if (item is Map) {
              _dispatchRideIfValid(Map<String, dynamic>.from(item));
            }
          }
          return;
        } else if (payload['data'] is List) {
          for (final item in payload['data'] as List) {
            if (item is Map) {
              _dispatchRideIfValid(Map<String, dynamic>.from(item));
            }
          }
          return;
        } else if (payload['bookings'] is List) {
          for (final item in payload['bookings'] as List) {
            if (item is Map) {
              _dispatchRideIfValid(Map<String, dynamic>.from(item));
            }
          }
          return;
        } else if (payload['ride'] is Map) {
          payload = payload['ride'];
        } else if (payload['booking'] is Map) {
          payload = payload['booking'];
        } else if (payload['rideRequest'] is Map) {
          payload = payload['rideRequest'];
        } else if (payload['request'] is Map) {
          payload = payload['request'];
        } else if (payload['data'] is Map) {
          final inner = payload['data'] as Map;
          if (inner['ride'] is Map) {
            payload = inner['ride'];
          } else if (inner['booking'] is Map) {
            payload = inner['booking'];
          } else {
            payload = inner;
          }
        }
      }

      if (payload is Map) {
        _dispatchRideIfValid(Map<String, dynamic>.from(payload));
      } else {
        log('⚠️ [HomeBloc] Unsupported socket ride payload format: $payload');
      }
    } catch (e, stack) {
      log('❌ [HomeBloc] Failed to parse incoming socket ride: $e\n$stack');
    }
  }

  void _dispatchRideIfValid(Map<String, dynamic> map) {
    final ride = AvailableRideEntity.fromJson(map);
    if (ride.id.isNotEmpty) {
      add(NewRideReceivedEvent(ride));
    } else {
      log('⚠️ [HomeBloc] Discarded ride with empty id from socket: $map');
    }
  }

  void _onToggleOnlineStatus(
    ToggleOnlineStatusEvent event,
    Emitter<HomeState> emit,
  ) {
    final nextOnline = event.forceStatus ?? !state.isOnline;

    if (nextOnline) {
      emit(
        state.copyWith(
          isOnline: true,
          isLoadingRides: true,
          clearError: true,
        ),
      );

      final cleanToken = driverToken.trim().replaceFirst(RegExp(r'^bearer\s+', caseSensitive: false), '');
      final token = cleanToken.isNotEmpty
          ? cleanToken
          : AvailableRidesRemoteDataSourceImpl.defaultDriverToken;

      // Connect or attach socket listener
      if (socketService.isConnected) {
        _attachSocketListener();
      } else {
        socketService.connectWithToken(token);
        _attachSocketListener();
      }

      // Initial API load
      add(const LoadAvailableRidesEvent(silent: false));
    } else {
      _detachSocketListener();
      emit(
        state.copyWith(
          isOnline: false,
          isLoadingRides: false,
          availableRides: const [],
          clearNewRideAlert: true,
        ),
      );
    }
  }

  Future<void> _onLoadAvailableRides(
    LoadAvailableRidesEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (!state.isOnline) return;

    if (!event.silent) {
      emit(state.copyWith(isLoadingRides: true, clearError: true));
    }

    try {
      final cleanToken = driverToken.trim().replaceFirst(RegExp(r'^bearer\s+', caseSensitive: false), '');
      final token = cleanToken.isNotEmpty
          ? cleanToken
          : AvailableRidesRemoteDataSourceImpl.defaultDriverToken;

      final apiRides = await remoteDataSource.fetchAvailableRides(token);

      // Merge API results with rides already received via socket
      // Treat API order as source of truth
      final apiIds = apiRides.map((r) => r.id).toSet();
      final socketOnlyRides = state.availableRides
          .where((ride) => !apiIds.contains(ride.id))
          .toList();

      final mergedRides = [...socketOnlyRides, ...apiRides];

      // If rides are present and no alert is active, set newest ride in alert
      final newAlert = state.newRideAlert ??
          (mergedRides.isNotEmpty ? mergedRides.first : null);

      emit(
        state.copyWith(
          isLoadingRides: false,
          availableRides: mergedRides,
          newRideAlert: newAlert,
          clearError: true,
        ),
      );
    } catch (e) {
      log('❌ [HomeBloc] Error loading available rides: $e');
      emit(
        state.copyWith(
          isLoadingRides: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  void _onNewRideReceived(
    NewRideReceivedEvent event,
    Emitter<HomeState> emit,
  ) {
    final existingIndex =
        state.availableRides.indexWhere((r) => r.id == event.ride.id);

    if (existingIndex == -1) {
      // New ride: insert at top and trigger alert banner
      final updatedList = [event.ride, ...state.availableRides];
      emit(
        state.copyWith(
          isOnline: true,
          availableRides: updatedList,
          newRideAlert: event.ride,
        ),
      );
    } else {
      // Existing ride: replace in place without re-triggering alert
      final updatedList = List<AvailableRideEntity>.from(state.availableRides);
      updatedList[existingIndex] = event.ride;
      emit(state.copyWith(isOnline: true, availableRides: updatedList));
    }
  }

  void _onClearNewRideAlert(
    ClearNewRideAlertEvent event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(clearNewRideAlert: true));
  }

  void _onDeclineRideRequest(
    DeclineRideRequestEvent event,
    Emitter<HomeState> emit,
  ) {
    final updatedList =
        state.availableRides.where((r) => r.id != event.rideId).toList();
    final clearAlert = state.newRideAlert?.id == event.rideId;

    emit(
      state.copyWith(
        availableRides: updatedList,
        clearNewRideAlert: clearAlert,
      ),
    );
  }

  @override
  Future<void> close() {
    _detachSocketListener();
    _connectedSubscription?.cancel();
    return super.close();
  }
}
