class ApiEndpoints {
  // Main Application Server
  // current Live Host  http://194.238.19.189:2200
  // current Test Host  http://192.168.0.161:3000
  static const String _host = 'https://drivonix.co.in';
  // static const String _host = 'http://201.18.205.130:3000';
  // static const String _host = 'http://192.168.0.161:3000';
  // static const String _host = 'http://194.238.19.189:2200';
  static const String baseUrl = '$_host/api';

  // Socket.IO server root (no /api prefix)
  static const String socketUrl = _host;

  // Login & Driver Settings Server (Only for login screen intro banners & assets)
  static const String serverBaseUrl = _host;
  static const String driverSettings = '$baseUrl/driver/settings';

  // Driver Authentication
  static const String driverLogin = '$baseUrl/driver/login';
  static const String driverVerifyOtp = '$baseUrl/driver/verify-otp';
  static const String driverRegister = '$baseUrl/driver/register';

  // Driver Rides & Bookings
  static const String driverAvailableRides = '$baseUrl/driver/available-rides';
  static String driverAcceptRide(String rideId) =>
      '$driverAvailableRides/$rideId/accept';
  static String driverRejectRide(String rideId) =>
      '$driverAvailableRides/$rideId/reject';
  static const String driverBookings = '$baseUrl/driver/bookings';
  static String driverBookingDetails(String bookingId) =>
      '$driverBookings/$bookingId';
  static const String driverTripStatus = '$driverBookings/trip-status';
  static const String driverDtoDBookings = '$baseUrl/driver/d-to-d-bookings';

  // Driver Subscriptions
  static const String driverSubscriptionPlans =
      '$baseUrl/driver/subscription-plans';
  static const String driverSubscription = '$baseUrl/driver/subscription';

  // Driver Profile
  static const String driverProfile = '$baseUrl/driver/profile';

  // Driver Jobs
  static const String driverJobs = '$baseUrl/driver/jobs';
  static String driverAcceptJob(String jobId) => '$driverJobs/$jobId/accept';
  static String driverRejectJob(String jobId) => '$driverJobs/$jobId/reject';

  // Common Charges
  static const String commonCharges = '$baseUrl/common/charges';
  static const String charges = '$baseUrl/common/charges';

  /// Helper to convert relative server paths (like /uploads/xyz.jpg) to full URLs
  static String resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return '$serverBaseUrl$cleanPath';
  }
}
