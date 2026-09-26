import '../entities/customer_entity.dart';
import '../entities/driver_entity.dart';

abstract class AuthRepository {
  // Customer Auth
  Future<CustomerEntity> loginCustomerWithEmail({
    required String email,
    required String password,
    bool rememberMe = true,
  });

  Future<CustomerEntity> verifyCustomerOtp({
    required String phone,
    required String otp,
  });

  Future<CustomerEntity> loginCustomerWithSocial({
    required String provider,
  });

  Future<CustomerEntity> registerCustomer({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    CustomerPaymentMethod preferredPayment = CustomerPaymentMethod.card,
  });

  // Driver Auth
  Future<DriverEntity> loginWithEmail({
    required String email,
    required String password,
    bool rememberMe = true,
  });

  Future<void> sendOtp({
    required String phone,
  });

  Future<DriverEntity> verifyOtp({
    required String phone,
    required String otp,
  });

  Future<DriverEntity> loginWithSocial({
    required String provider,
  });

  Future<DriverEntity> registerDriver({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String vehicleModel,
    required String vehiclePlate,
    required DriverServiceType serviceType,
  });

  Future<CustomerEntity?> getCurrentCustomer();
  Future<DriverEntity?> getCurrentDriver();
  Future<void> logout();
}
