import '../../domain/entities/ride_history_entity.dart';

abstract class RideHistoryState {}

class RideHistoryInitial extends RideHistoryState {}

class RideHistoryLoading extends RideHistoryState {}

class RideHistoryLoaded extends RideHistoryState {
  final List<RideHistoryEntity> history;
  RideHistoryLoaded(this.history);
}

class RideHistoryError extends RideHistoryState {
  final String message;
  RideHistoryError(this.message);
}
