class ApiEndpoints {
  static const String baseUrl = 'http://192.168.0.161:3000/api';

  // Driver Authentication
  static const String driverLogin = '$baseUrl/driver/login';
  static const String driverVerifyOtp = '$baseUrl/driver/verify-otp';
}
