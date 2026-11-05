import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/accept_driver_job_usecase.dart';
import '../../domain/usecases/get_driver_job_details_usecase.dart';
import '../../domain/usecases/get_driver_jobs_usecase.dart';
import '../../domain/usecases/reject_driver_job_usecase.dart';
import 'driver_jobs_event.dart';
import 'driver_jobs_state.dart';

class DriverJobsBloc extends Bloc<DriverJobsEvent, DriverJobsState> {
  final GetDriverJobsUseCase getDriverJobsUseCase;
  final GetDriverJobDetailsUseCase getDriverJobDetailsUseCase;
  final AcceptDriverJobUseCase acceptDriverJobUseCase;
  final RejectDriverJobUseCase rejectDriverJobUseCase;
  final String? driverToken;

  DriverJobsBloc({
    required this.getDriverJobsUseCase,
    required this.getDriverJobDetailsUseCase,
    required this.acceptDriverJobUseCase,
    required this.rejectDriverJobUseCase,
    this.driverToken,
  }) : super(const DriverJobsState()) {
    on<LoadDriverJobsEvent>(_onLoadDriverJobs);
    on<SearchDriverJobsEvent>(_onSearchDriverJobs);
    on<FilterDriverJobsTypeEvent>(_onFilterDriverJobsType);
    on<AcceptDriverJobEvent>(_onAcceptDriverJob);
    on<RejectDriverJobEvent>(_onRejectDriverJob);
  }

  Future<void> _onLoadDriverJobs(
    LoadDriverJobsEvent event,
    Emitter<DriverJobsState> emit,
  ) async {
    if (event.refresh) {
      emit(state.copyWith(isRefreshing: true, clearError: true));
    } else {
      emit(state.copyWith(status: DriverJobsStatus.loading, clearError: true));
    }

    try {
      final response = await getDriverJobsUseCase(
        token: event.token ?? driverToken,
        page: event.page,
        limit: event.limit,
        search: state.searchQuery,
        jobType: state.selectedJobType,
      );

      emit(state.copyWith(
        status: DriverJobsStatus.loaded,
        jobs: response.jobs,
        total: response.total,
        page: response.page,
        isRefreshing: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DriverJobsStatus.failure,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
        isRefreshing: false,
      ));
    }
  }

  Future<void> _onSearchDriverJobs(
    SearchDriverJobsEvent event,
    Emitter<DriverJobsState> emit,
  ) async {
    final query = event.query.trim();
    emit(state.copyWith(searchQuery: query));

    if (query.isEmpty) {
      try {
        final response = await getDriverJobsUseCase(
          token: driverToken,
          page: 1,
          limit: 10,
          jobType: state.selectedJobType,
        );
        emit(state.copyWith(
          jobs: response.jobs,
          total: response.total,
          page: response.page,
        ));
      } catch (_) {}
      return;
    }

    // Call /api/driver/jobs/:jobId API when search text is entered
    try {
      final singleJob = await getDriverJobDetailsUseCase(
        query,
        token: driverToken,
      );

      emit(state.copyWith(
        jobs: [singleJob],
        total: 1,
        page: 1,
      ));
    } catch (_) {
      // Fallback: If not found by specific Job ID, try search query endpoint
      try {
        final response = await getDriverJobsUseCase(
          token: driverToken,
          page: 1,
          limit: 10,
          search: query,
          jobType: state.selectedJobType,
        );

        emit(state.copyWith(
          jobs: response.jobs,
          total: response.total,
          page: response.page,
        ));
      } catch (_) {
        emit(state.copyWith(jobs: [], total: 0, page: 1));
      }
    }
  }

  Future<void> _onFilterDriverJobsType(
    FilterDriverJobsTypeEvent event,
    Emitter<DriverJobsState> emit,
  ) async {
    emit(state.copyWith(selectedJobType: event.jobType));

    try {
      final response = await getDriverJobsUseCase(
        token: driverToken,
        page: 1,
        limit: 10,
        search: state.searchQuery,
        jobType: event.jobType,
      );

      emit(state.copyWith(
        jobs: response.jobs,
        total: response.total,
        page: response.page,
      ));
    } catch (_) {}
  }

  Future<void> _onAcceptDriverJob(
    AcceptDriverJobEvent event,
    Emitter<DriverJobsState> emit,
  ) async {
    emit(state.copyWith(actionLoadingJobId: event.jobId));

    try {
      await acceptDriverJobUseCase(
        event.jobId,
        token: event.token ?? driverToken,
      );

      final updatedActions = Map<String, String>.from(state.jobActions)
        ..[event.jobId] = 'accepted';

      emit(state.copyWith(
        clearActionLoading: true,
        jobActions: updatedActions,
        actionMessage: 'Job post accepted successfully.',
      ));
    } catch (_) {
      final updatedActions = Map<String, String>.from(state.jobActions)
        ..[event.jobId] = 'accepted';

      emit(state.copyWith(
        clearActionLoading: true,
        jobActions: updatedActions,
        actionMessage: 'Job post accepted.',
      ));
    }
  }

  Future<void> _onRejectDriverJob(
    RejectDriverJobEvent event,
    Emitter<DriverJobsState> emit,
  ) async {
    print('📦 [DriverJobsBloc] RejectDriverJobEvent -> JobId: ${event.jobId}, Reason: "${event.reason}"');
    emit(state.copyWith(actionLoadingJobId: event.jobId));

    try {
      final success = await rejectDriverJobUseCase(
        event.jobId,
        reason: event.reason,
        token: event.token ?? driverToken,
      );
      print('📦 [DriverJobsBloc] RejectDriverJobUseCase completed -> Result: $success');

      final updatedActions = Map<String, String>.from(state.jobActions)
        ..[event.jobId] = 'rejected';

      emit(state.copyWith(
        clearActionLoading: true,
        jobActions: updatedActions,
        actionMessage: 'Job ${event.jobId} declined.',
      ));
    } catch (e) {
      print('⚠️ [DriverJobsBloc] RejectDriverJobUseCase failed: $e');
      final updatedActions = Map<String, String>.from(state.jobActions)
        ..[event.jobId] = 'rejected';

      emit(state.copyWith(
        clearActionLoading: true,
        jobActions: updatedActions,
        actionMessage: 'Job ${event.jobId} declined.',
      ));
    }
  }
}

