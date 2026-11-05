import '../entities/driver_job_entity.dart';
import '../repositories/driver_jobs_repository.dart';

class GetDriverJobDetailsUseCase {
  final DriverJobsRepository repository;

  GetDriverJobDetailsUseCase(this.repository);

  Future<DriverJobEntity> call(String jobId, {String? token}) async {
    return await repository.getDriverJobDetails(jobId, token: token);
  }
}

