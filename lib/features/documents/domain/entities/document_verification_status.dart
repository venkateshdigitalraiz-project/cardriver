/// Clean Architecture domain enum representing verification status: Verified or Not Verified only.
enum DocumentVerificationStatus {
  notVerified,
  verified,
}

extension DocumentVerificationStatusX on DocumentVerificationStatus {
  /// User-facing label: 'Verified' or 'Not Verified'.
  String get label {
    switch (this) {
      case DocumentVerificationStatus.verified:
        return 'Verified';
      case DocumentVerificationStatus.notVerified:
        return 'Not Verified';
    }
  }

  /// Theme badge status type.
  String get statusType {
    switch (this) {
      case DocumentVerificationStatus.verified:
        return 'success';
      case DocumentVerificationStatus.notVerified:
        return 'warning';
    }
  }

  bool get isVerified => this == DocumentVerificationStatus.verified;
  bool get isNotVerified => this == DocumentVerificationStatus.notVerified;

  // Compatibility helpers
  bool get isComplete => isVerified;
  bool get isIncomplete => isNotVerified;
  bool get isNotUploaded => isNotVerified;
}
