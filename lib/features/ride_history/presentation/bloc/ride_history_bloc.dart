import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_ride_history_usecase.dart';
import 'ride_history_event.dart';
import 'ride_history_state.dart';

class RideHistoryBloc extends Bloc<RideHistoryEvent, RideHistoryState> {
  final GetRideHistoryUseCase getRideHistoryUseCase;

  RideHistoryBloc({required this.getRideHistoryUseCase}) : super(RideHistoryInitial()) {
    on<LoadRideHistory>((event, emit) async {
      emit(RideHistoryLoading());
      try {
        final history = await getRideHistoryUseCase();
        emit(RideHistoryLoaded(history));
      } catch (e) {
        emit(RideHistoryError(e.toString()));
      }
    });
  }
}
