import '../../../profile/domain/entities/driver_documents_entity.dart';
import '../../../profile/domain/entities/driver_profile_entity.dart';

abstract class DocumentsRepository {
  /// Fetches latest driver documents from the driver profile API
  Future<DriverDocumentsEntity> getDriverDocuments({String? token});

  /// Fetches entire profile with documents
  Future<DriverProfileEntity> getDriverProfileWithDocuments({String? token});
}
