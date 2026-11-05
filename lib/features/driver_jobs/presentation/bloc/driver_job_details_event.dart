import 'package:equatable/equatable.dart';

abstract class DriverJobDetailsEvent extends Equatable {
  const DriverJobDetailsEvent();

  @override
  List<Object?> get props => [];
}

class LoadDriverJobDetailsEvent extends DriverJobDetailsEvent {
  final String jobId;
  final String? token;
  final bool refresh;

  const LoadDriverJobDetailsEvent({
    required this.jobId,
    this.token,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [jobId, token, refresh];
}

class ApplyDriverJobDetailsEvent extends DriverJobDetailsEvent {
  final String jobId;
  final String? token;

  const ApplyDriverJobDetailsEvent({
    required this.jobId,
    this.token,
  });

  @override
  List<Object?> get props => [jobId, token];
}

