import '../repositories/driver_jobs_repository.dart';

class RejectDriverJobUseCase {
  final DriverJobsRepository repository;

  RejectDriverJobUseCase(this.repository);

  Future<bool> call(String jobId, {String? reason, String? token}) async {
    return await repository.rejectDriverJob(jobId, reason: reason, token: token);
  }
}

