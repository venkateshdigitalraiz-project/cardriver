import 'package:equatable/equatable.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/driver_entity.dart';
import '../repositories/auth_repository.dart';

class LoginWithEmailParams extends Equatable {
  final String email;
  final String password;
  final bool rememberMe;

  const LoginWithEmailParams({
    required this.email,
    required this.password,
    this.rememberMe = true,
  });

  @override
  List<Object?> get props => [email, password, rememberMe];
}

class LoginWithEmailUseCase implements UseCase<DriverEntity, LoginWithEmailParams> {
  final AuthRepository repository;

  LoginWithEmailUseCase(this.repository);

  @override
  Future<DriverEntity> call(LoginWithEmailParams params) async {
    return await repository.loginWithEmail(
      email: params.email,
      password: params.password,
      rememberMe: params.rememberMe,
    );
  }
}
