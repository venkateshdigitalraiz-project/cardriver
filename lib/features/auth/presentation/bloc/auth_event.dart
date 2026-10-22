import 'package:cardriver/features/auth/data/models/driver_register_body.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/driver_entity.dart';

enum AuthLoginMode { email, phone }

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {
  const CheckAuthStatusEvent();
}

class LoadIntroBannersEvent extends AuthEvent {
  const LoadIntroBannersEvent();
}

class IntroBannerPageChangedEvent extends AuthEvent {
  final int pageIndex;

  const IntroBannerPageChangedEvent(this.pageIndex);

  @override
  List<Object?> get props => [pageIndex];
}

class LoginWithEmailEvent extends AuthEvent {
  final String email;
  final String password;
  final bool rememberMe;

  const LoginWithEmailEvent({
    required this.email,
    required this.password,
    this.rememberMe = true,
  });

  @override
  List<Object?> get props => [email, password, rememberMe];
}

class SendOtpEvent extends AuthEvent {
  final String phone;
  final String? fcmToken;

  const SendOtpEvent({required this.phone, this.fcmToken});

  @override
  List<Object?> get props => [phone, fcmToken];
}

class VerifyOtpEvent extends AuthEvent {
  final String phone;
  final String otp;

  const VerifyOtpEvent({required this.phone, required this.otp});

  @override
  List<Object?> get props => [phone, otp];
}

class SocialLoginEvent extends AuthEvent {
  final String provider;

  const SocialLoginEvent({required this.provider});

  @override
  List<Object?> get props => [provider];
}

class RegisterCustomerEvent extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String password;
  final CustomerPaymentMethod preferredPayment;

  const RegisterCustomerEvent({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
    this.preferredPayment = CustomerPaymentMethod.card,
  });

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    email,
    phone,
    password,
    preferredPayment,
  ];
}

class RegisterDriverEvent extends AuthEvent {
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
  String? get panNumber => pancardNumber;
  String? get aadharNumber => aadhaarNumber;
  String? get passportNumber => passportId;
  String? get panCardPath => pancard;
  String? get aadharFrontPath => aadhaarCardFront;
  String? get aadharBackPath => aadhaarCardBack;
  String? get drivingLicensePath => drivingLicense;
  String? get profilePicPath => selfie;
  String? get passportPath => passport;

  RegisterDriverEvent({
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
    String? pancard,
    String? aadhaarCardFront,
    String? aadhaarCardBack,
    String? drivingLicense,
    String? selfie,
    String? passport,
    String? aadharNumber,
    String? panNumber,
    String? passportNumber,
    String? aadharFrontPath,
    String? aadharBackPath,
    String? panCardPath,
    String? drivingLicensePath,
    String? passportPath,
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
       passportId = passportId ?? passportNumber ?? body?.passportId,
       pancard = pancard ?? panCardPath ?? body?.pancard,
       aadhaarCardFront =
           aadhaarCardFront ?? aadharFrontPath ?? body?.aadhaarCardFront,
       aadhaarCardBack =
           aadhaarCardBack ?? aadharBackPath ?? body?.aadhaarCardBack,
       drivingLicense =
           drivingLicense ?? drivingLicensePath ?? body?.drivingLicense,
       selfie = selfie ?? profilePicPath ?? body?.selfie,
       passport = passport ?? passportPath ?? body?.passport;

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

class SwitchLoginModeEvent extends AuthEvent {
  final AuthLoginMode mode;

  const SwitchLoginModeEvent(this.mode);

  @override
  List<Object?> get props => [mode];
}

class ToggleRememberMeEvent extends AuthEvent {
  final bool value;

  const ToggleRememberMeEvent(this.value);

  @override
  List<Object?> get props => [value];
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}

class ClearAuthErrorEvent extends AuthEvent {
  const ClearAuthErrorEvent();
}

class ResetAuthEvent extends AuthEvent {
  const ResetAuthEvent();
}
