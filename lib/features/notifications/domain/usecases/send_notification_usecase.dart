import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

class SendNotificationParams {
  final String title;
  final String message;
  final String? type;
  final String? recipientToken;
  final Map<String, dynamic>? data;

  const SendNotificationParams({
    required this.title,
    required this.message,
    this.type,
    this.recipientToken,
    this.data,
  });
}

class SendNotificationUseCase {
  final NotificationRepository repository;

  SendNotificationUseCase(this.repository);

  Future<NotificationEntity> call(SendNotificationParams params) async {
    return await repository.sendNotification(
      title: params.title,
      message: params.message,
      type: params.type,
      recipientToken: params.recipientToken,
      data: params.data,
    );
  }
}
