import '../../domain/entities/driver_documents_entity.dart';

class DriverDocumentsModel extends DriverDocumentsEntity {
  const DriverDocumentsModel({
    super.aadhaarNumber,
    super.aadhaarCardFront,
    super.aadhaarCardBack,
    super.aadhaarCardImage,
    super.drivingLicense,
    super.licenseNumber,
    super.pancard,
    super.pancardNumber,
    super.passport,
    super.passportId,
    super.selfie,
  });

  static String _safeString(dynamic value) {
    if (value == null) return '';
    final str = value.toString().trim();
    if (str.isEmpty || str.toLowerCase() == 'null') return '';
    return str;
  }

  factory DriverDocumentsModel.fromJson(
    Map<String, dynamic> json, {
    String? fallbackAadhaar,
    String? fallbackLicense,
    String? fallbackPan,
    String? fallbackPassport,
  }) {
    final rawAadhaar = _safeString(json['aadhaarNumber']);
    final rawLicense = _safeString(json['licenseNumber']);
    final rawPan = _safeString(json['pancardNumber']);
    final rawPassport = _safeString(json['passportId']);

    return DriverDocumentsModel(
      aadhaarNumber: rawAadhaar.isNotEmpty ? rawAadhaar : _safeString(fallbackAadhaar),
      aadhaarCardFront: _safeString(json['aadhaarCardFront']),
      aadhaarCardBack: _safeString(json['aadhaarCardBack']),
      aadhaarCardImage: _safeString(json['aadhaarCardImage']),
      drivingLicense: _safeString(json['drivingLicense']),
      licenseNumber: rawLicense.isNotEmpty ? rawLicense : _safeString(fallbackLicense),
      pancard: _safeString(json['pancard']),
      pancardNumber: rawPan.isNotEmpty ? rawPan : _safeString(fallbackPan),
      passport: _safeString(json['passport']),
      passportId: rawPassport.isNotEmpty ? rawPassport : _safeString(fallbackPassport),
      selfie: _safeString(json['selfie']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aadhaarNumber': aadhaarNumber,
      'aadhaarCardFront': aadhaarCardFront,
      'aadhaarCardBack': aadhaarCardBack,
      'aadhaarCardImage': aadhaarCardImage,
      'drivingLicense': drivingLicense,
      'licenseNumber': licenseNumber,
      'pancard': pancard,
      'pancardNumber': pancardNumber,
      'passport': passport,
      'passportId': passportId,
      'selfie': selfie,
    };
  }
}
