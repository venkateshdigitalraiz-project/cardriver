import 'package:equatable/equatable.dart';
import 'driver_subscription_entity.dart';

/// Wraps the complete response from GET /api/driver/subscription
class SubscriptionHistoryResponseEntity extends Equatable {
  final bool hasActiveSubscription;
  final DriverSubscriptionEntity? activeSubscription;
  final List<DriverSubscriptionEntity> subscriptions;

  const SubscriptionHistoryResponseEntity({
    required this.hasActiveSubscription,
    this.activeSubscription,
    required this.subscriptions,
  });

  factory SubscriptionHistoryResponseEntity.fromJson(Map<String, dynamic> json) {
    final hasActive = json['hasActiveSubscription'] == true;

    DriverSubscriptionEntity? activeSub;
    if (json['activeSubscription'] is Map) {
      activeSub = DriverSubscriptionEntity.fromJson(
        Map<String, dynamic>.from(json['activeSubscription']),
      );
    }

    List<DriverSubscriptionEntity> subs = [];
    if (json['subscriptions'] is List) {
      subs = (json['subscriptions'] as List)
          .whereType<Map>()
          .map((m) => DriverSubscriptionEntity.fromJson(
                Map<String, dynamic>.from(m),
              ))
          .toList();
    }

    // If subscriptions list is empty but activeSubscription is present, include it in history
    if (subs.isEmpty && activeSub != null) {
      subs = [activeSub];
    }

    return SubscriptionHistoryResponseEntity(
      hasActiveSubscription: hasActive,
      activeSubscription: activeSub,
      subscriptions: subs,
    );
  }

  @override
  List<Object?> get props => [
        hasActiveSubscription,
        activeSubscription,
        subscriptions,
      ];
}
