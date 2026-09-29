import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../models/notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  @override
  Future<List<NotificationEntity>> getNotifications() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network
    return [
      NotificationModel(
        id: '1',
        title: 'New Ride Request',
        message: 'You have a new ride request nearby.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
      ),
      NotificationModel(
        id: '2',
        title: 'Payment Received',
        message: 'A payment of Rs 450 has been credited to your wallet.',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: true,
      ),
    ];
  }
}
