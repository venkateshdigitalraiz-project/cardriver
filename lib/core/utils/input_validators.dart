/// Input validation rules for authentication and driver forms
class InputValidators {
  InputValidators._();

  static String? validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter first name';
    }
    if (value.trim().length < 2) {
      return 'First name must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s.]+$').hasMatch(value.trim())) {
      return 'First name should contain only letters';
    }
    return null;
  }

  static String? validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter last name';
    }
    if (!RegExp(r'^[a-zA-Z\s.]+$').hasMatch(value.trim())) {
      return 'Last name should contain only letters';
    }
    return null;
  }

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
    if (cleanPhone.length != 10) {
      return 'Phone number must be exactly 10 digits';
    }
    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your address';
    }
    if (value.trim().length < 5) {
      return 'Please enter a complete address';
    }
    return null;
  }

  static String? validateLicenseNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Driving license number is required';
    }
    final cleanLicense = value.trim();
    if (cleanLicense.length < 5) {
      return 'Please enter a valid driving license number';
    }
    return null;
  }

  static String? validateAadhar(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Aadhaar number is required';
    }
    final digits = value.replaceAll(RegExp(r'\s+'), '');
    if (!RegExp(r'^\d{12}$').hasMatch(digits)) {
      return 'Aadhaar number must be exactly 12 digits';
    }
    return null;
  }

  static String? validatePan(String? value, {bool isRequired = true}) {
    if (value == null || value.trim().isEmpty) {
      if (isRequired) return 'PAN card number is required';
      return null;
    }
    final cleanPan = value.trim().toUpperCase();
    if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(cleanPan)) {
      return 'Please enter a valid 10-character PAN (e.g. ABCDE1234F)';
    }
    return null;
  }

  static String? validatePvc(String? value, {bool isRequired = true}) {
    if (value == null || value.trim().isEmpty) {
      if (isRequired) return 'PVC number (Police Verification) is required';
      return null;
    }
    final cleanPvc = value.trim().toUpperCase();
    if (cleanPvc.length < 3) {
      return 'Please enter a valid PVC number';
    }
    return null;
  }

  static String? validatePassport(String? value, {bool isRequired = true}) {
    if (value == null || value.trim().isEmpty) {
      if (isRequired) return 'Passport ID is required';
      return null;
    }
    final cleanPassport = value.trim().toUpperCase();
    if (!RegExp(r'^[A-Z][0-9]{7,8}$|^[A-Z0-9]{8,9}$').hasMatch(cleanPassport)) {
      return 'Please enter a valid Passport ID (e.g. A1234567)';
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
