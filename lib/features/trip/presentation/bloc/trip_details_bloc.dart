import 'package:flutter_bloc/flutter_bloc.dart';
import 'trip_details_event.dart';
import 'trip_details_state.dart';

class TripDetailsBloc extends Bloc<TripDetailsEvent, TripDetailsState> {
  TripDetailsBloc() : super(TripDetailsInitial()) {
    on<LoadTripDetailsEvent>((event, emit) async {
      emit(TripDetailsLoading());
      try {
        // Simulate network delay for loading details
        await Future.delayed(const Duration(milliseconds: 300));
        emit(TripDetailsLoaded(trip: event.trip));
      } catch (e) {
        emit(const TripDetailsError(message: 'Failed to load trip details'));
      }
    });
  }
}
