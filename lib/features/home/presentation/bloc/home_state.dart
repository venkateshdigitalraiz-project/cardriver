import 'package:equatable/equatable.dart';

class HomeState extends Equatable {
  final bool isOnline;
  final double todaysEarnings;
  final int todaysTrips;
  final double rating;

  const HomeState({
    this.isOnline = false,
    this.todaysEarnings = 0.0,
    this.todaysTrips = 0,
    this.rating = 5.0,
  });

  HomeState copyWith({
    bool? isOnline,
    double? todaysEarnings,
    int? todaysTrips,
    double? rating,
  }) {
    return HomeState(
      isOnline: isOnline ?? this.isOnline,
      todaysEarnings: todaysEarnings ?? this.todaysEarnings,
      todaysTrips: todaysTrips ?? this.todaysTrips,
      rating: rating ?? this.rating,
    );
  }

  @override
  List<Object> get props => [isOnline, todaysEarnings, todaysTrips, rating];
}
