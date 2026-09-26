import 'package:equatable/equatable.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/customer_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterCustomerParams extends Equatable {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String password;
  final CustomerPaymentMethod preferredPayment;

  const RegisterCustomerParams({
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

class RegisterCustomerUseCase implements UseCase<CustomerEntity, RegisterCustomerParams> {
  final AuthRepository repository;

  RegisterCustomerUseCase(this.repository);

  @override
  Future<CustomerEntity> call(RegisterCustomerParams params) async {
    return await repository.registerCustomer(
      firstName: params.firstName,
      lastName: params.lastName,
      email: params.email,
      phone: params.phone,
      password: params.password,
      preferredPayment: params.preferredPayment,
    );
  }
}
