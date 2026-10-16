import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/trip_remote_data_source.dart';
import '../../domain/entities/trip_entity.dart';
import '../../domain/repositories/trip_repository.dart';
import '../../domain/usecases/get_driver_bookings_usecase.dart';
import 'trip_event.dart';
import 'trip_state.dart';

class TripBloc extends Bloc<TripEvent, TripState> {
  final GetDriverBookingsUseCase? getDriverBookingsUseCase;
  final TripRepository? tripRepository;
  final TripRemoteDataSource _remoteDataSource;
  final String? driverToken;

  TripBloc({
    this.getDriverBookingsUseCase,
    this.tripRepository,
    TripRemoteDataSource? remoteDataSource,
    this.driverToken,
  })  : _remoteDataSource = remoteDataSource ?? TripRemoteDataSourceImpl(),
        super(const TripState()) {
    on<LoadTripsEvent>(_onLoadTrips);
    on<RefreshTripsEvent>(_onRefreshTrips);
    on<FilterTripsEvent>(_onFilterTrips);
    on<SearchTripsEvent>(_onSearchTrips);
  }

  Future<void> _onLoadTrips(
    LoadTripsEvent event,
    Emitter<TripState> emit,
  ) async {
    if (!event.silent) {
      emit(state.copyWith(isLoading: true, clearError: true));
    }

    try {
      final token = event.token ?? driverToken;
      final trips = await _fetchBookings(token);

      final filtered = _applyFilter(
        trips,
        state.filterType,
        state.searchQuery,
      );

      emit(
        state.copyWith(
          isLoading: false,
          trips: trips,
          filteredTrips: filtered,
          clearError: true,
        ),
      );
    } catch (e) {
      log('❌ [TripBloc] Failed to load trips: $e');
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onRefreshTrips(
    RefreshTripsEvent event,
    Emitter<TripState> emit,
  ) async {
    emit(state.copyWith(isRefreshing: true, clearError: true));

    try {
      final token = event.token ?? driverToken;
      final trips = await _fetchBookings(token);

      final filtered = _applyFilter(
        trips,
        state.filterType,
        state.searchQuery,
      );

      emit(
        state.copyWith(
          isRefreshing: false,
          trips: trips,
          filteredTrips: filtered,
          clearError: true,
        ),
      );
    } catch (e) {
      log('❌ [TripBloc] Failed to refresh trips: $e');
      emit(
        state.copyWith(
          isRefreshing: false,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  void _onFilterTrips(
    FilterTripsEvent event,
    Emitter<TripState> emit,
  ) {
    final filtered = _applyFilter(
      state.trips,
      event.filterType,
      state.searchQuery,
    );
    emit(
      state.copyWith(
        filterType: event.filterType,
        filteredTrips: filtered,
      ),
    );
  }

  void _onSearchTrips(
    SearchTripsEvent event,
    Emitter<TripState> emit,
  ) {
    final filtered = _applyFilter(
      state.trips,
      state.filterType,
      event.query,
    );
    emit(
      state.copyWith(
        searchQuery: event.query,
        filteredTrips: filtered,
      ),
    );
  }

  Future<List<TripEntity>> _fetchBookings(String? token) async {
    if (getDriverBookingsUseCase != null) {
      return await getDriverBookingsUseCase!(
        GetDriverBookingsParams(token: token),
      );
    }
    if (tripRepository != null) {
      return await tripRepository!.getDriverBookings(token: token);
    }
    return await _remoteDataSource.getDriverBookings(token: token);
  }

  List<TripEntity> _applyFilter(
    List<TripEntity> allTrips,
    String filterType,
    String searchQuery,
  ) {
    var result = allTrips;

    // Filter by tab
    if (filterType != 'All') {
      result = result.where((t) => t.status == filterType).toList();
    }

    // Filter by search query
    final query = searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((t) {
        final bookingId = t.bookingId.toLowerCase();
        final customer = t.customerName.toLowerCase();
        final pickup = t.pickupAddress.toLowerCase();
        final drop = t.dropAddress.toLowerCase();
        return bookingId.contains(query) ||
            customer.contains(query) ||
            pickup.contains(query) ||
            drop.contains(query);
      }).toList();
    }

    return result;
  }
}
