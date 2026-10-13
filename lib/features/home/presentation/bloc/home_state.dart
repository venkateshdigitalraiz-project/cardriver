import 'package:equatable/equatable.dart';

class HomeState extends Equatable {
  final bool isOnline;
  final double todaysEarnings;
  final int todaysTrips;
  final double rating;
  final bool hasRideRequest;
  final List<String> activeRequestIds;

  const HomeState({
    this.isOnline = false,
    this.todaysEarnings = 9640.0,
    this.todaysTrips = 0,
    this.rating = 5.0,
    this.hasRideRequest = true,
    this.activeRequestIds = const ['req_1', 'req_2', 'req_3'],
  });

  HomeState copyWith({
    bool? isOnline,
    double? todaysEarnings,
    int? todaysTrips,
    double? rating,
    bool? hasRideRequest,
    List<String>? activeRequestIds,
  }) {
    return HomeState(
      isOnline: isOnline ?? this.isOnline,
      todaysEarnings: todaysEarnings ?? this.todaysEarnings,
      todaysTrips: todaysTrips ?? this.todaysTrips,
      rating: rating ?? this.rating,
      hasRideRequest: hasRideRequest ?? this.hasRideRequest,
      activeRequestIds: activeRequestIds ?? this.activeRequestIds,
    );
  }

  @override
  List<Object> get props => [isOnline, todaysEarnings, todaysTrips, rating, hasRideRequest, activeRequestIds];
}
