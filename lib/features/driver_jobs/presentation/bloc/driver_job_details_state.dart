import 'package:equatable/equatable.dart';
import '../../domain/entities/driver_job_entity.dart';

enum DriverJobDetailsStatus { initial, loading, loaded, failure, applied }

class DriverJobDetailsState extends Equatable {
  final DriverJobDetailsStatus status;
  final DriverJobEntity? job;
  final String? errorMessage;
  final String? successMessage;
  final bool isRefreshing;
  final bool isApplying;

  const DriverJobDetailsState({
    this.status = DriverJobDetailsStatus.initial,
    this.job,
    this.errorMessage,
    this.successMessage,
    this.isRefreshing = false,
    this.isApplying = false,
  });

  bool get isLoading =>
      status == DriverJobDetailsStatus.loading && !isRefreshing;
  bool get isLoaded => status == DriverJobDetailsStatus.loaded;
  bool get isFailure => status == DriverJobDetailsStatus.failure;
  bool get isApplied => status == DriverJobDetailsStatus.applied;

  DriverJobDetailsState copyWith({
    DriverJobDetailsStatus? status,
    DriverJobEntity? job,
    String? errorMessage,
    String? successMessage,
    bool? isRefreshing,
    bool? isApplying,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return DriverJobDetailsState(
      status: status ?? this.status,
      job: job ?? this.job,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isApplying: isApplying ?? this.isApplying,
    );
  }

  @override
  List<Object?> get props => [
        status,
        job,
        errorMessage,
        successMessage,
        isRefreshing,
        isApplying,
      ];
}

