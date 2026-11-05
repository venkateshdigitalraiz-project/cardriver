import '../../domain/entities/driver_job_entity.dart';
import '../../domain/repositories/driver_jobs_repository.dart';
import '../datasources/driver_jobs_remote_datasource.dart';

class DriverJobsRepositoryImpl implements DriverJobsRepository {
  final DriverJobsRemoteDataSource remoteDataSource;

  DriverJobsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<DriverJobListResponseEntity> getDriverJobs({
    String? token,
    int page = 1,
    int limit = 10,
    String? search,
    String? jobType,
  }) async {
    return await remoteDataSource.getDriverJobs(
      token: token,
      page: page,
      limit: limit,
      search: search,
      jobType: jobType,
    );
  }

  @override
  Future<DriverJobEntity> getDriverJobDetails(
    String jobId, {
    String? token,
  }) async {
    return await remoteDataSource.getDriverJobDetails(
      jobId,
      token: token,
    );
  }

  @override
  Future<bool> acceptDriverJob(
    String jobId, {
    String? token,
  }) async {
    return await remoteDataSource.acceptDriverJob(
      jobId,
      token: token,
    );
  }

  @override
  Future<bool> rejectDriverJob(
    String jobId, {
    String? reason,
    String? token,
  }) async {
    return await remoteDataSource.rejectDriverJob(
      jobId,
      reason: reason,
      token: token,
    );
  }
}
