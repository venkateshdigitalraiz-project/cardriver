import '../repositories/driver_jobs_repository.dart';

class AcceptDriverJobUseCase {
  final DriverJobsRepository repository;

  AcceptDriverJobUseCase(this.repository);

  Future<bool> call(String jobId, {String? token}) async {
    return await repository.acceptDriverJob(jobId, token: token);
  }
}

