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

  const SendOtpEvent({required this.phone});

  @override
  List<Object?> get props => [phone];
}

class VerifyOtpEvent extends AuthEvent {
  final String phone;
  final String otp;

  const VerifyOtpEvent({
    required this.phone,
    required this.otp,
  });

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
  final String? firstName;
  final String? lastName;
  final String name;
  final String email;
  final String phone;
  final String password;
  final String vehicleModel;
  final String vehiclePlate;
  final DriverServiceType serviceType;

  const RegisterDriverEvent({
    this.firstName,
    this.lastName,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.vehicleModel,
    required this.vehiclePlate,
    required this.serviceType,
  });

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        name,
        email,
        phone,
        password,
        vehicleModel,
        vehiclePlate,
        serviceType,
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
