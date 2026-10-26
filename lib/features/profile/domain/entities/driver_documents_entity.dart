import 'package:equatable/equatable.dart';

/// Clean Architecture Entity representing driver verification documents from /api/driver/profile
class DriverDocumentsEntity extends Equatable {
  final String aadhaarNumber;
  final String aadhaarCardFront;
  final String aadhaarCardBack;
  final String aadhaarCardImage;
  final String drivingLicense;
  final String licenseNumber;
  final String pancard;
  final String pancardNumber;
  final String passport;
  final String passportId;
  final String selfie;

  // PVC aliases mapped to API fields (passport / passportId)
  String get pvc => passport;
  String get pvcId => passportId;
  String get pvcNumber => passportId;

  const DriverDocumentsEntity({
    this.aadhaarNumber = '',
    this.aadhaarCardFront = '',
    this.aadhaarCardBack = '',
    this.aadhaarCardImage = '',
    this.drivingLicense = '',
    this.licenseNumber = '',
    this.pancard = '',
    this.pancardNumber = '',
    this.passport = '',
    this.passportId = '',
    this.selfie = '',
  });

  /// Document file verification getters (based on files, not identification numbers)
  bool get isAadhaarComplete =>
      aadhaarCardFront.trim().isNotEmpty && aadhaarCardBack.trim().isNotEmpty;

  bool get isAadhaarIncomplete =>
      !isAadhaarComplete &&
      (aadhaarCardFront.trim().isNotEmpty || aadhaarCardBack.trim().isNotEmpty);

  bool get isDrivingLicenseUploaded => drivingLicense.trim().isNotEmpty;
  bool get isPanCardUploaded => pancard.trim().isNotEmpty;
  bool get isPvcUploaded => pvc.trim().isNotEmpty;
  bool get isPassportUploaded => isPvcUploaded;
  bool get isSelfieUploaded => selfie.trim().isNotEmpty;

  /// Legacy helper getters updated to reflect upload completeness
  bool get hasAadhaar => isAadhaarComplete;
  bool get hasDrivingLicense => isDrivingLicenseUploaded;
  bool get hasPanCard => isPanCardUploaded;
  bool get hasPvc => isPvcUploaded;
  bool get hasPassport => isPassportUploaded;
  bool get hasSelfie => isSelfieUploaded;

  /// Helper to get masked aadhaar (e.g. "XXXX XXXX 9012")
  String get maskedAadhaar {
    final clean = aadhaarNumber.replaceAll(RegExp(r'\s+'), '');
    if (clean.isEmpty) return 'Not uploaded';
    if (clean.length >= 4) {
      final last4 = clean.substring(clean.length - 4);
      return 'XXXX XXXX $last4';
    }
    return clean;
  }

  /// Create a copy with modified fields
  DriverDocumentsEntity copyWith({
    String? aadhaarNumber,
    String? aadhaarCardFront,
    String? aadhaarCardBack,
    String? aadhaarCardImage,
    String? drivingLicense,
    String? licenseNumber,
    String? pancard,
    String? pancardNumber,
    String? pvc,
    String? pvcId,
    String? passport,
    String? passportId,
    String? selfie,
  }) {
    return DriverDocumentsEntity(
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      aadhaarCardFront: aadhaarCardFront ?? this.aadhaarCardFront,
      aadhaarCardBack: aadhaarCardBack ?? this.aadhaarCardBack,
      aadhaarCardImage: aadhaarCardImage ?? this.aadhaarCardImage,
      drivingLicense: drivingLicense ?? this.drivingLicense,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      pancard: pancard ?? this.pancard,
      pancardNumber: pancardNumber ?? this.pancardNumber,
      passport: passport ?? pvc ?? this.passport,
      passportId: passportId ?? pvcId ?? this.passportId,
      selfie: selfie ?? this.selfie,
    );
  }

  @override
  List<Object?> get props => [
        aadhaarNumber,
        aadhaarCardFront,
        aadhaarCardBack,
        aadhaarCardImage,
        drivingLicense,
        licenseNumber,
        pancard,
        pancardNumber,
        passport,
        passportId,
        selfie,
      ];
}
