import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/trip_entity.dart';
import 'trip_event.dart';
import 'trip_state.dart';

class TripBloc extends Bloc<TripEvent, TripState> {
  TripBloc() : super(const TripState()) {
    on<LoadTripsEvent>(_onLoadTrips);
    on<FilterTripsEvent>(_onFilterTrips);
  }

  Future<void> _onLoadTrips(LoadTripsEvent event, Emitter<TripState> emit) async {
    emit(state.copyWith(isLoading: true));
    
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    final dummyTrips = [
      const TripEntity(
        id: '1',
        date: 'Today, 10:30 AM',
        fare: 15.50,
        customerName: 'Sarah Connor',
        pickupLocation: '742 Evergreen Terrace',
        destination: 'International Airport T2',
        status: 'Upcoming',
      ),
      const TripEntity(
        id: '2',
        date: 'Yesterday, 2:15 PM',
        fare: 22.00,
        customerName: 'John Doe',
        pickupLocation: 'Central Park',
        destination: 'Times Square',
        status: 'Completed',
      ),
      const TripEntity(
        id: '3',
        date: 'Oct 12, 9:00 AM',
        fare: 12.00,
        customerName: 'Alice Smith',
        pickupLocation: 'Brooklyn Bridge',
        destination: 'Empire State Building',
        status: 'Cancelled',
      ),
    ];

    final filtered = dummyTrips.where((trip) => trip.status == state.filterType).toList();

    emit(state.copyWith(
      isLoading: false,
      trips: dummyTrips,
      filteredTrips: filtered,
    ));
  }

  void _onFilterTrips(FilterTripsEvent event, Emitter<TripState> emit) {
    final filtered = state.trips.where((trip) => trip.status == event.filterType).toList();
    emit(state.copyWith(
      filterType: event.filterType,
      filteredTrips: filtered,
    ));
  }
}
