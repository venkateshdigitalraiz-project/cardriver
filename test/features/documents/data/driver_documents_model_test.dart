import 'package:flutter_test/flutter_test.dart';
import 'package:cardriver/features/profile/data/models/driver_documents_model.dart';

void main() {
  group('DriverDocumentsModel JSON Parsing', () {
    test('Case 1: Parses empty documents object safely', () {
      final json = <String, dynamic>{
        'aadhaarNumber': '',
        'aadhaarCardFront': '',
        'aadhaarCardBack': '',
        'aadhaarCardImage': '',
        'drivingLicense': '',
        'licenseNumber': '',
        'pancard': '',
        'pancardNumber': '',
        'passport': '',
        'passportId': '',
        'selfie': '',
      };

      final model = DriverDocumentsModel.fromJson(json);

      expect(model.aadhaarCardFront, '');
      expect(model.aadhaarCardBack, '');
      expect(model.drivingLicense, '');
      expect(model.pancard, '');
      expect(model.passport, '');
      expect(model.selfie, '');
      expect(model.isAadhaarComplete, false);
      expect(model.isDrivingLicenseUploaded, false);
      expect(model.isPanCardUploaded, false);
      expect(model.isPassportUploaded, false);
      expect(model.isSelfieUploaded, false);
    });

    test('Case 5: ID numbers exist but document file fields are empty', () {
      final json = <String, dynamic>{
        'aadhaarNumber': '123456789012',
        'aadhaarCardFront': '',
        'aadhaarCardBack': '',
        'aadhaarCardImage': '',
        'drivingLicense': '',
        'licenseNumber': 'DL-9988776655',
        'pancard': '',
        'pancardNumber': 'ABCDE1234F',
        'passport': '',
        'passportId': 'P1234567',
        'selfie': '',
      };

      final model = DriverDocumentsModel.fromJson(json);

      expect(model.aadhaarNumber, '123456789012');
      expect(model.licenseNumber, 'DL-9988776655');
      expect(model.pancardNumber, 'ABCDE1234F');
      expect(model.passportId, 'P1234567');

      // Crucial: Identification numbers must NOT mark documents as uploaded/complete
      expect(model.isAadhaarComplete, false);
      expect(model.isDrivingLicenseUploaded, false);
      expect(model.isPanCardUploaded, false);
      expect(model.isPassportUploaded, false);
      expect(model.isSelfieUploaded, false);
    });

    test('Case 6: Treats null, empty strings, and whitespace as missing', () {
      final json = <String, dynamic>{
        'aadhaarNumber': '   ',
        'aadhaarCardFront': null,
        'aadhaarCardBack': '   ',
        'drivingLicense': '  \t  ',
        'licenseNumber': null,
        'pancard': 'null',
        'pancardNumber': null,
        'passport': '   ',
        'selfie': null,
      };

      final model = DriverDocumentsModel.fromJson(json);

      expect(model.aadhaarCardFront, '');
      expect(model.aadhaarCardBack, '');
      expect(model.drivingLicense, '');
      expect(model.pancard, '');
      expect(model.passport, '');
      expect(model.selfie, '');
      expect(model.isAadhaarComplete, false);
      expect(model.isDrivingLicenseUploaded, false);
      expect(model.isPanCardUploaded, false);
      expect(model.isPassportUploaded, false);
      expect(model.isSelfieUploaded, false);
    });

    test('Case 2: Aadhaar front and back populated', () {
      final json = <String, dynamic>{
        'aadhaarCardFront': 'https://example.com/front.jpg',
        'aadhaarCardBack': 'https://example.com/back.jpg',
      };

      final model = DriverDocumentsModel.fromJson(json);

      expect(model.isAadhaarComplete, true);
      expect(model.isAadhaarIncomplete, false);
    });

    test('Case 3: Only Aadhaar front populated', () {
      final json = <String, dynamic>{
        'aadhaarCardFront': 'https://example.com/front.jpg',
        'aadhaarCardBack': '',
      };

      final model = DriverDocumentsModel.fromJson(json);

      expect(model.isAadhaarComplete, false);
      expect(model.isAadhaarIncomplete, true);
    });

    test('Case 4: Populated individual document fields', () {
      final json = <String, dynamic>{
        'drivingLicense': 'https://example.com/dl.jpg',
        'pancard': 'https://example.com/pan.jpg',
        'passport': 'https://example.com/passport.jpg',
        'selfie': 'https://example.com/selfie.jpg',
      };

      final model = DriverDocumentsModel.fromJson(json);

      expect(model.isDrivingLicenseUploaded, true);
      expect(model.isPanCardUploaded, true);
      expect(model.isPassportUploaded, true);
      expect(model.isSelfieUploaded, true);
    });
  });
}
