class ApiEndpoints {
  static const String _host = 'http://192.168.0.161:3000';
  static const String baseUrl = '$_host/api';

  // Socket.IO server root (no /api prefix)
  static const String socketUrl = _host;

  // Driver Authentication
  static const String driverLogin = '$baseUrl/driver/login';
  static const String driverVerifyOtp = '$baseUrl/driver/verify-otp';
  static const String driverRegister = '$baseUrl/driver/register';

  // Driver Rides
  static const String driverAvailableRides = '$baseUrl/driver/available-rides';
}
