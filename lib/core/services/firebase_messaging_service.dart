import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../firebase/firebase_options.dart';

/// Top-level background message handler required by Firebase Messaging.
/// Handles background and terminated state pushes for both data-only and notification messages.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (_) {
    try {
      await Firebase.initializeApp();
    } catch (_) {}
  }

  final title = message.notification?.title ??
      message.data['title']?.toString() ??
      message.data['heading']?.toString() ??
      message.data['subject']?.toString() ??
      'New Ride Notification';

  final body = message.notification?.body ??
      message.data['body']?.toString() ??
      message.data['message']?.toString() ??
      message.data['content']?.toString() ??
      message.data['description']?.toString() ??
      'You have received an update';

  debugPrint('🔔 [Background FCM] Received: id=${message.messageId}, title=$title, body=$body');

  // If the push message is data-only (no system 'notification' object in FCM payload),
  // Android will NOT display a status-bar notification by default.
  // We trigger it via FlutterLocalNotificationsPlugin so the driver receives an alert banner, sound, & vibration.
  if (message.notification == null) {
    try {
      final localNotifications = FlutterLocalNotificationsPlugin();
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings();
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );
      await localNotifications.initialize(settings: initSettings);

      final androidDetails = AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription: 'This channel is used for important ride alerts, updates, and messages.',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
        channelShowBadge: true,
        visibility: NotificationVisibility.public,
        category: AndroidNotificationCategory.message,
        styleInformation: BigTextStyleInformation(body),
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await localNotifications.show(
        id: message.hashCode,
        title: title,
        body: body,
        notificationDetails: details,
        payload: message.data['type']?.toString() ?? 'general',
      );
    } catch (e) {
      debugPrint('⚠️ [Background FCM Notification Error] $e');
    }
  }
}

/// Core service encapsulating Firebase Cloud Messaging (FCM) operations:
/// - Safe multiplatform initialization with driverbooking-4b700 credentials
/// - High-importance notification channel registration for Android
/// - Local heads-up notifications display for foreground and background messages
/// - Device FCM push token retrieval and token refresh stream
/// - Topic subscriptions ('drivers', 'all', 'driver', 'rides') for ride dispatches
/// - Receiving foreground, background, and opened-app messages
class FirebaseMessagingService {
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();
  factory FirebaseMessagingService() => _instance;
  FirebaseMessagingService._internal();

  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  static String? _cachedToken;
  static String? get cachedToken => _cachedToken;

  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final StreamController<RemoteMessage> _messageStreamController =
      StreamController<RemoteMessage>.broadcast();

  Stream<RemoteMessage> get onMessageStream => _messageStreamController.stream;

  final StreamController<String> _tokenRefreshStreamController =
      StreamController<String>.broadcast();

  Stream<String> get onTokenRefreshStream => _tokenRefreshStreamController.stream;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important ride alerts, updates, and messages.',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  /// Initializes Local Notifications & Firebase Messaging safely
  Future<void> initialize() async {
    // 1. Initialize FlutterLocalNotificationsPlugin first for Android/iOS channels
    await _initLocalNotifications();

    // 2. Initialize Firebase with driverbooking-4b700 project credentials
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      _isInitialized = true;
      debugPrint('✅ [Firebase] Initialized successfully with driverbooking-4b700');
    } catch (e) {
      try {
        if (Firebase.apps.isEmpty) {
          await Firebase.initializeApp();
        }
        _isInitialized = true;
      } catch (err) {
        debugPrint('⚠️ [Firebase] initializeApp fallback notice: $err');
        _isInitialized = false;
      }
    }

