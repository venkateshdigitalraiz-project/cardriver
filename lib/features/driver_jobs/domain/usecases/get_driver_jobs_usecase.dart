import '../entities/driver_job_entity.dart';
import '../repositories/driver_jobs_repository.dart';

class GetDriverJobsUseCase {
  final DriverJobsRepository repository;

  GetDriverJobsUseCase(this.repository);

  Future<DriverJobListResponseEntity> call({
    String? token,
    int page = 1,
    int limit = 10,
    String? search,
    String? jobType,
  }) async {
    return await repository.getDriverJobs(
      token: token,
      page: page,
      limit: limit,
      search: search,
      jobType: jobType,
    );
  }
}

