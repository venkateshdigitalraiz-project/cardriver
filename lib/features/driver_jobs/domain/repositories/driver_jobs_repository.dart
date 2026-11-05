import '../entities/driver_job_entity.dart';

abstract class DriverJobsRepository {
  Future<DriverJobListResponseEntity> getDriverJobs({
    String? token,
    int page = 1,
    int limit = 10,
    String? search,
    String? jobType,
  });

  Future<DriverJobEntity> getDriverJobDetails(
    String jobId, {
    String? token,
  });

  Future<bool> acceptDriverJob(
    String jobId, {
    String? token,
  });

  Future<bool> rejectDriverJob(
    String jobId, {
    String? reason,
    String? token,
  });
}

