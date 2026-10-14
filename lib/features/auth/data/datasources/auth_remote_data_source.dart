import 'dart:io';
import '../../../../core/errors/exceptions.dart';
import '../models/customer_model.dart';
import '../models/driver_model.dart';
import '../models/driver_register_body.dart';
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
    DriverRegisterBody? body,
    required String name,
    required String email,
    required String phone,
    required String password,
    required String vehicleModel,
    required String vehiclePlate,
    required DriverServiceType serviceType,
    String? firstName,
    String? lastName,
    String? address,
    String? licenseNumber,
    String? pancardNumber,
    String? aadhaarNumber,
    String? passportId,
    String? pancard,
    String? aadhaarCardFront,
    String? aadhaarCardBack,
    String? drivingLicense,
    String? selfie,
    String? passport,
    String? aadharNumber,
    String? panNumber,
    String? passportNumber,
    String? aadharFrontPath,
    String? aadharBackPath,
    String? panCardPath,
    String? drivingLicensePath,
    String? passportPath,
    String? profilePicPath,
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
    DriverRegisterBody? body,
    required String name,
    required String email,
    required String phone,
    required String password,
    required String vehicleModel,
    required String vehiclePlate,
    required DriverServiceType serviceType,
    String? firstName,
    String? lastName,
    String? address,
    String? licenseNumber,
    String? pancardNumber,
    String? aadhaarNumber,
    String? passportId,
    String? pancard,
    String? aadhaarCardFront,
    String? aadhaarCardBack,
    String? drivingLicense,
    String? selfie,
    String? passport,
    String? aadharNumber,
    String? panNumber,
    String? passportNumber,
    String? aadharFrontPath,
    String? aadharBackPath,
    String? panCardPath,
    String? drivingLicensePath,
    String? passportPath,
    String? profilePicPath,
  }) async {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 25),
        receiveTimeout: const Duration(seconds: 25),
      ),
    )..interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
        ),
      );

    try {
      final FormData formData;
      if (body != null) {
        formData = await body.toFormData();
      } else {
        formData = FormData();

        // Text fields according to cURL API specifications
        formData.fields.addAll([
          MapEntry('firstName', firstName ?? ''),
          MapEntry('lastName', lastName ?? ''),
          MapEntry('email', email),
          MapEntry('phone', phone),
          MapEntry('address', address ?? ''),
          MapEntry('licenseNumber', licenseNumber ?? ''),
          MapEntry('pancardNumber', pancardNumber ?? panNumber ?? ''),
          MapEntry('aadhaarNumber', aadhaarNumber ?? aadharNumber ?? ''),
          MapEntry('passportId', passportId ?? passportNumber ?? ''),
        ]);

        if (password.isNotEmpty) {
          formData.fields.add(MapEntry('password', password));
        }

        // Multipart files: pancard, aadhaarCardFront, aadhaarCardBack, drivingLicense, selfie, passport
        final effectivePanPath = pancard ?? panCardPath;
        if (effectivePanPath != null &&
            effectivePanPath.isNotEmpty &&
            File(effectivePanPath).existsSync()) {
          formData.files.add(MapEntry(
            'pancard',
            await MultipartFile.fromFile(
              effectivePanPath,
              filename: effectivePanPath.split(Platform.pathSeparator).last,
            ),
          ));
        } else {
          formData.fields.add(const MapEntry('pancard', ''));
        }

        final effectiveAadharFront = aadhaarCardFront ?? aadharFrontPath;
        if (effectiveAadharFront != null &&
            effectiveAadharFront.isNotEmpty &&
            File(effectiveAadharFront).existsSync()) {
          formData.files.add(MapEntry(
            'aadhaarCardFront',
            await MultipartFile.fromFile(
              effectiveAadharFront,
              filename: effectiveAadharFront.split(Platform.pathSeparator).last,
            ),
          ));
        } else {
          formData.fields.add(const MapEntry('aadhaarCardFront', ''));
        }

        final effectiveAadharBack = aadhaarCardBack ?? aadharBackPath;
        if (effectiveAadharBack != null &&
            effectiveAadharBack.isNotEmpty &&
            File(effectiveAadharBack).existsSync()) {
          formData.files.add(MapEntry(
            'aadhaarCardBack',
            await MultipartFile.fromFile(
              effectiveAadharBack,
              filename: effectiveAadharBack.split(Platform.pathSeparator).last,
            ),
          ));
        } else {
          formData.fields.add(const MapEntry('aadhaarCardBack', ''));
        }

        final effectiveLicensePath = drivingLicense ?? drivingLicensePath;
        if (effectiveLicensePath != null &&
            effectiveLicensePath.isNotEmpty &&
            File(effectiveLicensePath).existsSync()) {
          formData.files.add(MapEntry(
            'drivingLicense',
            await MultipartFile.fromFile(
              effectiveLicensePath,
              filename: effectiveLicensePath.split(Platform.pathSeparator).last,
            ),
          ));
        } else {
          formData.fields.add(const MapEntry('drivingLicense', ''));
        }

        final effectiveSelfie = selfie ?? profilePicPath;
        if (effectiveSelfie != null &&
            effectiveSelfie.isNotEmpty &&
            File(effectiveSelfie).existsSync()) {
          formData.files.add(MapEntry(
            'selfie',
            await MultipartFile.fromFile(
              effectiveSelfie,
              filename: effectiveSelfie.split(Platform.pathSeparator).last,
            ),
          ));
        } else {
          formData.fields.add(const MapEntry('selfie', ''));
        }

        final effectivePassportPath = passport ?? passportPath;
        if (effectivePassportPath != null &&
            effectivePassportPath.isNotEmpty &&
            File(effectivePassportPath).existsSync()) {
          formData.files.add(MapEntry(
            'passport',
            await MultipartFile.fromFile(
              effectivePassportPath,
              filename: effectivePassportPath.split(Platform.pathSeparator).last,
            ),
          ));
        } else {
          formData.fields.add(const MapEntry('passport', ''));
        }
      }

      final response = await dio.post(
        ApiEndpoints.driverRegister,
        options: Options(
          headers: {'content-type': 'multipart/form-data'},
        ),
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final resData = response.data;
        Map<String, dynamic> driverData = {};
        String token =
            'jwt_driver_token_${DateTime.now().millisecondsSinceEpoch}';

        if (resData is Map<String, dynamic>) {
          if (resData['driver'] is Map<String, dynamic>) {
            driverData = resData['driver'];
          } else if (resData['data'] is Map<String, dynamic>) {
            driverData = resData['data'];
          } else {
            driverData = resData;
          }
          if (resData['token'] != null) {
            token = resData['token'].toString();
          } else if (driverData['token'] != null) {
            token = driverData['token'].toString();
          }
        }

        final effectiveFirstName = body?.firstName ?? firstName;
        final effectiveLastName = body?.lastName ?? lastName;
        final fullName = (effectiveFirstName != null &&
                effectiveLastName != null &&
                effectiveFirstName.isNotEmpty)
            ? '$effectiveFirstName $effectiveLastName'.trim()
            : name;

        return DriverModel(
          id: driverData['id']?.toString() ??
              driverData['_id']?.toString() ??
              'drv_${DateTime.now().millisecondsSinceEpoch}',
          name: driverData['name']?.toString() ?? fullName,
          email: driverData['email']?.toString() ?? body?.email ?? email,
          phone: driverData['phone']?.toString() ?? body?.phone ?? phone,
          avatarUrl: driverData['avatarUrl']?.toString() ??
              body?.selfie ??
              selfie ??
              profilePicPath ??
              'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400&auto=format&fit=crop&q=80',
          vehicleModel: driverData['vehicleModel']?.toString() ?? vehicleModel,
          vehiclePlate: driverData['vehiclePlate']?.toString() ?? vehiclePlate,
          serviceType: serviceType,
          rating: (driverData['rating'] as num?)?.toDouble() ?? 5.0,
          totalTrips: (driverData['totalTrips'] as int?) ?? 0,
          todayEarnings:
              (driverData['todayEarnings'] as num?)?.toDouble() ?? 0.0,
          isOnline: (driverData['isOnline'] as bool?) ?? true,
          token: token,
          aadharNumber: driverData['aadhaarNumber']?.toString() ??
              body?.aadhaarNumber ??
              aadhaarNumber ??
              aadharNumber,
          panNumber: driverData['pancardNumber']?.toString() ??
              body?.pancardNumber ??
              pancardNumber ??
              panNumber,
          passportNumber: driverData['passportId']?.toString() ??
              body?.passportId ??
              passportId ??
              passportNumber,
          aadharFrontPath:
              body?.aadhaarCardFront ?? aadhaarCardFront ?? aadharFrontPath,
          aadharBackPath:
              body?.aadhaarCardBack ?? aadhaarCardBack ?? aadharBackPath,
          panCardPath: body?.pancard ?? pancard ?? panCardPath,
          drivingLicensePath:
              body?.drivingLicense ?? drivingLicense ?? drivingLicensePath,
          passportPath: body?.passport ?? passport ?? passportPath,
          profilePicPath: body?.selfie ?? selfie ?? profilePicPath,
        );
      } else {
        throw AuthException(
          message: 'Registration failed with status ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw AuthException(message: _handleDioError(e));
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(
        message: 'Registration failed: ${e.toString()}',
      );
    }
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
