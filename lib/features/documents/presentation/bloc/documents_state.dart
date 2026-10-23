import 'package:equatable/equatable.dart';
import '../../domain/entities/document_verification_status.dart';
import '../../../profile/domain/entities/driver_documents_entity.dart';
import '../../../profile/domain/entities/driver_profile_entity.dart';

abstract class DocumentsState extends Equatable {
  const DocumentsState();

  @override
  List<Object?> get props => [];
}

class DocumentsInitial extends DocumentsState {}

class DocumentsLoading extends DocumentsState {}

class DocumentItem extends Equatable {
  final String key;
  final String title;
  final String subtitle;
  final String status; // 'Verified' or 'Not Verified'
  final String statusType; // 'success' or 'warning'
  final DocumentVerificationStatus verificationStatus;
  final String? documentNumber;
  final String? fileUrl;
  final String? backFileUrl;
  final String? localPath;
  final String? localBackPath;
  final String? uploadedFileName;
  final String category; // 'driver' or 'vehicle'

  const DocumentItem({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusType,
    this.verificationStatus = DocumentVerificationStatus.notVerified,
    this.documentNumber,
    this.fileUrl,
    this.backFileUrl,
    this.localPath,
    this.localBackPath,
    this.uploadedFileName,
    this.category = 'driver',
  });

  bool get isVerified => verificationStatus == DocumentVerificationStatus.verified;
  bool get isNotVerified => verificationStatus == DocumentVerificationStatus.notVerified;
  bool get isUploaded => isVerified;
  bool get isIncomplete => isNotVerified;
  bool get isNotUploaded => isNotVerified;

  DocumentItem copyWith({
    String? key,
    String? title,
    String? subtitle,
    String? status,
    String? statusType,
    DocumentVerificationStatus? verificationStatus,
    String? documentNumber,
    String? fileUrl,
    String? backFileUrl,
    String? localPath,
    String? localBackPath,
    String? uploadedFileName,
    String? category,
  }) {
    return DocumentItem(
      key: key ?? this.key,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      status: status ?? this.status,
      statusType: statusType ?? this.statusType,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      documentNumber: documentNumber ?? this.documentNumber,
      fileUrl: fileUrl ?? this.fileUrl,
      backFileUrl: backFileUrl ?? this.backFileUrl,
      localPath: localPath ?? this.localPath,
      localBackPath: localBackPath ?? this.localBackPath,
      uploadedFileName: uploadedFileName ?? this.uploadedFileName,
      category: category ?? this.category,
    );
  }

  @override
  List<Object?> get props => [
        key,
        title,
        subtitle,
        status,
        statusType,
        verificationStatus,
        documentNumber,
        fileUrl,
        backFileUrl,
        localPath,
        localBackPath,
        uploadedFileName,
        category,
      ];
}

class DocumentsLoaded extends DocumentsState {
  final int verifiedCount;
  final int expiringCount;
  final int missingCount;
  final List<DocumentItem> driverDocuments;
  final List<DocumentItem> vehicleDocuments;
  final String selectedFilter; // 'All', 'Driver', 'Vehicle'
  final DriverDocumentsEntity? rawDocuments;
  final DriverProfileEntity? profile;
  final bool isRefreshing;
  final String? message;

  const DocumentsLoaded({
    required this.verifiedCount,
    required this.expiringCount,
    required this.missingCount,
    required this.driverDocuments,
    required this.vehicleDocuments,
    this.selectedFilter = 'All',
    this.rawDocuments,
    this.profile,
    this.isRefreshing = false,
    this.message,
  });

  int get totalCount => driverDocuments.length + vehicleDocuments.length;
  double get progress => totalCount > 0 ? (verifiedCount / totalCount) : 0.0;

  DocumentsLoaded copyWith({
    int? verifiedCount,
    int? expiringCount,
    int? missingCount,
    List<DocumentItem>? driverDocuments,
    List<DocumentItem>? vehicleDocuments,
    String? selectedFilter,
    DriverDocumentsEntity? rawDocuments,
    DriverProfileEntity? profile,
    bool? isRefreshing,
    String? message,
  }) {
    return DocumentsLoaded(
      verifiedCount: verifiedCount ?? this.verifiedCount,
      expiringCount: expiringCount ?? this.expiringCount,
      missingCount: missingCount ?? this.missingCount,
      driverDocuments: driverDocuments ?? this.driverDocuments,
      vehicleDocuments: vehicleDocuments ?? this.vehicleDocuments,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      rawDocuments: rawDocuments ?? this.rawDocuments,
      profile: profile ?? this.profile,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
        verifiedCount,
        expiringCount,
        missingCount,
        driverDocuments,
        vehicleDocuments,
        selectedFilter,
        rawDocuments,
        profile,
        isRefreshing,
        message,
      ];
}

class DocumentsError extends DocumentsState {
  final String message;

  const DocumentsError(this.message);

  @override
  List<Object?> get props => [message];
}
