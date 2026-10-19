import 'package:firebase_messaging/firebase_messaging.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  NotificationModel({
    required super.id,
    required super.title,
    required super.message,
    required super.createdAt,
    required super.isRead,
    super.type,
    super.sender,
    super.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title']?.toString() ?? 'New Notification',
      message: json['message']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isRead: json['is_read'] ?? false,
      type: json['type']?.toString() ?? 'general',
      sender: json['sender']?.toString(),
      data: json['data'] is Map<String, dynamic> ? json['data'] : null,
    );
  }

  /// Factory constructor to convert Firebase FCM [RemoteMessage] to [NotificationModel]
  factory NotificationModel.fromRemoteMessage(RemoteMessage message) {
    final notification = message.notification;
    final data = message.data;

    final title = notification?.title ??
        data['title']?.toString() ??
        data['heading']?.toString() ??
        data['subject']?.toString() ??
        'New Notification';
    final body = notification?.body ??
        data['body']?.toString() ??
        data['message']?.toString() ??
        data['content']?.toString() ??
        data['description']?.toString() ??
        '';
    final type = data['type']?.toString() ?? 'general';
    final sender = data['sender']?.toString() ?? 'Server';

    return NotificationModel(
      id: message.messageId ?? 'fcm_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: body,
      createdAt: message.sentTime ?? DateTime.now(),
      isRead: false,
      type: type,
      sender: sender,
      data: data,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'type': type,
      if (sender != null) 'sender': sender,
      if (data != null) 'data': data,
    };
  }
}
