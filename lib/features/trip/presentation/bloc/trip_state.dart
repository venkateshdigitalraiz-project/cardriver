import 'package:equatable/equatable.dart';
import '../../domain/entities/trip_entity.dart';

class TripState extends Equatable {
  final bool isLoading;
  final List<TripEntity> trips;
  final List<TripEntity> filteredTrips;
  final String filterType;
  final String? errorMessage;

  const TripState({
    this.isLoading = false,
    this.trips = const [],
    this.filteredTrips = const [],
    this.filterType = 'Upcoming',
    this.errorMessage,
  });

  TripState copyWith({
    bool? isLoading,
    List<TripEntity>? trips,
    List<TripEntity>? filteredTrips,
    String? filterType,
    String? errorMessage,
  }) {
    return TripState(
      isLoading: isLoading ?? this.isLoading,
      trips: trips ?? this.trips,
      filteredTrips: filteredTrips ?? this.filteredTrips,
      filterType: filterType ?? this.filterType,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        trips,
        filteredTrips,
        filterType,
        errorMessage,
      ];
}
