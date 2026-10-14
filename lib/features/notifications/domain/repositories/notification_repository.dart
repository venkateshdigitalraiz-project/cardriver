import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  /// Fetches stored/cached notifications
  Future<List<NotificationEntity>> getNotifications();

  /// Sends a new notification/message
  Future<NotificationEntity> sendNotification({
    required String title,
    required String message,
    String? type,
    String? recipientToken,
    Map<String, dynamic>? data,
  });

  /// Real-time stream of incoming notifications (Foreground & Background FCM messages)
  Stream<NotificationEntity> get onNotificationReceived;

  /// Retrieves the current Firebase FCM push token
  Future<String?> getFcmToken();

  /// Deletes and refreshes the Firebase FCM push token
  Future<String?> refreshFcmToken();

  /// Stream of refreshed FCM tokens
  Stream<String> get onTokenRefresh;

  /// Marks a notification as read
  Future<void> markAsRead(String id);
}