    if (_isInitialized) {
      try {
        // 3. Register top-level background message handler
        FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

        // 4. Request user notification permissions (including Android 13+)
        await requestPermission();

        // 5. Set foreground presentation options
        await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

        // 6. Subscribe to broadcast topics for dispatch alerts
        try {
          await FirebaseMessaging.instance.subscribeToTopic('all');
          await FirebaseMessaging.instance.subscribeToTopic('drivers');
          await FirebaseMessaging.instance.subscribeToTopic('driver');
          await FirebaseMessaging.instance.subscribeToTopic('rides');
          debugPrint('✅ [FCM Topics] Subscribed to "all", "drivers", "driver", and "rides"');
        } catch (e) {
          debugPrint('⚠️ [FCM Topics] Failed to subscribe: $e');
        }

        // 7. Retrieve device FCM token
        await _retrieveFcmToken();

        // 8. Setup listeners for foreground, background tap, and token refresh
        _setupListeners();
      } catch (e) {
        debugPrint('⚠️ [FCM setup notice]: $e');
      }
    }
  }

  /// Initialize local notification channels and permissions
  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _localNotificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('🔔 [Local Notification Clicked]: ${response.payload}');
      },
    );

    // Create high importance channel on Android
    final androidImplementation = _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(_channel);
      try {
        await androidImplementation.requestNotificationsPermission();
      } catch (e) {
        debugPrint('⚠️ [LocalNotification Permission notice]: $e');
      }
    }
  }

  /// Displays an immediate high-priority local notification banner on screen
  Future<void> showNotification({
    int? id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      final notificationId = id ?? DateTime.now().millisecondsSinceEpoch.remainder(100000);

      final androidDetails = AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
        channelShowBadge: true,
        visibility: NotificationVisibility.public,
        category: AndroidNotificationCategory.message,
        styleInformation: BigTextStyleInformation(body),
      );

      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      );

      await _localNotificationsPlugin.show(
        id: notificationId,
        title: title,
        body: body,
        notificationDetails: details,
        payload: payload,
      );
    } catch (e) {
      debugPrint('⚠️ [showNotification Error]: $e');
    }
  }

  static bool _isRequestingPermission = false;

  /// Request user notification permissions
  Future<NotificationSettings?> requestPermission() async {
    if (!_isInitialized || _isRequestingPermission) return null;
    _isRequestingPermission = true;
    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: true,
        provisional: false,
        sound: true,
      );
      debugPrint('🔔 [FCM Permission] Authorization status: ${settings.authorizationStatus}');

      final androidImplementation = _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        try {
          await androidImplementation.requestNotificationsPermission();
        } catch (_) {}
      }

      return settings;
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
      return null;
    } finally {
      _isRequestingPermission = false;
    }
  }

  /// Retrieve the device's FCM push token
  Future<String?> getFcmToken() async {
    if (_cachedToken != null && _cachedToken!.isNotEmpty) return _cachedToken;
    return await _retrieveFcmToken();
  }

  Future<String?> _retrieveFcmToken() async {
    // 1. Try reading stored token from SharedPreferences first
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('fcm_token') ?? prefs.getString('fcmToken');
      if (stored != null && stored.isNotEmpty) {
        _cachedToken = stored;
      }
    } catch (_) {}

    if (!_isInitialized) {
      return _cachedToken;
    }

    // 2. Fetch live token from Firebase Messaging
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        _cachedToken = token;
        debugPrint('🔑 [FCM Token] $token');
        await _saveTokenToPreferences(token);
      }
      return _cachedToken;
    } catch (e) {
      debugPrint('⚠️ Error getting FCM token: $e');
      return _cachedToken;
    }
  }

  /// Persists the active FCM token into SharedPreferences under 'fcm_token' and 'fcmToken'
  static Future<void> _saveTokenToPreferences(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
      await prefs.setString('fcmToken', token);
      debugPrint('💾 [FCM] Saved FCM token to SharedPreferences: $token');
    } catch (e) {
      debugPrint('⚠️ [FCM] Error saving token to SharedPreferences: $e');
    }
  }

  /// Removes the stored FCM token from SharedPreferences
  static Future<void> _clearTokenFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('fcm_token');
      await prefs.remove('fcmToken');
      debugPrint('🗑️ [FCM] Cleared FCM token from SharedPreferences');
    } catch (e) {
      debugPrint('⚠️ [FCM] Error clearing token from SharedPreferences: $e');
    }
  }

  /// Setup foreground, background, and token refresh listeners
  void _setupListeners() {
    try {
      // 1. Foreground message stream
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        try {
          final title = message.notification?.title ??
              message.data['title']?.toString() ??
              message.data['heading']?.toString() ??
              message.data['subject']?.toString() ??
              'New Notification';

          final body = message.notification?.body ??
              message.data['body']?.toString() ??
              message.data['message']?.toString() ??
              message.data['content']?.toString() ??
              message.data['description']?.toString() ??
              '';

          debugPrint('🔔 [Foreground FCM]: $title - $body');

          // Show heads-up alert banner on device
          showNotification(
            id: message.hashCode,
            title: title,
            body: body,
            payload: message.data['type']?.toString() ?? 'general',
          );

          // Broadcast to stream listeners (NotificationBloc)
          _messageStreamController.add(message);
        } catch (e) {
          debugPrint('⚠️ [Foreground FCM listen error]: $e');
        }
      });

      // 2. Message opened app from background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('🚀 [FCM Opened from background]: ${message.notification?.title}');
        _messageStreamController.add(message);
      });

      // 3. Token refresh stream
      FirebaseMessaging.instance.onTokenRefresh.listen((String newToken) async {
        _cachedToken = newToken;
        _tokenRefreshStreamController.add(newToken);
        debugPrint('🔑 [FCM Token Refreshed]: $newToken');
        await _saveTokenToPreferences(newToken);
      });

      // 4. Initial message when launched from terminated state
      FirebaseMessaging.instance.getInitialMessage().then((initialMessage) {
        if (initialMessage != null) {
          debugPrint('🚀 [FCM Initial Message from terminated]: ${initialMessage.notification?.title}');
          _messageStreamController.add(initialMessage);
        }
      });
    } catch (e) {
      debugPrint('Error setting up FCM listeners: $e');
    }
  }

  /// Invalidates the existing FCM push token by calling [FirebaseMessaging.instance.deleteToken],
  /// clears local token cache, and requests a brand new FCM token.
  /// This ensures push notifications for the prior account are invalidated upon logout.
  Future<String?> refreshFcmToken() async {
    try {
      if (_isInitialized) {
        debugPrint('🗑️ [FCM] Deleting old FCM token upon logout...');
        await FirebaseMessaging.instance.deleteToken();
        debugPrint('✅ [FCM] Old token successfully deleted from Firebase');
      }
    } catch (e) {
      debugPrint('⚠️ [FCM] Notice during deleteToken: $e');
    }

    _cachedToken = null;
    await _clearTokenFromPreferences();

    final newToken = await _retrieveFcmToken();
    if (newToken != null && newToken.isNotEmpty) {
      _tokenRefreshStreamController.add(newToken);
      await _saveTokenToPreferences(newToken);
    }
    debugPrint('🔄 [FCM] New token generated and saved in SharedPreferences after logout: $newToken');
    return newToken;
  }

  /// Check if the app was launched by tapping a notification from terminated state
  Future<RemoteMessage?> getInitialMessage() async {
    if (!_isInitialized) return null;
    try {
      return await FirebaseMessaging.instance.getInitialMessage();
    } catch (e) {
      debugPrint('Error checking initial message: $e');
      return null;
    }
  }

  /// Emits a local or received notification into the active stream
  void emitNotification(RemoteMessage message) {
    _messageStreamController.add(message);
  }

  void dispose() {
    _messageStreamController.close();
    _tokenRefreshStreamController.close();
  }
}
