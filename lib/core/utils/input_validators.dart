/// Input validation rules for authentication and driver forms
class InputValidators {
  InputValidators._();

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final cleanPhone = value.replaceAll(RegExp(r'[\s\-()]'), '');
    if (cleanPhone.length < 9 || cleanPhone.length > 15) {
      return 'Please enter a valid mobile number';
    }
    return null;
  }

  static String? validateOtp(String? value, {int expectedLength = 6}) {
    if (value == null || value.trim().isEmpty) {
      return 'OTP code is required';
    }
    if (value.trim().length != expectedLength) {
      return 'OTP code must be $expectedLength digits';
    }
    return null;
  }
}
