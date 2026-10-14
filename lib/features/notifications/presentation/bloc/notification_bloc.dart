import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/usecases/get_fcm_token_usecase.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/refresh_fcm_token_usecase.dart';
import '../../domain/usecases/send_notification_usecase.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final SendNotificationUseCase sendNotificationUseCase;
  final GetFcmTokenUseCase getFcmTokenUseCase;
  final RefreshFcmTokenUseCase? refreshFcmTokenUseCase;
  final NotificationRepository repository;

  StreamSubscription<NotificationEntity>? _notificationSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;

  NotificationBloc({
    required this.getNotificationsUseCase,
    required this.sendNotificationUseCase,
    required this.getFcmTokenUseCase,
    this.refreshFcmTokenUseCase,
    required this.repository,
  }) : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<NotificationReceived>(_onNotificationReceived);
    on<SendNotificationEvent>(_onSendNotification);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<UpdateFcmToken>(_onUpdateFcmToken);
    on<RefreshFcmToken>(_onRefreshFcmToken);

    // Listen to real-time incoming push notification stream
    _notificationSubscription = repository.onNotificationReceived.listen(
      (notification) {
        add(NotificationReceived(notification));
      },
    );

    // Listen to token refresh stream (e.g., when token is refreshed on logout or rotation)
    _tokenRefreshSubscription = repository.onTokenRefresh.listen(
      (newToken) {
        add(UpdateFcmToken(newToken));
      },
    );
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      final notifications = await getNotificationsUseCase.call();
      final token = await getFcmTokenUseCase.call();
      emit(NotificationLoaded(notifications, fcmToken: token));
    } catch (e) {
      emit(NotificationError('Failed to load notifications: ${e.toString()}'));
    }
  }

  void _onNotificationReceived(
    NotificationReceived event,
    Emitter<NotificationState> emit,
  ) {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;
      final currentList = List<NotificationEntity>.from(currentState.notifications);
      
      // Avoid duplicate notifications by ID
      currentList.removeWhere((n) => n.id == event.notification.id);
      currentList.insert(0, event.notification);

      emit(currentState.copyWith(
        notifications: currentList,
        newlyReceived: event.notification,
      ));
    } else {
      emit(NotificationLoaded(
        [event.notification],
        newlyReceived: event.notification,
      ));
    }
  }

  Future<void> _onSendNotification(
    SendNotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    final currentState = state;
    if (currentState is NotificationLoaded) {
      emit(currentState.copyWith(isSending: true));
    }

    try {
      final sentNotification = await sendNotificationUseCase.call(
        SendNotificationParams(
          title: event.title,
          message: event.message,
          type: event.type,
          recipientToken: event.recipientToken,
          data: event.data,
        ),
      );

      if (state is NotificationLoaded) {
        final current = state as NotificationLoaded;
        final updated = List<NotificationEntity>.from(current.notifications);
        if (!updated.any((n) => n.id == sentNotification.id)) {
          updated.insert(0, sentNotification);
        }
        emit(current.copyWith(
          isSending: false,
          notifications: updated,
          sendSuccessMessage: 'Notification "${event.title}" sent successfully!',
        ));
      }
    } catch (e) {
      if (state is NotificationLoaded) {
        emit((state as NotificationLoaded).copyWith(isSending: false));
      }
    }
  }

  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    await repository.markAsRead(event.id);
    if (state is NotificationLoaded) {
      final current = state as NotificationLoaded;
      final updated = current.notifications.map((n) {
        if (n.id == event.id) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();
      emit(current.copyWith(notifications: updated));
    }
  }

  void _onUpdateFcmToken(
    UpdateFcmToken event,
    Emitter<NotificationState> emit,
  ) {
    if (state is NotificationLoaded) {
      emit((state as NotificationLoaded).copyWith(fcmToken: event.token));
    }
  }

  Future<void> _onRefreshFcmToken(
    RefreshFcmToken event,
    Emitter<NotificationState> emit,
  ) async {
    final newToken = refreshFcmTokenUseCase != null
        ? await refreshFcmTokenUseCase!.call()
        : await repository.refreshFcmToken();
    if (newToken != null && state is NotificationLoaded) {
      emit((state as NotificationLoaded).copyWith(fcmToken: newToken));
    }
  }

  @override
  Future<void> close() {
    _notificationSubscription?.cancel();
    _tokenRefreshSubscription?.cancel();
    return super.close();
  }
}
