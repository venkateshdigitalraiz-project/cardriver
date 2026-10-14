import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    return await remoteDataSource.getNotifications();
  }

  @override
  Future<NotificationEntity> sendNotification({
    required String title,
    required String message,
    String? type,
    String? recipientToken,
    Map<String, dynamic>? data,
  }) async {
    return await remoteDataSource.sendNotification(
      title: title,
      message: message,
      type: type,
      recipientToken: recipientToken,
      data: data,
    );
  }

  @override
  Stream<NotificationEntity> get onNotificationReceived =>
      remoteDataSource.onNotificationReceived;

  @override
  Future<String?> getFcmToken() async {
    return await remoteDataSource.getFcmToken();
  }

  @override
  Future<String?> refreshFcmToken() async {
    return await remoteDataSource.refreshFcmToken();
  }

  @override
  Stream<String> get onTokenRefresh => remoteDataSource.onTokenRefresh;

  @override
  Future<void> markAsRead(String id) async {
    await remoteDataSource.markAsRead(id);
  }
}
