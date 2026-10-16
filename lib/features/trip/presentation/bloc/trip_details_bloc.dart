import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/trip_remote_data_source.dart';
import '../../domain/entities/trip_entity.dart';
import '../../domain/repositories/trip_repository.dart';
import '../../domain/usecases/get_driver_booking_details_usecase.dart';
import 'trip_details_event.dart';
import 'trip_details_state.dart';

class TripDetailsBloc extends Bloc<TripDetailsEvent, TripDetailsState> {
  final GetDriverBookingDetailsUseCase? getDriverBookingDetailsUseCase;
  final TripRepository? tripRepository;
  final TripRemoteDataSource _remoteDataSource;
  final String? driverToken;

  TripDetailsBloc({
    this.getDriverBookingDetailsUseCase,
    this.tripRepository,
    TripRemoteDataSource? remoteDataSource,
    this.driverToken,
  })  : _remoteDataSource = remoteDataSource ?? TripRemoteDataSourceImpl(),
        super(TripDetailsInitial()) {
    on<LoadTripDetailsEvent>(_onLoadTripDetails);
    on<RefreshTripDetailsEvent>(_onRefreshTripDetails);
  }

  Future<void> _onLoadTripDetails(
    LoadTripDetailsEvent event,
    Emitter<TripDetailsState> emit,
  ) async {
    // If an initial trip was supplied, show it immediately while the fresh API call completes
    emit(TripDetailsLoading(cachedTrip: event.trip));

    final id = event.bookingId.isNotEmpty
        ? event.bookingId
        : (event.trip?.id ?? event.trip?.bookingId ?? '');

    if (id.isEmpty) {
      if (event.trip != null) {
        emit(TripDetailsLoaded(trip: event.trip!));
        return;
      }
      emit(const TripDetailsError(message: 'Invalid booking ID'));
      return;
    }

    try {
      final token = event.token ?? driverToken;
      final freshBooking = await _fetchDetails(id, token);
      emit(TripDetailsLoaded(trip: freshBooking));
    } catch (e) {
      log('❌ [TripDetailsBloc] Failed to fetch booking details for $id: $e');
      if (event.trip != null) {
        // Fallback to the available trip data so driver is never blocked
        emit(TripDetailsLoaded(trip: event.trip!));
      } else {
        emit(
          TripDetailsError(
            message: e.toString().replaceFirst('Exception: ', ''),
            cachedTrip: event.trip,
          ),
        );
      }
    }
  }

  Future<void> _onRefreshTripDetails(
    RefreshTripDetailsEvent event,
    Emitter<TripDetailsState> emit,
  ) async {
    final currentTrip = state is TripDetailsLoaded ? (state as TripDetailsLoaded).trip : null;
    if (currentTrip != null) {
      emit(TripDetailsLoaded(trip: currentTrip, isRefreshing: true));
    }

    try {
      final token = event.token ?? driverToken;
      final freshBooking = await _fetchDetails(event.bookingId, token);
      emit(TripDetailsLoaded(trip: freshBooking));
    } catch (e) {
      log('❌ [TripDetailsBloc] Failed to refresh booking details: $e');
      if (currentTrip != null) {
        emit(TripDetailsLoaded(trip: currentTrip));
      } else {
        emit(
          TripDetailsError(
            message: e.toString().replaceFirst('Exception: ', ''),
          ),
        );
      }
    }
  }

  Future<TripEntity> _fetchDetails(String bookingId, String? token) async {
    if (getDriverBookingDetailsUseCase != null) {
      return await getDriverBookingDetailsUseCase!(
        GetDriverBookingDetailsParams(bookingId: bookingId, token: token),
      );
    }
    if (tripRepository != null) {
      return await tripRepository!.getDriverBookingDetails(
        bookingId: bookingId,
        token: token,
      );
    }
    return await _remoteDataSource.getDriverBookingDetails(
      bookingId: bookingId,
      token: token,
    );
  }
}
