import '../../../../core/errors/exceptions.dart';
import '../models/customer_model.dart';
import '../models/driver_model.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/driver_entity.dart';
import '../../../../core/network/api_endpoints.dart';
import 'package:dio/dio.dart';

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
    final dio = Dio()..interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
    try {
      final response = await dio.post(
        ApiEndpoints.driverLogin,
        options: Options(headers: {'content-type': 'application/json'}),
        data: {'phone': phone},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw AuthException(message: 'Failed to send OTP. Server responded with ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw AuthException(message: _handleDioError(e));
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw const AuthException(message: 'Something went wrong. Please try again.');
    }
  }

  @override
  Future<CustomerModel> verifyCustomerOtp({
    required String phone,
    required String otp,
  }) async {
    final dio = Dio()..interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
    try {
      final response = await dio.post(
        ApiEndpoints.driverVerifyOtp,
        options: Options(headers: {'content-type': 'application/json'}),
        data: {'phone': phone, 'otp': otp},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CustomerModel(
          id: 'cust_api_${DateTime.now().millisecondsSinceEpoch}',
          firstName: 'Verified',
          lastName: 'Driver',
          name: 'Verified Driver',
          email: 'driver.api@cardriver.com',
          phone: phone,
          avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&auto=format&fit=crop&q=80',
          rating: 5.0,
          totalRides: 0,
          preferredPayment: CustomerPaymentMethod.card,
          token: response.data is Map && response.data['token'] != null 
              ? response.data['token'] 
              : 'api_token_${DateTime.now().millisecondsSinceEpoch}',
        );
      } else {
        throw AuthException(message: 'The OTP code is invalid or has expired.');
      }
    } on DioException catch (e) {
      throw AuthException(message: _handleDioError(e));
    } catch (e) {
      if (e is AuthException) rethrow;
      throw const AuthException(message: 'Something went wrong. Please try again.');
    }
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
    final dio = Dio()..interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
    try {
      final response = await dio.post(
        ApiEndpoints.driverVerifyOtp,
        options: Options(headers: {'content-type': 'application/json'}),
        data: {'phone': phone, 'otp': otp},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return mockDrivers.first;
      } else {
        throw AuthException(message: 'The OTP code is invalid or has expired.');
      }
    } on DioException catch (e) {
      throw AuthException(message: _handleDioError(e));
    } catch (e) {
      if (e is AuthException) rethrow;
      throw const AuthException(message: 'Something went wrong. Please try again.');
    }
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

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Please check your internet connection.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 400 || statusCode == 401) {
          if (e.response?.data is Map && e.response?.data['message'] != null) {
            return e.response?.data['message'];
          }
          return 'Invalid request. Please check your details.';
        } else if (statusCode != null && statusCode >= 500) {
          return 'Server is currently unavailable. Please try again later.';
        }
        return 'Something went wrong. Please try again.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please connect to the internet and try again.';
      default:
        return 'An unexpected network error occurred. Please try again.';
    }
  }
}
