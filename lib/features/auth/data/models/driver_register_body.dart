import 'dart:io';
import 'package:dio/dio.dart';

/// Request body model matching the multipart/form-data cURL specification:
/// POST http://192.168.0.161:3000/api/driver/register
class DriverRegisterBody {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final String licenseNumber;
  final String pancardNumber;
  final String aadhaarNumber;
  final String passportId;
  final String? pancard;
  final String? aadhaarCardFront;
  final String? aadhaarCardBack;
  final String? drivingLicense;
  final String? selfie;
  final String? passport;
  final String? password;

  const DriverRegisterBody({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.licenseNumber,
    required this.pancardNumber,
    required this.aadhaarNumber,
    required this.passportId,
    this.pancard,
    this.aadhaarCardFront,
    this.aadhaarCardBack,
    this.drivingLicense,
    this.selfie,
    this.passport,
    this.password,
  });

  /// Map representation of all form fields matching the cURL keys
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'address': address,
      'licenseNumber': licenseNumber,
      'pancardNumber': pancardNumber,
      'aadhaarNumber': aadhaarNumber,
      'passportId': passportId,
      'pancard': pancard,
      'aadhaarCardFront': aadhaarCardFront,
      'aadhaarCardBack': aadhaarCardBack,
      'drivingLicense': drivingLicense,
      'selfie': selfie,
      'passport': passport,
      if (password != null && password!.isNotEmpty) 'password': password,
    };
  }

  /// Converts this request body into Dio FormData for multipart/form-data POST
  Future<FormData> toFormData() async {
    final formData = FormData();

    // 1. Text Form Fields
    formData.fields.addAll([
      MapEntry('firstName', firstName),
      MapEntry('lastName', lastName),
      MapEntry('email', email),
      MapEntry('phone', phone),
      MapEntry('address', address),
      MapEntry('licenseNumber', licenseNumber),
      MapEntry('pancardNumber', pancardNumber),
      MapEntry('aadhaarNumber', aadhaarNumber),
      MapEntry('passportId', passportId),
    ]);

    if (password != null && password!.isNotEmpty) {
      formData.fields.add(MapEntry('password', password!));
    }

    // 2. Attached Files (or empty fields matching cURL specification)
    if (pancard != null && pancard!.isNotEmpty && File(pancard!).existsSync()) {
      formData.files.add(
        MapEntry(
          'pancard',
          await MultipartFile.fromFile(
            pancard!,
            filename: pancard!.split(Platform.pathSeparator).last,
          ),
        ),
      );
    } else {
      formData.fields.add(const MapEntry('pancard', ''));
    }

    if (aadhaarCardFront != null &&
        aadhaarCardFront!.isNotEmpty &&
        File(aadhaarCardFront!).existsSync()) {
      formData.files.add(
        MapEntry(
          'aadhaarCardFront',
          await MultipartFile.fromFile(
            aadhaarCardFront!,
            filename: aadhaarCardFront!.split(Platform.pathSeparator).last,
          ),
        ),
      );
    } else {
      formData.fields.add(const MapEntry('aadhaarCardFront', ''));
    }

    if (aadhaarCardBack != null &&
        aadhaarCardBack!.isNotEmpty &&
        File(aadhaarCardBack!).existsSync()) {
      formData.files.add(
        MapEntry(
          'aadhaarCardBack',
          await MultipartFile.fromFile(
            aadhaarCardBack!,
            filename: aadhaarCardBack!.split(Platform.pathSeparator).last,
          ),
        ),
      );
    } else {
      formData.fields.add(const MapEntry('aadhaarCardBack', ''));
    }

    if (drivingLicense != null &&
        drivingLicense!.isNotEmpty &&
        File(drivingLicense!).existsSync()) {
      formData.files.add(
        MapEntry(
          'drivingLicense',
          await MultipartFile.fromFile(
            drivingLicense!,
            filename: drivingLicense!.split(Platform.pathSeparator).last,
          ),
        ),
      );
    } else {
      formData.fields.add(const MapEntry('drivingLicense', ''));
    }

    if (selfie != null && selfie!.isNotEmpty && File(selfie!).existsSync()) {
      formData.files.add(
        MapEntry(
          'selfie',
          await MultipartFile.fromFile(
            selfie!,
            filename: selfie!.split(Platform.pathSeparator).last,
          ),
        ),
      );
    } else {
      formData.fields.add(const MapEntry('selfie', ''));
    }

    if (passport != null &&
        passport!.isNotEmpty &&
        File(passport!).existsSync()) {
      formData.files.add(
        MapEntry(
          'passport',
          await MultipartFile.fromFile(
            passport!,
            filename: passport!.split(Platform.pathSeparator).last,
          ),
        ),
      );
    } else {
      formData.fields.add(const MapEntry('passport', ''));
    }

    return formData;
  }
}
