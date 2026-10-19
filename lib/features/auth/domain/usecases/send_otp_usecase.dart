import 'package:equatable/equatable.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class SendOtpParams extends Equatable {
  final String phone;
  final String? fcmToken;

  const SendOtpParams({required this.phone, this.fcmToken});

  @override
  List<Object?> get props => [phone, fcmToken];
}

class SendOtpUseCase implements UseCase<void, SendOtpParams> {
  final AuthRepository repository;

  SendOtpUseCase(this.repository);

  @override
  Future<void> call(SendOtpParams params) async {
    return await repository.sendOtp(
      phone: params.phone,
      fcmToken: params.fcmToken,
    );
  }
}
