import 'package:equatable/equatable.dart';
import '../../../profile/domain/entities/driver_documents_entity.dart';
import '../../../profile/domain/entities/driver_profile_entity.dart';

abstract class DocumentsEvent extends Equatable {
  const DocumentsEvent();

  @override
  List<Object?> get props => [];
}

class LoadDocumentsEvent extends DocumentsEvent {
  final DriverDocumentsEntity? documents;
  final DriverProfileEntity? profile;
  final String? token;
  final bool forceRefresh;

  const LoadDocumentsEvent({
    this.documents,
    this.profile,
    this.token,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [documents, profile, token, forceRefresh];
}

class FilterDocumentsEvent extends DocumentsEvent {
  final String filterType;

  const FilterDocumentsEvent(this.filterType);

  @override
  List<Object?> get props => [filterType];
}

class RefreshDocumentsEvent extends DocumentsEvent {
  final String? token;

  const RefreshDocumentsEvent({this.token});

  @override
  List<Object?> get props => [token];
}

class UpdateDocumentFileEvent extends DocumentsEvent {
  final String documentKey;
  final String filePath;
  final String fileName;
  final String? side; // Optional: 'front' or 'back' for two-sided documents like Aadhaar

  const UpdateDocumentFileEvent({
    required this.documentKey,
    required this.filePath,
    required this.fileName,
    this.side,
  });

  @override
  List<Object?> get props => [documentKey, filePath, fileName, side];
}
