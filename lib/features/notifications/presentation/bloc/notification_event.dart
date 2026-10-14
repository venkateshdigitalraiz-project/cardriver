import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_entity.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Load list of notifications and fetch FCM device token
class LoadNotifications extends NotificationEvent {
  const LoadNotifications();
}

/// Triggered when an incoming FCM notification message is received
class NotificationReceived extends NotificationEvent {
  final NotificationEntity notification;

  const NotificationReceived(this.notification);

  @override
  List<Object?> get props => [notification];
}

/// Send a new notification / message
class SendNotificationEvent extends NotificationEvent {
  final String title;
  final String message;
  final String type;
  final String? recipientToken;
  final Map<String, dynamic>? data;

  const SendNotificationEvent({
    required this.title,
    required this.message,
    this.type = 'message',
    this.recipientToken,
    this.data,
  });

  @override
  List<Object?> get props => [title, message, type, recipientToken, data];
}

/// Mark a specific notification as read
class MarkNotificationAsRead extends NotificationEvent {
  final String id;

  const MarkNotificationAsRead(this.id);

  @override
  List<Object?> get props => [id];
}

/// Update current device FCM push token in state
class UpdateFcmToken extends NotificationEvent {
  final String token;

  const UpdateFcmToken(this.token);

  @override
  List<Object?> get props => [token];
}

/// Invalidate and refresh device FCM push token (e.g., during logout or manual refresh)
class RefreshFcmToken extends NotificationEvent {
  const RefreshFcmToken();
}

