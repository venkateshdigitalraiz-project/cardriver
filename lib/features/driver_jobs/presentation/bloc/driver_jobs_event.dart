import 'package:equatable/equatable.dart';

abstract class DriverJobsEvent extends Equatable {
  const DriverJobsEvent();

  @override
  List<Object?> get props => [];
}

class LoadDriverJobsEvent extends DriverJobsEvent {
  final bool refresh;
  final int page;
  final int limit;
  final String? token;

  const LoadDriverJobsEvent({
    this.refresh = false,
    this.page = 1,
    this.limit = 10,
    this.token,
  });

  @override
  List<Object?> get props => [refresh, page, limit, token];
}

class SearchDriverJobsEvent extends DriverJobsEvent {
  final String query;

  const SearchDriverJobsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterDriverJobsTypeEvent extends DriverJobsEvent {
  final String jobType; // 'all', 'full_time', 'part_time', 'contract'

  const FilterDriverJobsTypeEvent(this.jobType);

  @override
  List<Object?> get props => [jobType];
}

class AcceptDriverJobEvent extends DriverJobsEvent {
  final String jobId;
  final String? token;

  const AcceptDriverJobEvent(this.jobId, {this.token});

  @override
  List<Object?> get props => [jobId, token];
}

class RejectDriverJobEvent extends DriverJobsEvent {
  final String jobId;
  final String? reason;
  final String? token;

  const RejectDriverJobEvent(this.jobId, {this.reason, this.token});

  @override
  List<Object?> get props => [jobId, reason, token];
}

