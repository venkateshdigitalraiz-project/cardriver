import 'package:equatable/equatable.dart';
import 'document_verification_status.dart';

/// Clean Architecture Entity representing a document item for the Driver.
class DocumentItemEntity extends Equatable {
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

  const DocumentItemEntity({
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

  DocumentItemEntity copyWith({
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
    return DocumentItemEntity(
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
