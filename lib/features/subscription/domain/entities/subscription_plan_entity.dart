import 'package:equatable/equatable.dart';

/// Represents a driver subscription plan returned by the backend.
class SubscriptionPlanEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final double price;
  final int durationDays;
  final String billingCycle;
  final bool localEligible;
  final bool outstationEligible;
  final int maxRequestsPerDay;
  final List<String> features;
  final String status;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  const SubscriptionPlanEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationDays,
    required this.billingCycle,
    required this.localEligible,
    required this.outstationEligible,
    required this.maxRequestsPerDay,
    required this.features,
    required this.status,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Formatted Price string e.g. "₹2,499"
  String get formattedPrice {
    final intPrice = price.round();
    if (intPrice >= 1000) {
      final str = intPrice.toString();
      final lastThree = str.substring(str.length - 3);
      final remaining = str.substring(0, str.length - 3);
      return '₹$remaining,$lastThree';
    }
    return '₹$intPrice';
  }

  /// Formatted Duration e.g. "30 Days"
  String get formattedDuration => '$durationDays Days';

  /// Formatted Billing Frequency e.g. "/month" or "/monthly"
  String get formattedBillingSuffix {
    final cycle = billingCycle.toLowerCase();
    if (cycle == 'monthly' || cycle == 'month') return '/mo';
    if (cycle == 'weekly' || cycle == 'week') return '/wk';
    if (cycle == 'yearly' || cycle == 'annual') return '/yr';
    return '/$durationDays days';
  }

  /// Approximate daily cost e.g. "~₹83/day"
  String get dailyCostText {
    if (durationDays <= 0) return '';
    final perDay = (price / durationDays).round();
    return '~₹$perDay/day';
  }

  /// Helper to check if this is a high-tier pass (Gold / Pro / Premium)
  bool get isHighTier {
    final lower = name.toLowerCase();
    return lower.contains('gold') ||
        lower.contains('pro') ||
        lower.contains('premium') ||
        lower.contains('unlimited');
  }

  factory SubscriptionPlanEntity.fromJson(Map<String, dynamic> json) {
    List<String> parsedFeatures = [];
    if (json['features'] is List) {
      parsedFeatures = (json['features'] as List)
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    final priceVal = json['price'];
    double parsedPrice = 0.0;
    if (priceVal is num) {
      parsedPrice = priceVal.toDouble();
    } else if (priceVal != null) {
      parsedPrice = double.tryParse(priceVal.toString()) ?? 0.0;
    }

    final durationVal = json['durationDays'];
    int parsedDuration = 30;
    if (durationVal is num) {
      parsedDuration = durationVal.toInt();
    } else if (durationVal != null) {
      parsedDuration = int.tryParse(durationVal.toString()) ?? 30;
    }

    final maxReqVal = json['maxRequestsPerDay'];
    int parsedMaxRequests = 999;
    if (maxReqVal is num) {
      parsedMaxRequests = maxReqVal.toInt();
    } else if (maxReqVal != null) {
      parsedMaxRequests = int.tryParse(maxReqVal.toString()) ?? 999;
    }

    final statusStr = (json['status'] ?? 'Active').toString();
    final isActiveVal = json['isActive'] == true ||
        statusStr.toLowerCase() == 'active';

    return SubscriptionPlanEntity(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? json['planName'] ?? 'Driver Pass').toString(),
      description: (json['description'] ?? '').toString(),
      price: parsedPrice,
      durationDays: parsedDuration,
      billingCycle: (json['billingCycle'] ?? 'monthly').toString(),
      localEligible: json['localEligible'] == true,
      outstationEligible: json['outstationEligible'] == true,
      maxRequestsPerDay: parsedMaxRequests,
      features: parsedFeatures,
      status: statusStr,
      isActive: isActiveVal,
      createdAt: (json['createdAt'] ?? '').toString(),
      updatedAt: (json['updatedAt'] ?? '').toString(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        durationDays,
        billingCycle,
        localEligible,
        outstationEligible,
        maxRequestsPerDay,
        features,
        status,
        isActive,
        createdAt,
        updatedAt,
      ];
}
