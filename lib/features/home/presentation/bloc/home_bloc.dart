import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState(todaysEarnings: 9640, todaysTrips: 8, rating: 4.8)) {
    on<ToggleOnlineStatusEvent>((event, emit) {
      emit(state.copyWith(
        isOnline: !state.isOnline, 
        activeRequestIds: !state.isOnline ? const ['req_1', 'req_2', 'req_3'] : state.activeRequestIds
      ));
    });
    
    on<DeclineRideRequestEvent>((event, emit) {
      final updatedIds = List<String>.from(state.activeRequestIds)..remove(event.requestId);
      emit(state.copyWith(activeRequestIds: updatedIds));
    });
  }
}
