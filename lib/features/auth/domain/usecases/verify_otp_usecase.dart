import 'package:equatable/equatable.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/driver_entity.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpParams extends Equatable {
  final String phone;
  final String otp;

  const VerifyOtpParams({
    required this.phone,
    required this.otp,
  });

  @override
  List<Object?> get props => [phone, otp];
}

class VerifyOtpUseCase implements UseCase<DriverEntity, VerifyOtpParams> {
  final AuthRepository repository;

  VerifyOtpUseCase(this.repository);

  @override
  Future<DriverEntity> call(VerifyOtpParams params) async {
    return await repository.verifyOtp(
      phone: params.phone,
      otp: params.otp,
    );
  }
}
