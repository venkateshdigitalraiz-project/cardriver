import '../../../../core/errors/exceptions.dart';
import '../models/customer_model.dart';
import '../models/driver_model.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/driver_entity.dart';

abstract class AuthRemoteDataSource {
  Future<CustomerModel> loginCustomerWithEmail({
    required String email,
    required String password,
  });

  Future<void> sendOtp({
    required String phone,
  });

  Future<CustomerModel> verifyCustomerOtp({
    required String phone,
    required String otp,
  });

  Future<CustomerModel> loginCustomerWithSocial({
    required String provider,
  });

  Future<CustomerModel> registerCustomer({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    CustomerPaymentMethod preferredPayment = CustomerPaymentMethod.card,
  });

  Future<DriverModel> loginWithEmail({
    required String email,
    required String password,
  });

  Future<DriverModel> verifyOtp({
    required String phone,
    required String otp,
  });

  Future<DriverModel> loginWithSocial({
    required String provider,
  });

  Future<DriverModel> registerDriver({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String vehicleModel,
    required String vehiclePlate,
    required DriverServiceType serviceType,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  static final List<CustomerModel> mockCustomers = [
    const CustomerModel(
      id: 'cust_001',
      firstName: 'Sarah',
      lastName: 'Jenkins',
      name: 'Sarah Jenkins',
      email: 'sarah.rider@cardriver.com',
      phone: '+1 555-901-2345',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80',
      rating: 4.98,
      totalRides: 64,
      preferredPayment: CustomerPaymentMethod.card,
      token: 'jwt_customer_token_sarah_001',
    ),
    const CustomerModel(
      id: 'cust_002',
      firstName: 'James',
      lastName: 'Wilson',
      name: 'James Wilson',
      email: 'james.rider@cardriver.com',
      phone: '+1 555-888-9999',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&auto=format&fit=crop&q=80',
      rating: 5.0,
      totalRides: 128,
      preferredPayment: CustomerPaymentMethod.applePay,
      token: 'jwt_customer_token_james_002',
    ),
    const CustomerModel(
      id: 'cust_003',
      firstName: 'Emily',
      lastName: 'Blunt',
      name: 'Emily Blunt',
      email: 'emily.rider@cardriver.com',
      phone: '+1 555-777-6666',
      avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=400&auto=format&fit=crop&q=80',
      rating: 4.95,
      totalRides: 42,
      preferredPayment: CustomerPaymentMethod.cash,
      token: 'jwt_customer_token_emily_003',
    ),
  ];

  static final List<DriverModel> mockDrivers = [
    const DriverModel(
      id: 'drv_001',
      name: 'Alex Martinez',
      email: 'driver@cardriver.com',
      phone: '+1 555-019-2834',
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400&auto=format&fit=crop&q=80',
      vehicleModel: 'Toyota Camry Hybrid (2024)',
      vehiclePlate: 'CAB-8924',
      serviceType: DriverServiceType.taxi,
      rating: 4.94,
      totalTrips: 1420,
      todayEarnings: 184.50,
      isOnline: true,
      token: 'jwt_mock_token_alex_001',
    ),
  ];

  @override
  Future<CustomerModel> loginCustomerWithEmail({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final normalizedEmail = email.trim().toLowerCase();

    if (password == 'wrongpass' || password == 'error') {
      throw const AuthException(message: 'Invalid email or password. Please try again.');
    }

    final matched = mockCustomers.firstWhere(
      (c) => c.email.toLowerCase() == normalizedEmail,
      orElse: () {
        final username = normalizedEmail.split('@').first;
        final formattedName = username.isNotEmpty
            ? username[0].toUpperCase() + username.substring(1)
            : 'Passenger';

        return CustomerModel(
          id: 'cust_${DateTime.now().millisecondsSinceEpoch}',
          firstName: formattedName,
          lastName: 'Rider',
          name: '$formattedName Rider',
          email: normalizedEmail,
          phone: '+1 555-012-3456',
          avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80',
          rating: 5.0,
          totalRides: 10,
          preferredPayment: CustomerPaymentMethod.card,
          token: 'token_cust_${DateTime.now().millisecondsSinceEpoch}',
        );
      },
    );

    return matched;
  }

  @override
  Future<void> sendOtp({required String phone}) async {
    await Future.delayed(const Duration(milliseconds: 750));

    if (phone.contains('00000')) {
      throw const AuthException(message: 'Unable to send SMS code. Please check your number.');
    }
  }

  @override
  Future<CustomerModel> verifyCustomerOtp({
    required String phone,
    required String otp,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (otp == '000000') {
      throw const AuthException(message: 'The OTP code is invalid or has expired.');
    }

    final matched = mockCustomers.firstWhere(
      (c) => c.phone.replaceAll(RegExp(r'\D'), '') == phone.replaceAll(RegExp(r'\D'), ''),
      orElse: () => CustomerModel(
        id: 'cust_phone_${DateTime.now().millisecondsSinceEpoch}',
        firstName: 'Verified',
        lastName: 'Passenger',
        name: 'Verified Passenger',
        email: 'rider.phone@cardriver.com',
        phone: phone,
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&auto=format&fit=crop&q=80',
        rating: 5.0,
        totalRides: 5,
        preferredPayment: CustomerPaymentMethod.card,
        token: 'otp_token_cust_${DateTime.now().millisecondsSinceEpoch}',
      ),
    );

    return matched;
  }

  @override
  Future<CustomerModel> loginCustomerWithSocial({required String provider}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return CustomerModel(
      id: 'cust_social_${provider.toLowerCase()}',
      firstName: provider,
      lastName: 'User',
      name: '$provider Passenger',
      email: 'user@$provider.com',
      phone: '+1 555-333-2222',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80',
      rating: 4.96,
      totalRides: 15,
      preferredPayment: CustomerPaymentMethod.card,
      token: 'social_cust_token_$provider',
    );
  }

  @override
  Future<CustomerModel> registerCustomer({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    CustomerPaymentMethod preferredPayment = CustomerPaymentMethod.card,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));

    final fullName = '$firstName $lastName'.trim();

    return CustomerModel(
      id: 'cust_${DateTime.now().millisecondsSinceEpoch}',
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      name: fullName.isNotEmpty ? fullName : 'New Passenger',
      email: email.trim().toLowerCase(),
      phone: phone.trim(),
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80',
      rating: 5.0,
      totalRides: 0,
      preferredPayment: preferredPayment,
      token: 'reg_cust_token_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  Future<DriverModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    return mockDrivers.first;
  }

  @override
  Future<DriverModel> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    return mockDrivers.first;
  }

  @override
  Future<DriverModel> loginWithSocial({
    required String provider,
  }) async {
    return mockDrivers.first;
  }

  @override
  Future<DriverModel> registerDriver({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String vehicleModel,
    required String vehiclePlate,
    required DriverServiceType serviceType,
  }) async {
    return mockDrivers.first;
  }
}
