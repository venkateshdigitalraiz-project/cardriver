import '../repositories/notification_repository.dart';

class GetFcmTokenUseCase {
  final NotificationRepository repository;

  GetFcmTokenUseCase(this.repository);

  Future<String?> call() async {
    return await repository.getFcmToken();
  }
}
