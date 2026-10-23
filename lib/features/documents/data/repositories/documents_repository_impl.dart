import '../../../profile/domain/entities/driver_documents_entity.dart';
import '../../../profile/domain/entities/driver_profile_entity.dart';
import '../../domain/repositories/documents_repository.dart';
import '../datasources/documents_remote_datasource.dart';

class DocumentsRepositoryImpl implements DocumentsRepository {
  final DocumentsRemoteDataSource remoteDataSource;

  DocumentsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<DriverDocumentsEntity> getDriverDocuments({String? token}) async {
    return await remoteDataSource.getDriverDocuments(token: token);
  }

  @override
  Future<DriverProfileEntity> getDriverProfileWithDocuments({String? token}) async {
    return await remoteDataSource.getDriverProfileWithDocuments(token: token);
  }
}
