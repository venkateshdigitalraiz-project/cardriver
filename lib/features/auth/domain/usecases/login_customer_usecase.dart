import 'package:equatable/equatable.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/customer_entity.dart';
import '../repositories/auth_repository.dart';

class LoginCustomerParams extends Equatable {
  final String email;
  final String password;
  final bool rememberMe;

  const LoginCustomerParams({
    required this.email,
    required this.password,
    this.rememberMe = true,
  });

  @override
  List<Object?> get props => [email, password, rememberMe];
}

class LoginCustomerUseCase implements UseCase<CustomerEntity, LoginCustomerParams> {
  final AuthRepository repository;

  LoginCustomerUseCase(this.repository);

  @override
  Future<CustomerEntity> call(LoginCustomerParams params) async {
    return await repository.loginCustomerWithEmail(
      email: params.email,
      password: params.password,
      rememberMe: params.rememberMe,
    );
  }
}
