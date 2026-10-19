import '../../../../core/storage/local_storage_service.dart';
import '../models/customer_model.dart';
import '../models/driver_model.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/driver_entity.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheCustomer(CustomerModel customer);
  Future<CustomerModel?> getCachedCustomer();
  Future<void> cacheDriver(DriverModel driver);
  Future<DriverModel?> getCachedDriver();
  Future<void> clearCache();
  Future<void> saveFcmToken(String fcmToken);
  Future<String?> getFcmToken();
  Future<void> clearFcmToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final LocalStorageService _storageService;
  CustomerModel? _cachedCustomer;
  DriverModel? _cachedDriver;

  AuthLocalDataSourceImpl({LocalStorageService? storageService})
    : _storageService = storageService ?? LocalStorageService();

  @override
  Future<void> cacheCustomer(CustomerModel customer) async {
    _cachedCustomer = customer;
    await _storageService.saveLoginData(
      token: customer.token,
      id: customer.id,
      firstName: customer.firstName,
      lastName: customer.lastName,
      phone: customer.phone,
      email: customer.email,
      driverId: customer.driverId,
    );
  }

  @override
  Future<CustomerModel?> getCachedCustomer() async {
    if (_cachedCustomer != null) {
      return _cachedCustomer;
    }
    final data = await _storageService.getDriverData();
    final token = data['token'];
    if (token == null || token.isEmpty) {
      return null;
    }
    final id = data['id'] ?? '';
    final firstName = data['firstName'] ?? '';
    final lastName = data['lastName'] ?? '';
    final name = ('$firstName $lastName'.trim()).isNotEmpty
        ? '$firstName $lastName'.trim()
        : 'Driver';
    final email = data['email'] ?? '';
    final phone = data['phone'] ?? '';
    final driverId = data['driverId'];

    _cachedCustomer = CustomerModel(
      id: id,
      firstName: firstName,
      lastName: lastName,
      name: name,
      email: email,
      phone: phone,
      avatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&auto=format&fit=crop&q=80',
      rating: 5.0,
      totalRides: 0,
      preferredPayment: CustomerPaymentMethod.card,
      token: token,
      driverId: driverId,
    );
    return _cachedCustomer;
  }

  @override
  Future<void> cacheDriver(DriverModel driver) async {
    _cachedDriver = driver;
    final nameParts = driver.name.split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    await _storageService.saveLoginData(
      token: driver.token,
      id: driver.id,
      firstName: firstName,
      lastName: lastName,
      phone: driver.phone,
      email: driver.email,
      driverId: driver.driverId,
    );
  }

  @override
  Future<DriverModel?> getCachedDriver() async {
    if (_cachedDriver != null) {
      return _cachedDriver;
    }
    final data = await _storageService.getDriverData();
    final token = data['token'];
    if (token == null || token.isEmpty) {
      return null;
    }
    final id = data['id'] ?? '';
    final firstName = data['firstName'] ?? '';
    final lastName = data['lastName'] ?? '';
    final name = ('$firstName $lastName'.trim()).isNotEmpty
        ? '$firstName $lastName'.trim()
        : 'Driver';
    final email = data['email'] ?? '';
    final phone = data['phone'] ?? '';
    final driverId = data['driverId'];

    _cachedDriver = DriverModel(
      id: id,
      name: name,
      email: email,
      phone: phone,
      avatarUrl:
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400&auto=format&fit=crop&q=80',
      vehicleModel: 'Toyota Camry Hybrid (2024)',
      vehiclePlate: 'CAB-8924',
      serviceType: DriverServiceType.taxi,
      rating: 5.0,
      totalTrips: 0,
      todayEarnings: 0.0,
      isOnline: true,
      token: token,
      driverId: driverId,
    );
    return _cachedDriver;
  }

  @override
  Future<void> clearCache() async {
    _cachedCustomer = null;
    _cachedDriver = null;
    await _storageService.clearLoginData();
  }

  @override
  Future<void> saveFcmToken(String fcmToken) async {
    await _storageService.saveFcmToken(fcmToken);
  }

  @override
  Future<String?> getFcmToken() async {
    return await _storageService.getFcmToken();
  }

  @override
  Future<void> clearFcmToken() async {
    await _storageService.clearFcmToken();
  }
}
