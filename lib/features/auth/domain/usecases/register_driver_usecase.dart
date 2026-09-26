import 'package:equatable/equatable.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/driver_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterDriverParams extends Equatable {
  final String? firstName;
  final String? lastName;
  final String name;
  final String email;
  final String phone;
  final String password;
  final String vehicleModel;
  final String vehiclePlate;
  final DriverServiceType serviceType;

  const RegisterDriverParams({
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

class RegisterDriverUseCase implements UseCase<DriverEntity, RegisterDriverParams> {
  final AuthRepository repository;

  RegisterDriverUseCase(this.repository);

  @override
  Future<DriverEntity> call(RegisterDriverParams params) async {
    return await repository.registerDriver(
      name: params.name,
      email: params.email,
      phone: params.phone,
      password: params.password,
      vehicleModel: params.vehicleModel,
      vehiclePlate: params.vehiclePlate,
      serviceType: params.serviceType,
    );
  }
}
