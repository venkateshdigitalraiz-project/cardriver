import 'dart:async';
import 'package:dio/dio.dart';
import '../../../../core/services/firebase_messaging_service.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<NotificationModel> sendNotification({
    required String title,
    required String message,
    String? type,
    String? recipientToken,
    Map<String, dynamic>? data,
  });
  Stream<NotificationModel> get onNotificationReceived;
  Future<String?> getFcmToken();
  Future<String?> refreshFcmToken();
  Stream<String> get onTokenRefresh;
  Future<void> markAsRead(String id);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final FirebaseMessagingService messagingService;
  final Dio? dio;

  final StreamController<NotificationModel> _incomingController =
      StreamController<NotificationModel>.broadcast();

  // In-memory notification store
  final List<NotificationModel> _notifications = [];

  NotificationRemoteDataSourceImpl({
    required this.messagingService,
    this.dio,
  }) {
    _initMockNotifications();
    _listenToFirebaseMessages();
  }

  void _initMockNotifications() {
    _notifications.addAll([
      NotificationModel(
        id: 'notif_001',
        title: 'New Ride Request',
        message: 'You have a new ride request nearby (2.3 km away).',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
        type: 'ride',
        sender: 'Dispatcher',
      ),
      NotificationModel(
        id: 'notif_002',
        title: 'Payment Credited',
        message: 'A payment of ₹450.00 has been credited to your wallet.',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
        type: 'payment',
        sender: 'Billing System',
      ),
      NotificationModel(
        id: 'notif_003',
        title: 'Document Approved',
        message: 'Your Driving License has been successfully verified.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
        type: 'system',
        sender: 'Admin Support',
      ),
    ]);
  }

  void _listenToFirebaseMessages() {
    messagingService.onMessageStream.listen((remoteMessage) {
      final model = NotificationModel.fromRemoteMessage(remoteMessage);
      _notifications.insert(0, model);
      _incomingController.add(model);
    });
  }

  @override
  Stream<NotificationModel> get onNotificationReceived => _incomingController.stream;

  @override
  Future<List<NotificationModel>> getNotifications() async {
    // Return newest first
    return List.unmodifiable(_notifications);
  }

  @override
  Future<NotificationModel> sendNotification({
    required String title,
    required String message,
    String? type,
    String? recipientToken,
    Map<String, dynamic>? data,
  }) async {
    final newNotification = NotificationModel(
      id: 'sent_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      createdAt: DateTime.now(),
      isRead: false,
      type: type ?? 'message',
      sender: 'Driver App',
      data: data,
    );

    // 1. Add to local notifications list
    _notifications.insert(0, newNotification);

    // 2. Broadcast via incoming stream so listeners receive the message
    _incomingController.add(newNotification);

    // 3. If remote API or endpoint is configured, optionally send via HTTP:
    // (Failures are caught safely without throwing unhandled exceptions)
    try {
      if (dio != null && recipientToken != null && recipientToken.isNotEmpty) {
        // Example FCM HTTP v1 / gateway send call (silently handled)
      }
    } catch (_) {}

    return newNotification;
  }

  @override
  Future<String?> getFcmToken() async {
    return await messagingService.getFcmToken();
  }

  @override
  Future<String?> refreshFcmToken() async {
    return await messagingService.refreshFcmToken();
  }

  @override
  Stream<String> get onTokenRefresh => messagingService.onTokenRefreshStream;

  @override
  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      final item = _notifications[index];
      _notifications[index] = NotificationModel(
        id: item.id,
        title: item.title,
        message: item.message,
        createdAt: item.createdAt,
        isRead: true,
        type: item.type,
        sender: item.sender,
        data: item.data,
      );
    }
  }
}
