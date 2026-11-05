import 'package:equatable/equatable.dart';
import '../../domain/entities/driver_job_entity.dart';

enum DriverJobsStatus { initial, loading, loaded, failure }

class DriverJobsState extends Equatable {
  final DriverJobsStatus status;
  final List<DriverJobEntity> jobs;
  final String selectedJobType; // 'all', 'full_time', 'part_time', 'contract'
  final String searchQuery;
  final int total;
  final int page;
  final String? errorMessage;
  final String? actionMessage;
  final String? actionLoadingJobId;
  final Map<String, String> jobActions; // jobId -> 'accepted' | 'rejected'
  final bool isRefreshing;

  const DriverJobsState({
    this.status = DriverJobsStatus.initial,
    this.jobs = const [],
    this.selectedJobType = 'all',
    this.searchQuery = '',
    this.total = 0,
    this.page = 1,
    this.errorMessage,
    this.actionMessage,
    this.actionLoadingJobId,
    this.jobActions = const {},
    this.isRefreshing = false,
  });

  bool isJobActioned(String jobId) => jobActions.containsKey(jobId);
  String? getJobAction(String jobId) => jobActions[jobId];
  bool isActionLoading(String jobId) => actionLoadingJobId == jobId;

  bool get isLoading => status == DriverJobsStatus.loading && !isRefreshing;
  bool get isLoaded => status == DriverJobsStatus.loaded;
  bool get isFailure => status == DriverJobsStatus.failure;

  List<DriverJobEntity> get filteredJobs {
    var list = jobs;
    if (selectedJobType != 'all') {
      list = list.where((job) {
        return job.jobType.toLowerCase() == selectedJobType.toLowerCase();
      }).toList();
    }
    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      list = list.where((job) {
        final title = job.title.toLowerCase();
        final loc = job.location.toLowerCase();
        final jId = job.jobId.toLowerCase();
        final desc = job.description.toLowerCase();
        return title.contains(q) ||
            loc.contains(q) ||
            jId.contains(q) ||
            desc.contains(q);
      }).toList();
    }
    return list;
  }

  DriverJobsState copyWith({
    DriverJobsStatus? status,
    List<DriverJobEntity>? jobs,
    String? selectedJobType,
    String? searchQuery,
    int? total,
    int? page,
    String? errorMessage,
    String? actionMessage,
    String? actionLoadingJobId,
    Map<String, String>? jobActions,
    bool? isRefreshing,
    bool clearError = false,
    bool clearActionMessage = false,
    bool clearActionLoading = false,
  }) {
    return DriverJobsState(
      status: status ?? this.status,
      jobs: jobs ?? this.jobs,
      selectedJobType: selectedJobType ?? this.selectedJobType,
      searchQuery: searchQuery ?? this.searchQuery,
      total: total ?? this.total,
      page: page ?? this.page,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      actionMessage:
          clearActionMessage ? null : (actionMessage ?? this.actionMessage),
      actionLoadingJobId: clearActionLoading
          ? null
          : (actionLoadingJobId ?? this.actionLoadingJobId),
      jobActions: jobActions ?? this.jobActions,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [
        status,
        jobs,
        selectedJobType,
        searchQuery,
        total,
        page,
        errorMessage,
        actionMessage,
        actionLoadingJobId,
        jobActions,
        isRefreshing,
      ];
}

