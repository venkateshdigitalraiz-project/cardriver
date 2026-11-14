import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing local storage persistence via SharedPreferences.
class LocalStorageService {
  final SharedPreferences? preferences;

  LocalStorageService({this.preferences});

  // Static in-memory cache for token collected from SharedPreferences
  static String? _cachedToken;

  /// Retrieves currently cached token synchronously if available
  static String? get currentToken => _cachedToken;

  /// Sets or clears the static token in memory
  static void setStaticToken(String? token) {
    if (token != null && token.trim().isNotEmpty) {
      _cachedToken = cleanToken(token);
    } else {
      _cachedToken = null;
    }
  }

  /// Cleans raw JWT strings from 'Bearer ', quotes, or cookies prefixes
  static String cleanToken(String raw) {
    var t = raw.trim();
    if (t.contains('user_token=')) {
      t = t.split('user_token=').last.split(';').first.trim();
    } else if (t.contains('token=')) {
      t = t.split('token=').last.split(';').first.trim();
    } else if (t.contains('driver_token=')) {
      t = t.split('driver_token=').last.split(';').first.trim();
    } else if (t.contains(';')) {
      t = t.split(';').first.trim();
    }
    if (t.toLowerCase().startsWith('bearer ')) {
      t = t.substring(7).trim();
    }
    if ((t.startsWith('"') && t.endsWith('"')) ||
        (t.startsWith("'") && t.endsWith("'"))) {
      t = t.substring(1, t.length - 1).trim();
    }
    return t;
  }

  /// Collects token from SharedPreferences and caches it in static memory.
  static Future<String> getOrCollectToken([
    LocalStorageService? service,
  ]) async {
    if (_cachedToken != null && _cachedToken!.isNotEmpty) {
      return _cachedToken!;
    }
    try {
      final prefs =
          service?.preferences ?? await SharedPreferences.getInstance();
      for (final key in [
        keyToken,
        'driver_token',
        'jwt_token',
        'auth_token',
        'token',
      ]) {
        final val = prefs.getString(key);
        if (val != null && val.trim().isNotEmpty) {
          final clean = cleanToken(val);
          if (clean.isNotEmpty) {
            _cachedToken = clean;
            return clean;
          }
        }
      }
    } catch (e) {
      debugPrint(
        '⚠️ [LocalStorageService] Error collecting token from SharedPreferences: $e',
      );
    }
    return '';
  }

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
        setStaticToken(token);
        await prefs.setString(keyToken, cleanToken(token));
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
    final t = await getOrCollectToken(this);
    return t.isNotEmpty ? t : null;
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
      setStaticToken(null);
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

  /// Key names for FCM push token in SharedPreferences
  static const String keyFcmToken = 'fcm_token';
  static const String keyFcmTokenCamel = 'fcmToken';

  /// Key name for Driver Job notification counter in SharedPreferences
  static const String keyDriverJobNotificationCount =
      'driver_job_notification_count';

  /// Saves the persistent driver job notification count
  static Future<void> saveDriverJobNotificationCount(int count) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(keyDriverJobNotificationCount, count < 0 ? 0 : count);
    } catch (e) {
      debugPrint(
        '⚠️ [LocalStorageService] Error saving driver job notif count: $e',
      );
    }
  }

  /// Retrieves the persistent driver job notification count
  static Future<int> getDriverJobNotificationCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(keyDriverJobNotificationCount) ?? 0;
    } catch (e) {
      debugPrint(
        '⚠️ [LocalStorageService] Error getting driver job notif count: $e',
      );
      return 0;
    }
  }

  /// Increments the persistent driver job notification count by 1 and returns new count
  static Future<int> incrementDriverJobNotificationCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = prefs.getInt(keyDriverJobNotificationCount) ?? 0;
      final next = current + 1;
      await prefs.setInt(keyDriverJobNotificationCount, next);
      return next;
    } catch (e) {
      debugPrint(
        '⚠️ [LocalStorageService] Error incrementing driver job notif count: $e',
      );
      return 1;
    }
  }

  /// Resets the persistent driver job notification count to 0
  static Future<void> resetDriverJobNotificationCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(keyDriverJobNotificationCount, 0);
    } catch (e) {
      debugPrint(
        '⚠️ [LocalStorageService] Error resetting driver job notif count: $e',
      );
    }
  }

  /// Persists device FCM push token into SharedPreferences.
  Future<void> saveFcmToken(String fcmToken) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setString(keyFcmToken, fcmToken);
      await prefs.setString(keyFcmTokenCamel, fcmToken);
      debugPrint(
        '💾 [LocalStorageService] Saved FCM token to SharedPreferences: $fcmToken',
      );
    } catch (e) {
      debugPrint('⚠️ [LocalStorageService] Error saving FCM token: $e');
    }
  }

  /// Retrieves stored FCM push token from SharedPreferences.
  Future<String?> getFcmToken() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getString(keyFcmToken) ?? prefs.getString(keyFcmTokenCamel);
    } catch (e) {
      debugPrint('⚠️ [LocalStorageService] Error getting FCM token: $e');
      return null;
    }
  }

  /// Clears stored FCM token from SharedPreferences.
  Future<void> clearFcmToken() async {
    try {
      final prefs = await _getPrefs();
      await prefs.remove(keyFcmToken);
      await prefs.remove(keyFcmTokenCamel);
      debugPrint(
        '🗑️ [LocalStorageService] Cleared FCM token from SharedPreferences',
      );
    } catch (e) {
      debugPrint('⚠️ [LocalStorageService] Error clearing FCM token: $e');
    }
  }
}
