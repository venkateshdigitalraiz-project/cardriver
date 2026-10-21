import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/socket_service.dart';
import '../../../../core/services/firebase_messaging_service.dart';
import '../../data/datasources/available_rides_remote_data_source.dart';
import '../../domain/entities/available_ride_entity.dart';
import '../../domain/usecases/accept_ride_usecase.dart';
import '../../domain/usecases/reject_ride_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AvailableRidesRemoteDataSource remoteDataSource;
  final SocketService socketService;
  final String driverToken;
  final AcceptRideUseCase? acceptRideUseCase;
  final RejectRideUseCase? rejectRideUseCase;

  StreamSubscription<void>? _connectedSubscription;
  StreamSubscription<dynamic>? _rideNewAvailableSubscription;
  late final void Function(dynamic) _onRideNewAvailableHandler;
  DateTime? _lastRefreshTime;
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _lastSoundEventRideId;
  DateTime? _lastSoundPlayedTime;

  static const String _socketEvent = 'ride:new_available';

  HomeBloc({
    required this.remoteDataSource,
    required this.socketService,
    required this.driverToken,
    this.acceptRideUseCase,
    this.rejectRideUseCase,
  }) : super(const HomeState()) {
    // 1. Maintain a stable handler reference for socket off/on
    _onRideNewAvailableHandler = _handleRideNewAvailable;

    // 2. Register Bloc event handlers
    on<ToggleOnlineStatusEvent>(_onToggleOnlineStatus);
    on<LoadAvailableRidesEvent>(_onLoadAvailableRides);
    on<NewRideReceivedEvent>(_onNewRideReceived);
    on<ClearNewRideAlertEvent>(_onClearNewRideAlert);
    on<DeclineRideRequestEvent>(_onDeclineRideRequest);
    on<ClearRejectedRideEvent>(_onClearRejectedRide);
    on<AcceptRideEvent>(_onAcceptRide);
    on<ClearAcceptedRideEvent>(_onClearAcceptedRide);

    // 3. Listen to socket connection / reconnection
    _connectedSubscription = socketService.onConnected.listen((_) {
      if (state.isOnline) {
        log(
          '🔄 [HomeBloc] Socket connected/reconnected while online. Attaching listener and refreshing home page.',
        );
        _attachSocketListener();
        add(const LoadAvailableRidesEvent(silent: true));
      }
    });

    // 4. Listen to onRideNewAvailable stream from SocketService
    _rideNewAvailableSubscription = socketService.onRideNewAvailable.listen((
      data,
    ) {
      if (state.isOnline) {
        log('🚗 [HomeBloc] "ride:new_available" stream received: $data');
        _handleRideNewAvailable(data);
      }
    });
  }

  void _attachSocketListener() {
    log('🔌 [HomeBloc] Attaching socket listener for: $_socketEvent');
    socketService.off(_socketEvent, _onRideNewAvailableHandler);
    socketService.on(_socketEvent, _onRideNewAvailableHandler);
  }

  void _detachSocketListener() {
    log('🔌 [HomeBloc] Detaching socket listener for: $_socketEvent');
    socketService.off(_socketEvent, _onRideNewAvailableHandler);
  }

  /// Handles incoming 'ride:new_available' socket event.
  /// Refreshes the driver app home page so up-to-date rides are displayed.
  void _handleRideNewAvailable(dynamic data) {
    // 1. Debounce rapid duplicate socket events within 1 second
    final now = DateTime.now();
    if (_lastRefreshTime != null &&
        now.difference(_lastRefreshTime!).inMilliseconds < 1000) {
      log('⏱️ [HomeBloc] Duplicate "ride:new_available" ignored within 1s');
      return;
    }
    _lastRefreshTime = now;

    log(
      '🚗 [HomeBloc] "ride:new_available" event detected! Refreshing home page...',
    );

    // 2. Play short notification sound safely for new incoming event
    _playNotificationSound(data);

    // 3. If payload contains a valid ride entity, dispatch immediately for instant UI responsiveness
    if (data != null) {
      try {
        dynamic parsed = data;
        if (parsed is String) {
          try {
            parsed = jsonDecode(parsed);
          } catch (_) {}
        }

        if (parsed is Map) {
          Map<String, dynamic>? rideMap;
          if (parsed['ride'] is Map) {
            rideMap = Map<String, dynamic>.from(parsed['ride']);
          } else if (parsed['id'] != null || parsed['_id'] != null) {
            rideMap = Map<String, dynamic>.from(parsed);
          }

          if (rideMap != null) {
            final ride = AvailableRideEntity.fromJson(rideMap);
            if (ride.id.isNotEmpty) {
              log(
                '✨ [HomeBloc] Instant new ride alert from socket payload: ${ride.id}',
              );
              add(NewRideReceivedEvent(ride));
              try {
                FirebaseMessagingService().showNotification(
                  title: '🚗 New Ride Available!',
                  body: ride.pickupAddress.isNotEmpty
                      ? 'Pickup: ${ride.pickupAddress}'
                      : 'A new ride request is ready to accept.',
                  payload: 'ride_request',
                );
              } catch (_) {}
            }
          }
        }
      } catch (e) {
        log('ℹ️ [HomeBloc] Non-critical error parsing payload ride: $e');
      }
    }

    // 4. Always refresh available rides from API so the home page is 100% up-to-date
    add(const LoadAvailableRidesEvent(silent: true));
  }

  /// Plays short notification sound safely without disrupting event processing or UI.
  void _playNotificationSound([dynamic data]) {
    try {
      final now = DateTime.now();
      // Guard against rapid duplicate playback within 1 second
      if (_lastSoundPlayedTime != null &&
          now.difference(_lastSoundPlayedTime!).inMilliseconds < 1000) {
        return;
      }

      String? rideId;
      if (data is Map) {
        if (data['ride'] is Map) {
          rideId =
              data['ride']['id']?.toString() ??
              data['ride']['_id']?.toString();
        } else {
          rideId = data['id']?.toString() ?? data['_id']?.toString();
        }
      }

      // Prevent duplicate sound for the same ride ID
      if (rideId != null &&
          rideId.isNotEmpty &&
          rideId == _lastSoundEventRideId) {
        return;
      }

      if (rideId != null && rideId.isNotEmpty) {
        _lastSoundEventRideId = rideId;
      }
      _lastSoundPlayedTime = now;

      _audioPlayer.stop();
      _audioPlayer.play(AssetSource('sounds/notification.mp3'));
    } catch (e) {
      log('ℹ️ [HomeBloc] Notification sound skipped/failed: $e');
    }
  }

  void _onToggleOnlineStatus(
    ToggleOnlineStatusEvent event,
    Emitter<HomeState> emit,
  ) {
    final nextOnline = event.forceStatus ?? !state.isOnline;

    if (nextOnline) {
      emit(
        state.copyWith(isOnline: true, isLoadingRides: true, clearError: true),
      );

      final cleanToken = driverToken.trim().replaceFirst(
        RegExp(r'^bearer\s+', caseSensitive: false),
        '',
      );
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

    if (!event.silent && state.availableRides.isEmpty) {
      emit(state.copyWith(isLoadingRides: true, clearError: true));
    }

    try {
      final cleanToken = driverToken.trim().replaceFirst(
        RegExp(r'^bearer\s+', caseSensitive: false),
        '',
      );
      final token = cleanToken.isNotEmpty
          ? cleanToken
          : AvailableRidesRemoteDataSourceImpl.defaultDriverToken;

      final apiRides = await remoteDataSource.fetchAvailableRides(token);

      // Check if there are newly added rides compared to previous state
      final previousIds = state.availableRides.map((r) => r.id).toSet();
      AvailableRideEntity? newAlert = state.newRideAlert;

      // Find any newly arrived ride to trigger the alert
      for (final ride in apiRides) {
        if (!previousIds.contains(ride.id)) {
          newAlert = ride;
          break;
        }
      }

      // If no alert is currently active and rides are available, show the newest
      if (newAlert == null && apiRides.isNotEmpty) {
        newAlert = apiRides.first;
      }

      // If the current alert ride is no longer in the available rides list, clear or update it
      if (newAlert != null && !apiRides.any((r) => r.id == newAlert!.id)) {
        newAlert = apiRides.isNotEmpty ? apiRides.first : null;
      }

      emit(
        state.copyWith(
          isLoadingRides: false,
          availableRides: apiRides,
          newRideAlert: newAlert,
          clearNewRideAlert: newAlert == null,
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

  void _onNewRideReceived(NewRideReceivedEvent event, Emitter<HomeState> emit) {
    final existingIndex = state.availableRides.indexWhere(
      (r) => r.id == event.ride.id,
    );

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

  Future<void> _onDeclineRideRequest(
    DeclineRideRequestEvent event,
    Emitter<HomeState> emit,
  ) async {
    // If an accept or decline is already in-flight, ignore concurrent taps
    if (state.isAcceptingRide || state.isDecliningRide) return;

    emit(
      state.copyWith(
        decliningRideId: event.rideId,
        clearError: true,
        clearRejectedRide: true,
      ),
    );

    try {
      final cleanToken = driverToken.trim().replaceFirst(
        RegExp(r'^bearer\s+', caseSensitive: false),
        '',
      );
      final token = cleanToken.isNotEmpty
          ? cleanToken
          : AvailableRidesRemoteDataSourceImpl.defaultDriverToken;

      final rejected = rejectRideUseCase != null
          ? await rejectRideUseCase!(
              RejectRideParams(
                rideId: event.rideId,
                token: token,
                reason: event.reason,
              ),
            )
          : await remoteDataSource.rejectRide(
              rideId: event.rideId,
              token: token,
              reason: event.reason,
            );

      // Remove the declined ride from availableRides list
      final updatedList = state.availableRides
          .where((r) => r.id != event.rideId)
          .toList();
      final clearAlert = state.newRideAlert?.id == event.rideId;

      emit(
        state.copyWith(
          clearDecliningRideId: true,
          rejectedRide: rejected,
          availableRides: updatedList,
          clearNewRideAlert: clearAlert,
          clearError: true,
        ),
      );
    } catch (e) {
      log('❌ [HomeBloc] Failed to decline ride: $e');
      emit(
        state.copyWith(
          clearDecliningRideId: true,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  void _onClearRejectedRide(
    ClearRejectedRideEvent event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(clearRejectedRide: true));
  }

  Future<void> _onAcceptRide(
    AcceptRideEvent event,
    Emitter<HomeState> emit,
  ) async {
    // If an accept or decline is already in-flight, ignore concurrent taps
    if (state.isAcceptingRide || state.isDecliningRide) return;

    emit(state.copyWith(acceptingRideId: event.rideId, clearError: true));

    try {
      final cleanToken = driverToken.trim().replaceFirst(
        RegExp(r'^bearer\s+', caseSensitive: false),
        '',
      );
      final token = cleanToken.isNotEmpty
          ? cleanToken
          : AvailableRidesRemoteDataSourceImpl.defaultDriverToken;

      final accepted = acceptRideUseCase != null
          ? await acceptRideUseCase!(
              AcceptRideParams(rideId: event.rideId, token: token),
            )
          : await remoteDataSource.acceptRide(
              rideId: event.rideId,
              token: token,
            );

      // Remove the accepted ride from availableRides list
      final updatedList = state.availableRides
          .where((r) => r.id != event.rideId)
          .toList();
      final clearAlert = state.newRideAlert?.id == event.rideId;

      emit(
        state.copyWith(
          clearAcceptingRideId: true,
          acceptedRide: accepted,
          availableRides: updatedList,
          clearNewRideAlert: clearAlert,
          clearError: true,
        ),
      );
    } catch (e) {
      log('❌ [HomeBloc] Failed to accept ride: $e');
      emit(
        state.copyWith(
          clearAcceptingRideId: true,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  void _onClearAcceptedRide(
    ClearAcceptedRideEvent event,
    Emitter<HomeState> emit,
  ) {
    emit(state.copyWith(clearAcceptedRide: true));
  }

  @override
  Future<void> close() {
    _detachSocketListener();
    _connectedSubscription?.cancel();
    _rideNewAvailableSubscription?.cancel();
    _audioPlayer.dispose();
    return super.close();
  }
}
