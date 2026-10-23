import '../../../profile/data/datasources/profile_remote_datasource.dart';
import '../../../profile/data/models/driver_profile_model.dart';
import '../../../profile/domain/entities/driver_documents_entity.dart';

abstract class DocumentsRemoteDataSource {
  Future<DriverProfileModel> getDriverProfileWithDocuments({String? token});
  Future<DriverDocumentsEntity> getDriverDocuments({String? token});
}

class DocumentsRemoteDataSourceImpl implements DocumentsRemoteDataSource {
  final ProfileRemoteDataSource profileRemoteDataSource;

  DocumentsRemoteDataSourceImpl({
    required this.profileRemoteDataSource,
  });

  @override
  Future<DriverProfileModel> getDriverProfileWithDocuments({String? token}) async {
    return await profileRemoteDataSource.getDriverProfile(token: token);
  }

  @override
  Future<DriverDocumentsEntity> getDriverDocuments({String? token}) async {
    final profile = await profileRemoteDataSource.getDriverProfile(token: token);
    return profile.documents ?? const DriverDocumentsEntity();
  }
}
