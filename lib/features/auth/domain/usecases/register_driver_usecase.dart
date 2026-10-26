import 'package:equatable/equatable.dart';
import '../../../../core/usecase/usecase.dart';
import '../../data/models/driver_register_body.dart';
import '../entities/driver_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterDriverParams extends Equatable {
  final DriverRegisterBody? body;
  final String? firstName;
  final String? lastName;
  final String name;
  final String email;
  final String phone;
  final String password;
  final String? address;
  final String? licenseNumber;
  final String vehicleModel;
  final String vehiclePlate;
  final DriverServiceType serviceType;
  final String? pancardNumber;
  final String? aadhaarNumber;
  final String? passportId;
  final String? pancard;
  final String? aadhaarCardFront;
  final String? aadhaarCardBack;
  final String? drivingLicense;
  final String? selfie;
  final String? passport;

  // Backwards compatibility getters
  String? get aadharNumber => aadhaarNumber;
  String? get panNumber => pancardNumber;
  String? get passportNumber => passportId;
  String? get pvcNumber => passportId;
  String? get pvcId => passportId;
  String? get aadharFrontPath => aadhaarCardFront;
  String? get aadharBackPath => aadhaarCardBack;
  String? get panCardPath => pancard;
  String? get drivingLicensePath => drivingLicense;
  String? get passportPath => passport;
  String? get pvcPath => passport;
  String? get pvc => passport;
  String? get profilePicPath => selfie;

  RegisterDriverParams({
    this.body,
    String? firstName,
    String? lastName,
    String? name,
    String? email,
    String? phone,
    String? password,
    String? address,
    String? licenseNumber,
    this.vehicleModel = 'Standard',
    this.vehiclePlate = 'N/A',
    this.serviceType = DriverServiceType.taxi,
    String? pancardNumber,
    String? aadhaarNumber,
    String? passportId,
    String? pvcId,
    String? pancard,
    String? aadhaarCardFront,
    String? aadhaarCardBack,
    String? drivingLicense,
    String? selfie,
    String? passport,
    String? pvc,
    String? aadharNumber,
    String? panNumber,
    String? passportNumber,
    String? pvcNumber,
    String? aadharFrontPath,
    String? aadharBackPath,
    String? panCardPath,
    String? drivingLicensePath,
    String? passportPath,
    String? pvcPath,
    String? profilePicPath,
  }) : firstName = firstName ?? body?.firstName,
       lastName = lastName ?? body?.lastName,
       name =
           name ??
           ((body != null)
               ? '${body.firstName} ${body.lastName}'.trim()
               : 'Driver'),
       email = email ?? body?.email ?? '',
       phone = phone ?? body?.phone ?? '',
       password = password ?? body?.password ?? '',
       address = address ?? body?.address,
       licenseNumber = licenseNumber ?? body?.licenseNumber,
       aadhaarNumber = aadhaarNumber ?? aadharNumber ?? body?.aadhaarNumber,
       pancardNumber = pancardNumber ?? panNumber ?? body?.pancardNumber,
       passportId = pvcId ?? pvcNumber ?? passportId ?? passportNumber ?? body?.effectivePvcId,
       pancard = pancard ?? panCardPath ?? body?.pancard,
       aadhaarCardFront =
           aadhaarCardFront ?? aadharFrontPath ?? body?.aadhaarCardFront,
       aadhaarCardBack =
           aadhaarCardBack ?? aadharBackPath ?? body?.aadhaarCardBack,
       drivingLicense =
           drivingLicense ?? drivingLicensePath ?? body?.drivingLicense,
       selfie = selfie ?? profilePicPath ?? body?.selfie,
       passport = pvc ?? pvcPath ?? passport ?? passportPath ?? body?.effectivePvc;

  @override
  List<Object?> get props => [
    body,
    firstName,
    lastName,
    name,
    email,
    phone,
    password,
    address,
    licenseNumber,
    vehicleModel,
    vehiclePlate,
    serviceType,
    pancardNumber,
    aadhaarNumber,
    passportId,
    pancard,
    aadhaarCardFront,
    aadhaarCardBack,
    drivingLicense,
    selfie,
    passport,
  ];
}

class RegisterDriverUseCase
    implements UseCase<DriverEntity, RegisterDriverParams> {
  final AuthRepository repository;

  RegisterDriverUseCase(this.repository);

  @override
  Future<DriverEntity> call(RegisterDriverParams params) async {
    return await repository.registerDriver(
      body: params.body,
      name: params.name,
      email: params.email,
      phone: params.phone,
      password: params.password,
      vehicleModel: params.vehicleModel,
      vehiclePlate: params.vehiclePlate,
      serviceType: params.serviceType,
      firstName: params.firstName,
      lastName: params.lastName,
      address: params.address,
      licenseNumber: params.licenseNumber,
      pancardNumber: params.pancardNumber,
      aadhaarNumber: params.aadhaarNumber,
      passportId: params.passportId,
      pancard: params.pancard,
      aadhaarCardFront: params.aadhaarCardFront,
      aadhaarCardBack: params.aadhaarCardBack,
      drivingLicense: params.drivingLicense,
      selfie: params.selfie,
      passport: params.passport,
      aadharNumber: params.aadhaarNumber,
      panNumber: params.pancardNumber,
      passportNumber: params.passportId,
      aadharFrontPath: params.aadhaarCardFront,
      aadharBackPath: params.aadhaarCardBack,
      panCardPath: params.pancard,
      drivingLicensePath: params.drivingLicense,
      passportPath: params.passport,
      profilePicPath: params.selfie,
    );
  }
}
