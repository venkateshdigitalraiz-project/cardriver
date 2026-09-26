import 'package:equatable/equatable.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/driver_entity.dart';
import '../repositories/auth_repository.dart';

class LoginWithPhoneParams extends Equatable {
  final String phone;
  final String otp;

  const LoginWithPhoneParams({
    required this.phone,
    required this.otp,
  });

  @override
  List<Object?> get props => [phone, otp];
}

class LoginWithPhoneUseCase implements UseCase<DriverEntity, LoginWithPhoneParams> {
  final AuthRepository repository;

  LoginWithPhoneUseCase(this.repository);

  @override
  Future<DriverEntity> call(LoginWithPhoneParams params) async {
    return await repository.verifyOtp(
      phone: params.phone,
      otp: params.otp,
    );
  }
}
