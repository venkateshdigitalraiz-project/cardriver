import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/driver_job_entity.dart';
import '../../domain/usecases/get_driver_job_details_usecase.dart';
import 'driver_job_details_event.dart';
import 'driver_job_details_state.dart';

class DriverJobDetailsBloc
    extends Bloc<DriverJobDetailsEvent, DriverJobDetailsState> {
  final GetDriverJobDetailsUseCase getDriverJobDetailsUseCase;
  final String? driverToken;

  DriverJobDetailsBloc({
    required this.getDriverJobDetailsUseCase,
    this.driverToken,
    DriverJobEntity? initialJob,
  }) : super(DriverJobDetailsState(
          job: initialJob,
          status: initialJob != null
              ? DriverJobDetailsStatus.loaded
              : DriverJobDetailsStatus.initial,
        )) {
    on<LoadDriverJobDetailsEvent>(_onLoadDriverJobDetails);
    on<ApplyDriverJobDetailsEvent>(_onApplyDriverJobDetails);
  }

  Future<void> _onLoadDriverJobDetails(
    LoadDriverJobDetailsEvent event,
    Emitter<DriverJobDetailsState> emit,
  ) async {
    if (event.refresh) {
      emit(state.copyWith(isRefreshing: true, clearError: true));
    } else if (state.job == null) {
      emit(state.copyWith(
          status: DriverJobDetailsStatus.loading, clearError: true));
    }

    try {
      final job = await getDriverJobDetailsUseCase(
        event.jobId,
        token: event.token ?? driverToken,
      );

      emit(state.copyWith(
        status: DriverJobDetailsStatus.loaded,
        job: job,
        isRefreshing: false,
      ));
    } catch (e) {
      if (state.job == null) {
        emit(state.copyWith(
          status: DriverJobDetailsStatus.failure,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
          isRefreshing: false,
        ));
      } else {
        emit(state.copyWith(isRefreshing: false));
      }
    }
  }

  Future<void> _onApplyDriverJobDetails(
    ApplyDriverJobDetailsEvent event,
    Emitter<DriverJobDetailsState> emit,
  ) async {
    emit(state.copyWith(isApplying: true, clearError: true));

    // Simulate / execute application
    await Future.delayed(const Duration(milliseconds: 600));

    emit(state.copyWith(
      status: DriverJobDetailsStatus.applied,
      isApplying: false,
      successMessage: 'Your application has been submitted successfully!',
    ));
  }
}

