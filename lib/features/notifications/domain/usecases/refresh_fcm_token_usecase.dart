import '../repositories/notification_repository.dart';

class RefreshFcmTokenUseCase {
  final NotificationRepository repository;

  RefreshFcmTokenUseCase(this.repository);

  Future<String?> call() async {
    return await repository.refreshFcmToken();
  }
}
