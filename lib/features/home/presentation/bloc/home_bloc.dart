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
import '../../domain/usecases/create_manual_ride_usecase.dart';
import '../../domain/usecases/reject_ride_usecase.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AvailableRidesRemoteDataSource remoteDataSource;
  final SocketService socketService;
  final String driverToken;
  final AcceptRideUseCase? acceptRideUseCase;
  final RejectRideUseCase? rejectRideUseCase;
  final CreateManualRideUseCase createManualRideUseCase;

  StreamSubscription<void>? _connectedSubscription;
  StreamSubscription<dynamic>? _rideNewAvailableSubscription;
  DateTime? _lastRefreshTime;
  String? _lastPayload;
  final Set<String> _assignedRideIds = {};
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _lastSoundEventRideId;
  DateTime? _lastSoundPlayedTime;

  HomeBloc({
    required this.remoteDataSource,
    required this.socketService,
    required this.driverToken,
    this.acceptRideUseCase,
    this.rejectRideUseCase,
    CreateManualRideUseCase? createManualRideUseCase,
  }) : createManualRideUseCase =
           createManualRideUseCase ?? const CreateManualRideUseCase(),
       super(const HomeState()) {
    // 1. Register Bloc event handlers

    // 2. Register Bloc event handlers
    on<ToggleOnlineStatusEvent>(_onToggleOnlineStatus);
    on<LoadAvailableRidesEvent>(_onLoadAvailableRides);
    on<NewRideReceivedEvent>(_onNewRideReceived);
    on<RemoveRideEvent>(_onRemoveRide);
    on<ClearNewRideAlertEvent>(_onClearNewRideAlert);
    on<DeclineRideRequestEvent>(_onDeclineRideRequest);
    on<ClearRejectedRideEvent>(_onClearRejectedRide);
    on<AcceptRideEvent>(_onAcceptRide);
    on<ClearAcceptedRideEvent>(_onClearAcceptedRide);
    on<CreateManualRideEvent>(_onCreateManualRide);

    // 3. Listen to socket connection / reconnection
    _connectedSubscription = socketService.onConnected.listen((_) {
      if (state.isOnline) {
        log(
          '🔄 [HomeBloc] Socket connected/reconnected while online. Refreshing home page.',
        );
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

  void _attachSocketListener() {}

  void _detachSocketListener() {}

  /// Handles incoming 'ride:new_available' socket event.
  /// Refreshes the driver app home page so up-to-date rides are displayed.
  void _handleRideNewAvailable(dynamic data) {
    // 1. Debounce only exact duplicate payloads within 1.5s
    final payloadStr = data?.toString() ?? '';
    final now = DateTime.now();
    if (payloadStr.isNotEmpty &&
        _lastPayload == payloadStr &&
        _lastRefreshTime != null &&
        now.difference(_lastRefreshTime!).inMilliseconds < 1500) {
      log('⏱️ [HomeBloc] Duplicate identical "ride:new_available" ignored');
      return;
    }
    _lastPayload = payloadStr;
    _lastRefreshTime = now;

    log(
      '🚗 [HomeBloc] "ride:new_available" event detected! Refreshing home page...',
    );

    // 2. If payload contains a ride entity or assignment status, process it
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
          } else if (parsed['booking'] is Map) {
            rideMap = Map<String, dynamic>.from(parsed['booking']);
          } else if (parsed['data'] is Map) {
            final inner = parsed['data'] as Map;
            if (inner['ride'] is Map) {
              rideMap = Map<String, dynamic>.from(inner['ride']);
            } else if (inner['booking'] is Map) {
              rideMap = Map<String, dynamic>.from(inner['booking']);
            } else {
              rideMap = Map<String, dynamic>.from(inner);
            }
          } else if (parsed['id'] != null ||
              parsed['_id'] != null ||
              parsed['bookingId'] != null ||
              parsed['booking_id'] != null ||
              parsed['rideId'] != null) {
            rideMap = Map<String, dynamic>.from(parsed);
          }

          if (rideMap != null) {
            // Check status: if ride is already assigned, accepted, or completed, remove it!
            final status = (rideMap['status'] ??
                    rideMap['bookingStatus'] ??
                    rideMap['booking_status'] ??
                    '')
                .toString()
                .toLowerCase();

            final isUnavailable = status == 'driver_assigned' ||
                status == 'accepted' ||
                status == 'assigned' ||
                status == 'completed' ||
                status == 'cancelled' ||
                status == 'canceled' ||
                status == 'in_progress' ||
                status == 'started' ||
                status == 'declined' ||
                status == 'rejected' ||
                (rideMap['driverId'] != null &&
                    rideMap['driverId'].toString().isNotEmpty &&
                    status != 'pending');

            final rideId = rideMap['id']?.toString() ??
                rideMap['_id']?.toString() ??
                rideMap['bookingMongoId']?.toString() ??
                '';
            final bookingId = rideMap['bookingId']?.toString() ??
                rideMap['booking_id']?.toString() ??
                '';

            if (isUnavailable) {
              log('🚫 [HomeBloc] Ride is no longer available ($status). Removing from home: id=$rideId, bookingId=$bookingId');
              if (rideId.isNotEmpty) _assignedRideIds.add(rideId);
              if (bookingId.isNotEmpty) _assignedRideIds.add(bookingId);
              add(RemoveRideEvent(rideId: rideId, bookingId: bookingId));
              return;
            }

            if (rideId.isNotEmpty) _assignedRideIds.remove(rideId);
            if (bookingId.isNotEmpty) _assignedRideIds.remove(bookingId);

            // Genuinely available new ride: play sound and add to state
            _playNotificationSound(data);

            final ride = AvailableRideEntity.fromJson(rideMap);
            if (ride.id.isNotEmpty || ride.bookingId.isNotEmpty) {
              log(
                '✨ [HomeBloc] Instant new ride alert from socket payload: ${ride.id.isNotEmpty ? ride.id : ride.bookingId}',
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

    // 3. Always refresh available rides from API so the home page is 100% up-to-date
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
              data['ride']['id']?.toString() ?? data['ride']['_id']?.toString();
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

  /// Returns true if two ride entities represent the same booking.
  bool _isSameRide(AvailableRideEntity a, AvailableRideEntity b) {
    if (a.id.isNotEmpty && b.id.isNotEmpty && a.id == b.id) return true;
    if (a.bookingId.isNotEmpty &&
        b.bookingId.isNotEmpty &&
        a.bookingId == b.bookingId) {
      return true;
    }
    if (a.id.isNotEmpty && b.bookingId.isNotEmpty && a.id == b.bookingId) {
      return true;
    }
    if (a.bookingId.isNotEmpty && b.id.isNotEmpty && a.bookingId == b.id) {
      return true;
    }
    return false;
  }

  /// Checks if a ride matches a given identifier (either id or bookingId).
  bool _matchesRideId(AvailableRideEntity r, String id) {
    if (id.isEmpty) return false;
    return r.id == id || r.bookingId == id;
  }

  /// Removes any duplicate ride entries based on booking and ride IDs.
  List<AvailableRideEntity> _deduplicateRides(List<AvailableRideEntity> rides) {
    final List<AvailableRideEntity> unique = [];
    for (final ride in rides) {
      if (!unique.any((existing) => _isSameRide(existing, ride))) {
        unique.add(ride);
      }
    }
    return unique;
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

      // Merge API rides with current valid socket rides without duplicates.
      // Filter out any rides that are in _assignedRideIds or marked unavailable.
      final List<AvailableRideEntity> combined = [];

      // 1. Authoritative rides from API
      for (final r in apiRides) {
        final st = r.bookingStatus.toLowerCase();
        final isTaken = _assignedRideIds.contains(r.id) ||
            _assignedRideIds.contains(r.bookingId) ||
            st == 'driver_assigned' ||
            st == 'accepted' ||
            st == 'completed' ||
            st == 'cancelled' ||
            st == 'rejected' ||
            st == 'declined';
        if (!isTaken && !combined.any((existing) => _isSameRide(existing, r))) {
          combined.add(r);
        }
      }

      // 2. Keep recently received socket/state rides not yet indexed in API
      for (final r in state.availableRides) {
        final st = r.bookingStatus.toLowerCase();
        final isTaken = _assignedRideIds.contains(r.id) ||
            _assignedRideIds.contains(r.bookingId) ||
            st == 'driver_assigned' ||
            st == 'accepted' ||
            st == 'completed' ||
            st == 'cancelled' ||
            st == 'rejected' ||
            st == 'declined';
        if (!isTaken && !combined.any((existing) => _isSameRide(existing, r))) {
          combined.add(r);
        }
      }

      final combinedRides = _deduplicateRides(combined);

      // Check if there are newly added rides compared to previous state
      AvailableRideEntity? newAlert = state.newRideAlert;

      // Find any newly arrived ride to trigger the alert
      for (final ride in combinedRides) {
        final wasPresent =
            state.availableRides.any((r) => _isSameRide(r, ride));
        if (!wasPresent) {
          newAlert = ride;
          break;
        }
      }

      // If no alert is currently active and rides are available, show the newest
      if (newAlert == null && combinedRides.isNotEmpty) {
        newAlert = combinedRides.first;
      }

      // If the current alert ride is no longer in the list, clear or update it
      if (newAlert != null &&
          !combinedRides.any((r) => _isSameRide(r, newAlert!))) {
        newAlert = combinedRides.isNotEmpty ? combinedRides.first : null;
      }

      emit(
        state.copyWith(
          isLoadingRides: false,
          availableRides: combinedRides,
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

  void _onRemoveRide(RemoveRideEvent event, Emitter<HomeState> emit) {
    log('🗑️ [HomeBloc] Removing ride from available list: id=${event.rideId}, bookingId=${event.bookingId}');
    final updatedList = state.availableRides.where((r) {
      if (event.rideId.isNotEmpty && _matchesRideId(r, event.rideId)) {
        return false;
      }
      if (event.bookingId != null &&
          event.bookingId!.isNotEmpty &&
          _matchesRideId(r, event.bookingId!)) {
        return false;
      }
      return true;
    }).toList();

    final clearAlert = (event.rideId.isNotEmpty &&
            state.newRideAlert != null &&
            _matchesRideId(state.newRideAlert!, event.rideId)) ||
        (event.bookingId != null &&
            event.bookingId!.isNotEmpty &&
            state.newRideAlert != null &&
            _matchesRideId(state.newRideAlert!, event.bookingId!));

    emit(
      state.copyWith(
        availableRides: _deduplicateRides(updatedList),
        clearNewRideAlert: clearAlert,
        newRideAlert: clearAlert ? null : state.newRideAlert,
      ),
    );
  }

  void _onNewRideReceived(NewRideReceivedEvent event, Emitter<HomeState> emit) {
    final existingIndex = state.availableRides.indexWhere(
      (r) => _isSameRide(r, event.ride),
    );

    if (existingIndex == -1) {
      // New ride: insert at top and trigger alert banner
      final updatedList =
          _deduplicateRides([event.ride, ...state.availableRides]);
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
      final deduplicated = _deduplicateRides(updatedList);
      emit(state.copyWith(isOnline: true, availableRides: deduplicated));
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
          .where((r) => !_matchesRideId(r, event.rideId))
          .toList();
      final clearAlert = state.newRideAlert != null &&
          _matchesRideId(state.newRideAlert!, event.rideId);

      emit(
        state.copyWith(
          clearDecliningRideId: true,
          rejectedRide: rejected,
          availableRides: _deduplicateRides(updatedList),
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
          .where((r) => !_matchesRideId(r, event.rideId))
          .toList();
      final clearAlert = state.newRideAlert != null &&
          _matchesRideId(state.newRideAlert!, event.rideId);

      emit(
        state.copyWith(
          clearAcceptingRideId: true,
          acceptedRide: accepted,
          availableRides: _deduplicateRides(updatedList),
          clearNewRideAlert: clearAlert,
          clearError: true,
        ),
      );
    } catch (e) {
      log('❌ [HomeBloc] Failed to accept ride: $e');
      final updatedList = state.availableRides
          .where((r) => !_matchesRideId(r, event.rideId))
          .toList();
      final clearAlert = state.newRideAlert != null &&
          _matchesRideId(state.newRideAlert!, event.rideId);

      emit(
        state.copyWith(
          clearAcceptingRideId: true,
          availableRides: _deduplicateRides(updatedList),
          clearNewRideAlert: clearAlert,
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

  void _onCreateManualRide(
    CreateManualRideEvent event,
    Emitter<HomeState> emit,
  ) {
    final newRide = createManualRideUseCase(
      userName: event.userName,
      mobileNumber: event.mobileNumber,
      fromAddress: event.fromAddress,
      toAddress: event.toAddress,
      price: event.price,
      dateTime: event.dateTime,
      pickupLat: event.pickupLat,
      pickupLng: event.pickupLng,
      dropLat: event.dropLat,
      dropLng: event.dropLng,
    );

    final updatedRides =
        _deduplicateRides([newRide, ...state.availableRides]);
    emit(state.copyWith(availableRides: updatedRides, newRideAlert: newRide));
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
