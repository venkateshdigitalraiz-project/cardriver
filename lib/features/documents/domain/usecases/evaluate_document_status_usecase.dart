import '../entities/document_verification_status.dart';

/// Centralized domain use case evaluating document verification status.
///
/// Rules:
/// 1. Status is strictly 'Verified' or 'Not Verified'.
/// 2. Missing values: null, empty string "", or whitespace-only strings are treated as missing.
/// 3. Aadhaar Card: 'Verified' ONLY when BOTH front and back contain valid non-empty file values.
///    If either side is missing or empty, status is 'Not Verified'.
/// 4. Driving License: 'Verified' ONLY when drivingLicense file contains a valid non-empty value.
/// 5. PAN Card: 'Verified' ONLY when pancard file contains a valid non-empty value.
/// 6. Passport: 'Verified' ONLY when passport file contains a valid non-empty value.
/// 7. Selfie: 'Verified' ONLY when selfie file contains a valid non-empty value.
/// 8. Document identification numbers (aadhaarNumber, licenseNumber, pancardNumber, passportId)
///    NEVER determine verification status.
class EvaluateDocumentStatusUseCase {
  const EvaluateDocumentStatusUseCase();

  /// Checks if a string contains a valid, non-empty, trimmed value.
  static bool isValidDocumentValue(String? value) {
    if (value == null) return false;
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.toLowerCase() == 'null') return false;
    return true;
  }

  /// Determines the verification status of an Aadhaar card requiring both front and back.
  static DocumentVerificationStatus evaluateAadhaar({
    required String? front,
    required String? back,
  }) {
    final hasFront = isValidDocumentValue(front);
    final hasBack = isValidDocumentValue(back);

    return (hasFront && hasBack)
        ? DocumentVerificationStatus.verified
        : DocumentVerificationStatus.notVerified;
  }

  /// Determines the verification status of a single-file document.
  static DocumentVerificationStatus evaluateSingleDocument(String? fileUrlOrPath) {
    return isValidDocumentValue(fileUrlOrPath)
        ? DocumentVerificationStatus.verified
        : DocumentVerificationStatus.notVerified;
  }
}
