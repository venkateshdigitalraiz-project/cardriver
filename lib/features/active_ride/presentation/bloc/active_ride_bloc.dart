import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_route_usecase.dart';
import 'active_ride_event.dart';
import 'active_ride_state.dart';

class ActiveRideBloc extends Bloc<ActiveRideEvent, ActiveRideState> {
  final GetRouteUseCase getRouteUseCase;

  ActiveRideBloc({required this.getRouteUseCase}) : super(ActiveRideInitial()) {
    on<LoadRouteEvent>(_onLoadRouteEvent);
  }

  Future<void> _onLoadRouteEvent(
    LoadRouteEvent event,
    Emitter<ActiveRideState> emit,
  ) async {
    emit(ActiveRideLoading());
    try {
      final route = await getRouteUseCase.execute(
        event.startLocation,
        event.endLocation,
      );
      emit(ActiveRideLoaded(route: route));
    } catch (e) {
      emit(ActiveRideError(message: e.toString()));
    }
  }
}
