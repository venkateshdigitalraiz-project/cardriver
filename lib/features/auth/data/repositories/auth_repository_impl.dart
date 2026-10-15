import 'package:flutter/foundation.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/firebase_messaging_service.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/driver_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/driver_register_body.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final FirebaseMessagingService? messagingService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    this.messagingService,
  });

  @override
  Future<CustomerEntity> loginCustomerWithEmail({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    try {
      final customer = await remoteDataSource.loginCustomerWithEmail(
        email: email,
        password: password,
      );
      if (rememberMe) {
        await localDataSource.cacheCustomer(customer);
      }
      return customer;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Authentication failed: ${e.toString()}');
    }
  }

  @override
  Future<void> sendOtp({required String phone}) async {
    try {
      await remoteDataSource.sendOtp(phone: phone);
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to send OTP: ${e.toString()}');
    }
  }

  @override
  Future<CustomerEntity> verifyCustomerOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final customer = await remoteDataSource.verifyCustomerOtp(
        phone: phone,
        otp: otp,
      );
      await localDataSource.cacheCustomer(customer);
      return customer;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'OTP verification failed: ${e.toString()}',
      );
    }
  }

  @override
  Future<CustomerEntity> loginCustomerWithSocial({
    required String provider,
  }) async {
    try {
      final customer = await remoteDataSource.loginCustomerWithSocial(
        provider: provider,
      );
      await localDataSource.cacheCustomer(customer);
      return customer;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Social login failed: ${e.toString()}');
    }
  }

  @override
  Future<CustomerEntity> registerCustomer({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    CustomerPaymentMethod preferredPayment = CustomerPaymentMethod.card,
  }) async {
    try {
      final customer = await remoteDataSource.registerCustomer(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
        preferredPayment: preferredPayment,
      );
      await localDataSource.cacheCustomer(customer);
      return customer;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<DriverEntity> loginWithEmail({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    final driver = await remoteDataSource.loginWithEmail(
      email: email,
      password: password,
    );
    return driver;
  }

  @override
  Future<DriverEntity> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final driver = await remoteDataSource.verifyOtp(phone: phone, otp: otp);
    await localDataSource.cacheDriver(driver);
    return driver;
  }

  @override
  Future<DriverEntity> loginWithSocial({required String provider}) async {
    final driver = await remoteDataSource.loginWithSocial(provider: provider);
    return driver;
  }

  @override
  Future<DriverEntity> registerDriver({
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
    final driver = await remoteDataSource.registerDriver(
      body: body,
      name: name,
      email: email,
      phone: phone,
      password: password,
      vehicleModel: vehicleModel,
      vehiclePlate: vehiclePlate,
      serviceType: serviceType,
      firstName: firstName,
      lastName: lastName,
      address: address,
      licenseNumber: licenseNumber,
      pancardNumber: pancardNumber,
      aadhaarNumber: aadhaarNumber,
      passportId: passportId,
      pancard: pancard,
      aadhaarCardFront: aadhaarCardFront,
      aadhaarCardBack: aadhaarCardBack,
      drivingLicense: drivingLicense,
      selfie: selfie,
      passport: passport,
      aadharNumber: aadharNumber,
      panNumber: panNumber,
      passportNumber: passportNumber,
      aadharFrontPath: aadharFrontPath,
      aadharBackPath: aadharBackPath,
      panCardPath: panCardPath,
      drivingLicensePath: drivingLicensePath,
      passportPath: passportPath,
      profilePicPath: profilePicPath,
    );
    await localDataSource.cacheDriver(driver);
    return driver;
  }

  @override
  Future<CustomerEntity?> getCurrentCustomer() async {
    return await localDataSource.getCachedCustomer();
  }

  @override
  Future<DriverEntity?> getCurrentDriver() async {
    return await localDataSource.getCachedDriver();
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearCache();
    try {
      debugPrint(
        '🔒 [AuthRepository] Logging out and refreshing device push token...',
      );
      await messagingService?.refreshFcmToken();
    } catch (e) {
      debugPrint('⚠️ [AuthRepository] Notice refreshing token on logout: $e');
    }
  }
}
