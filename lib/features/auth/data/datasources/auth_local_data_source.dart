import '../models/customer_model.dart';
import '../models/driver_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheCustomer(CustomerModel customer);
  Future<CustomerModel?> getCachedCustomer();
  Future<void> cacheDriver(DriverModel driver);
  Future<DriverModel?> getCachedDriver();
  Future<void> clearCache();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  CustomerModel? _cachedCustomer;
  DriverModel? _cachedDriver;

  @override
  Future<void> cacheCustomer(CustomerModel customer) async {
    _cachedCustomer = customer;
  }

  @override
  Future<CustomerModel?> getCachedCustomer() async {
    return _cachedCustomer;
  }

  @override
  Future<void> cacheDriver(DriverModel driver) async {
    _cachedDriver = driver;
  }

  @override
  Future<DriverModel?> getCachedDriver() async {
    return _cachedDriver;
  }

  @override
  Future<void> clearCache() async {
    _cachedCustomer = null;
    _cachedDriver = null;
  }
}
