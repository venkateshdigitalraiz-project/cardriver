import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_entity.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationEntity> notifications;
  final String? fcmToken;
  final bool isSending;
  final String? sendSuccessMessage;
  final NotificationEntity? newlyReceived;

  const NotificationLoaded(
    this.notifications, {
    this.fcmToken,
    this.isSending = false,
    this.sendSuccessMessage,
    this.newlyReceived,
  });

  NotificationLoaded copyWith({
    List<NotificationEntity>? notifications,
    String? fcmToken,
    bool? isSending,
    String? sendSuccessMessage,
    NotificationEntity? newlyReceived,
    bool clearNewlyReceived = false,
  }) {
    return NotificationLoaded(
      notifications ?? this.notifications,
      fcmToken: fcmToken ?? this.fcmToken,
      isSending: isSending ?? this.isSending,
      sendSuccessMessage: sendSuccessMessage,
      newlyReceived: clearNewlyReceived ? null : (newlyReceived ?? this.newlyReceived),
    );
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  List<Object?> get props => [
        notifications,
        fcmToken,
        isSending,
        sendSuccessMessage,
        newlyReceived,
      ];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}
