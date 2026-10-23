import 'package:equatable/equatable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../profile/domain/entities/driver_documents_entity.dart';
import '../../../profile/domain/entities/driver_profile_entity.dart';
import '../repositories/documents_repository.dart';

class GetDriverDocumentsParams extends Equatable {
  final String? token;

  const GetDriverDocumentsParams({this.token});

  @override
  List<Object?> get props => [token];
}

class GetDriverDocumentsUseCase
    implements UseCase<DriverProfileEntity, GetDriverDocumentsParams> {
  final DocumentsRepository repository;

  GetDriverDocumentsUseCase(this.repository);

  @override
  Future<DriverProfileEntity> call(GetDriverDocumentsParams params) async {
    return await repository.getDriverProfileWithDocuments(token: params.token);
  }

  Future<DriverDocumentsEntity> getDocumentsOnly({String? token}) async {
    return await repository.getDriverDocuments(token: token);
  }
}
