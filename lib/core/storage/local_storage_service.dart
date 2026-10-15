import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing local storage persistence via SharedPreferences.
class LocalStorageService {
  final SharedPreferences? preferences;

  LocalStorageService({this.preferences});

  // Key names specified for driver login data persistence
  static const String keyToken = 'token';
  static const String keyDriverId = 'driver.id';
  static const String keyFirstName = 'driver.firstName';
  static const String keyLastName = 'driver.lastName';
  static const String keyPhone = 'driver.phone';
  static const String keyEmail = 'driver.email';
  static const String keyDriverCustomId = 'driver.driverId';

  Future<SharedPreferences> _getPrefs() async {
    return preferences ?? await SharedPreferences.getInstance();
  }

  /// Persists driver login fields into SharedPreferences safely.
  Future<void> saveLoginData({
    required String token,
    required String id,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? driverId,
  }) async {
    try {
      final prefs = await _getPrefs();
      if (token.isNotEmpty) {
        await prefs.setString(keyToken, token);
      }
      if (id.isNotEmpty) {
        await prefs.setString(keyDriverId, id);
      }
      if (firstName != null && firstName.isNotEmpty) {
        await prefs.setString(keyFirstName, firstName);
      } else {
        await prefs.remove(keyFirstName);
      }
      if (lastName != null && lastName.isNotEmpty) {
        await prefs.setString(keyLastName, lastName);
      } else {
        await prefs.remove(keyLastName);
      }
      if (phone != null && phone.isNotEmpty) {
        await prefs.setString(keyPhone, phone);
      }
      if (email != null && email.isNotEmpty) {
        await prefs.setString(keyEmail, email);
      }
      if (driverId != null && driverId.isNotEmpty) {
        await prefs.setString(keyDriverCustomId, driverId);
      } else {
        await prefs.remove(keyDriverCustomId);
      }
    } catch (e) {
      debugPrint('⚠️ [LocalStorageService] Error saving login data: $e');
    }
  }

  /// Convenience method to save directly from API response Map.
  Future<void> saveLoginResponse({
    required String token,
    Map<String, dynamic>? driver,
  }) async {
    try {
      final id = driver?['id']?.toString() ?? driver?['_id']?.toString() ?? '';
      final firstName = driver?['firstName']?.toString();
      final lastName = driver?['lastName']?.toString();
      final phone = driver?['phone']?.toString();
      final email = driver?['email']?.toString();
      final driverId = driver?['driverId']?.toString();

      await saveLoginData(
        token: token,
        id: id,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        email: email,
        driverId: driverId,
      );
    } catch (e) {
      debugPrint('⚠️ [LocalStorageService] Error saving login response: $e');
    }
  }

  /// Retrieves stored authentication token.
  Future<String?> getToken() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getString(keyToken);
    } catch (e) {
      debugPrint('⚠️ [LocalStorageService] Error getting token: $e');
      return null;
    }
  }

  /// Retrieves stored driver ID (driver.id).
  Future<String?> getDriverId() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getString(keyDriverId);
    } catch (e) {
      debugPrint('⚠️ [LocalStorageService] Error getting driver id: $e');
      return null;
    }
  }

  /// Retrieves stored driver first name (driver.firstName).
  Future<String?> getFirstName() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getString(keyFirstName);
    } catch (e) {
      debugPrint('⚠️ [LocalStorageService] Error getting first name: $e');
      return null;
    }
  }

  /// Retrieves stored driver last name (driver.lastName).
  Future<String?> getLastName() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getString(keyLastName);
    } catch (e) {
      debugPrint('⚠️ [LocalStorageService] Error getting last name: $e');
      return null;
    }
  }

  /// Retrieves stored driver phone (driver.phone).
  Future<String?> getPhone() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getString(keyPhone);
    } catch (e) {
      debugPrint('⚠️ [LocalStorageService] Error getting phone: $e');
      return null;
    }
  }

  /// Retrieves stored driver email (driver.email).
  Future<String?> getEmail() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getString(keyEmail);
    } catch (e) {
      debugPrint('⚠️ [LocalStorageService] Error getting email: $e');
      return null;
    }
  }

  /// Retrieves stored custom driver identifier (driver.driverId).
  Future<String?> getDriverCustomId() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getString(keyDriverCustomId);
    } catch (e) {
      debugPrint('⚠️ [LocalStorageService] Error getting driverId: $e');
      return null;
    }
  }

  /// Retrieves stored driver details map.
  Future<Map<String, String?>> getDriverData() async {
    try {
      final prefs = await _getPrefs();
      return {
        'token': prefs.getString(keyToken),
        'id': prefs.getString(keyDriverId),
        'firstName': prefs.getString(keyFirstName),
        'lastName': prefs.getString(keyLastName),
        'phone': prefs.getString(keyPhone),
        'email': prefs.getString(keyEmail),
        'driverId': prefs.getString(keyDriverCustomId),
      };
    } catch (e) {
      debugPrint('⚠️ [LocalStorageService] Error getting driver data: $e');
      return {};
    }
  }

  /// Checks if valid login token exists in storage.
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Clears only authentication and driver login keys without clearing unrelated preferences.
  Future<void> clearLoginData() async {
    try {
      final prefs = await _getPrefs();
      await prefs.remove(keyToken);
      await prefs.remove(keyDriverId);
      await prefs.remove(keyFirstName);
      await prefs.remove(keyLastName);
      await prefs.remove(keyPhone);
      await prefs.remove(keyEmail);
      await prefs.remove(keyDriverCustomId);
    } catch (e) {
      debugPrint('⚠️ [LocalStorageService] Error clearing login data: $e');
    }
  }
}
