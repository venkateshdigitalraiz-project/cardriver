import 'package:equatable/equatable.dart';
import '../../domain/entities/available_ride_entity.dart';

class HomeState extends Equatable {
  final bool isOnline;
  final bool isLoadingRides;
  final List<AvailableRideEntity> availableRides;
  final AvailableRideEntity? newRideAlert;
  final String? errorMessage;
  final double todaysEarnings;
  final int todaysTrips;
  final double rating;

  const HomeState({
    this.isOnline = false,
    this.isLoadingRides = false,
    this.availableRides = const [],
    this.newRideAlert,
    this.errorMessage,
    this.todaysEarnings = 9640.0,
    this.todaysTrips = 8,
    this.rating = 4.8,
  });

  /// Convenience getters for UI compatibility
  bool get hasRideRequest => availableRides.isNotEmpty;
  List<String> get activeRequestIds => availableRides.map((r) => r.id).toList();

  HomeState copyWith({
    bool? isOnline,
    bool? isLoadingRides,
    List<AvailableRideEntity>? availableRides,
    AvailableRideEntity? newRideAlert,
    bool clearNewRideAlert = false,
    String? errorMessage,
    bool clearError = false,
    double? todaysEarnings,
    int? todaysTrips,
    double? rating,
  }) {
    return HomeState(
      isOnline: isOnline ?? this.isOnline,
      isLoadingRides: isLoadingRides ?? this.isLoadingRides,
      availableRides: availableRides ?? this.availableRides,
      newRideAlert:
          clearNewRideAlert ? null : (newRideAlert ?? this.newRideAlert),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      todaysEarnings: todaysEarnings ?? this.todaysEarnings,
      todaysTrips: todaysTrips ?? this.todaysTrips,
      rating: rating ?? this.rating,
    );
  }

  @override
  List<Object?> get props => [
        isOnline,
        isLoadingRides,
        availableRides,
        newRideAlert,
        errorMessage,
        todaysEarnings,
        todaysTrips,
        rating,
      ];
}
