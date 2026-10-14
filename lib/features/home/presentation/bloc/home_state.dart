import 'package:equatable/equatable.dart';
import '../../domain/entities/available_ride_entity.dart';

class HomeState extends Equatable {
  final bool isOnline;
  final double todaysEarnings;
  final int todaysTrips;
  final double rating;
  final bool hasRideRequest;
  final List<String> activeRequestIds;
  final List<AvailableRideEntity> availableRides;
  final Set<String> declinedRideIds;
  final bool isLoadingRides;
  final String? errorMessage;
  final AvailableRideEntity? newRideAlert;

  const HomeState({
    this.isOnline = false,
    this.todaysEarnings = 9640.0,
    this.todaysTrips = 0,
    this.rating = 5.0,
    this.hasRideRequest = false,
    this.activeRequestIds = const [],
    this.availableRides = const [],
    this.declinedRideIds = const {},
    this.isLoadingRides = false,
    this.errorMessage,
    this.newRideAlert,
  });

  HomeState copyWith({
    bool? isOnline,
    double? todaysEarnings,
    int? todaysTrips,
    double? rating,
    bool? hasRideRequest,
    List<String>? activeRequestIds,
    List<AvailableRideEntity>? availableRides,
    Set<String>? declinedRideIds,
    bool? isLoadingRides,
    String? errorMessage,
    bool clearError = false,
    AvailableRideEntity? newRideAlert,
    bool clearNewRideAlert = false,
  }) {
    return HomeState(
      isOnline: isOnline ?? this.isOnline,
      todaysEarnings: todaysEarnings ?? this.todaysEarnings,
      todaysTrips: todaysTrips ?? this.todaysTrips,
      rating: rating ?? this.rating,
      hasRideRequest: hasRideRequest ?? this.hasRideRequest,
      activeRequestIds: activeRequestIds ?? this.activeRequestIds,
      availableRides: availableRides ?? this.availableRides,
      declinedRideIds: declinedRideIds ?? this.declinedRideIds,
      isLoadingRides: isLoadingRides ?? this.isLoadingRides,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      newRideAlert: clearNewRideAlert ? null : (newRideAlert ?? this.newRideAlert),
    );
  }

  @override
  List<Object?> get props => [
        isOnline,
        todaysEarnings,
        todaysTrips,
        rating,
        hasRideRequest,
        activeRequestIds,
        availableRides,
        declinedRideIds,
        isLoadingRides,
        errorMessage,
        newRideAlert,
      ];
}
