import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState(todaysEarnings: 120.50, todaysTrips: 8, rating: 4.8)) {
    on<ToggleOnlineStatusEvent>((event, emit) {
      emit(state.copyWith(isOnline: !state.isOnline));
    });
  }
}
