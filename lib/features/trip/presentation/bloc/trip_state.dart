import 'package:equatable/equatable.dart';
import '../../domain/entities/trip_entity.dart';
import '../../domain/entities/trip_status_update_result.dart';

class TripState extends Equatable {
  final bool isLoading;
  final bool isRefreshing;
  final List<TripEntity> trips;
  final List<TripEntity> filteredTrips;
  final String filterType;
  final String searchQuery;
  final String? errorMessage;
  final String? updatingBookingId;
  final String? statusSuccessMessage;
  final String? statusErrorMessage;
  final TripStatusUpdateResult? lastCompletedTripResult;

  const TripState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.trips = const [],
    this.filteredTrips = const [],
    this.filterType = 'All',
    this.searchQuery = '',
    this.errorMessage,
    this.updatingBookingId,
    this.statusSuccessMessage,
    this.statusErrorMessage,
    this.lastCompletedTripResult,
  });

  // Category counts
  int get totalCount => trips.length;
  int get upcomingCount => trips.where((t) => t.status == 'Upcoming').length;
  int get completedCount => trips.where((t) => t.status == 'Completed').length;
  int get cancelledCount => trips.where((t) => t.status == 'Cancelled').length;

  TripState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    List<TripEntity>? trips,
    List<TripEntity>? filteredTrips,
    String? filterType,
    String? searchQuery,
    String? errorMessage,
    bool clearError = false,
    String? updatingBookingId,
    bool clearUpdatingBookingId = false,
    String? statusSuccessMessage,
    String? statusErrorMessage,
    bool clearStatusMessages = false,
    TripStatusUpdateResult? lastCompletedTripResult,
    bool clearLastCompletedTripResult = false,
  }) {
    return TripState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      trips: trips ?? this.trips,
      filteredTrips: filteredTrips ?? this.filteredTrips,
      filterType: filterType ?? this.filterType,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      updatingBookingId: clearUpdatingBookingId
          ? null
          : (updatingBookingId ?? this.updatingBookingId),
      statusSuccessMessage: clearStatusMessages
          ? null
          : (statusSuccessMessage ?? this.statusSuccessMessage),
      statusErrorMessage: clearStatusMessages
          ? null
          : (statusErrorMessage ?? this.statusErrorMessage),
      lastCompletedTripResult: clearLastCompletedTripResult
          ? null
          : (lastCompletedTripResult ?? this.lastCompletedTripResult),
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isRefreshing,
        trips,
        filteredTrips,
        filterType,
        searchQuery,
        errorMessage,
        updatingBookingId,
        statusSuccessMessage,
        statusErrorMessage,
        lastCompletedTripResult,
      ];
}
