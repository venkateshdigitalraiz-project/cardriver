import 'package:equatable/equatable.dart';

/// Represents a driver's subscription record (either active or historical).
class DriverSubscriptionEntity extends Equatable {
  final String id;
  final String driverId;
  final String driverMongoId;
  final String driverName;
  final String driverPhone;
  final String driverAvatar;
  final String planId;
  final String planName;
  final double amount;
  final int durationDays;
  final String billingCycle;
  final List<String> features;
  final bool localEligible;
  final bool outstationEligible;
  final int maxRequestsPerDay;
  final String startDate;
  final String expiryDate;
  final String paymentStatus;
  final String paymentMethod;
  final String transactionId;
  final String subscriptionStatus;
  final int bookingsReceived;
  final int completedBookings;
  final int daysLeft;
  final String createdAt;
  final String updatedAt;

  const DriverSubscriptionEntity({
    required this.id,
    required this.driverId,
    required this.driverMongoId,
    required this.driverName,
    required this.driverPhone,
    required this.driverAvatar,
    required this.planId,
    required this.planName,
    required this.amount,
    required this.durationDays,
    required this.billingCycle,
    required this.features,
    required this.localEligible,
    required this.outstationEligible,
    required this.maxRequestsPerDay,
    required this.startDate,
    required this.expiryDate,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.transactionId,
    required this.subscriptionStatus,
    required this.bookingsReceived,
    required this.completedBookings,
    required this.daysLeft,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Formatted Amount string e.g. "₹2,499"
  String get formattedAmount {
    final intPrice = amount.round();
    if (intPrice >= 1000) {
      final str = intPrice.toString();
      final lastThree = str.substring(str.length - 3);
      final remaining = str.substring(0, str.length - 3);
      return '₹$remaining,$lastThree';
    }
    return '₹$intPrice';
  }

  /// Status check getters
  bool get isActive =>
      subscriptionStatus.toLowerCase() == 'active' ||
      subscriptionStatus.toLowerCase() == 'successful';

  bool get isExpired => subscriptionStatus.toLowerCase() == 'expired';

  bool get isCancelled => subscriptionStatus.toLowerCase() == 'cancelled';

  /// Formatted date range: e.g. "16 Oct 2026 - 15 Nov 2026"
  String get formattedDateRange {
    final start = _formatShortDate(startDate);
    final end = _formatShortDate(expiryDate);
    if (start.isNotEmpty && end.isNotEmpty) {
      return '$start - $end';
    } else if (start.isNotEmpty) {
      return 'Started: $start';
    } else if (end.isNotEmpty) {
      return 'Expires: $end';
    }
    return '';
  }

  static String _formatShortDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final dt = DateTime.parse(dateStr);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final day = dt.day.toString().padLeft(2, '0');
      final month = months[dt.month - 1];
      return '$day $month ${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  factory DriverSubscriptionEntity.fromJson(Map<String, dynamic> json) {
    List<String> parsedFeatures = [];
    if (json['features'] is List) {
      parsedFeatures = (json['features'] as List)
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    final amountVal = json['amount'] ?? json['price'];
    double parsedAmount = 0.0;
    if (amountVal is num) {
      parsedAmount = amountVal.toDouble();
    } else if (amountVal != null) {
      parsedAmount = double.tryParse(amountVal.toString()) ?? 0.0;
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

    final bookingsRecVal = json['bookingsReceived'];
    int parsedBookingsRec = 0;
    if (bookingsRecVal is num) {
      parsedBookingsRec = bookingsRecVal.toInt();
    } else if (bookingsRecVal != null) {
      parsedBookingsRec = int.tryParse(bookingsRecVal.toString()) ?? 0;
    }

    final completedVal = json['completedBookings'];
    int parsedCompleted = 0;
    if (completedVal is num) {
      parsedCompleted = completedVal.toInt();
    } else if (completedVal != null) {
      parsedCompleted = int.tryParse(completedVal.toString()) ?? 0;
    }

    final daysLeftVal = json['daysLeft'];
    int parsedDaysLeft = 0;
    if (daysLeftVal is num) {
      parsedDaysLeft = daysLeftVal.toInt();
    } else if (daysLeftVal != null) {
      parsedDaysLeft = int.tryParse(daysLeftVal.toString()) ?? 0;
    }

    return DriverSubscriptionEntity(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      driverId: (json['driverId'] ?? '').toString(),
      driverMongoId: (json['driverMongoId'] ?? '').toString(),
      driverName: (json['driverName'] ?? '').toString(),
      driverPhone: (json['driverPhone'] ?? '').toString(),
      driverAvatar: (json['driverAvatar'] ?? '').toString(),
      planId: (json['planId'] ?? '').toString(),
      planName: (json['planName'] ?? 'Driver Pass').toString(),
      amount: parsedAmount,
      durationDays: parsedDuration,
      billingCycle: (json['billingCycle'] ?? 'monthly').toString(),
      features: parsedFeatures,
      localEligible: json['localEligible'] == true,
      outstationEligible: json['outstationEligible'] == true,
      maxRequestsPerDay: parsedMaxRequests,
      startDate: (json['startDate'] ?? '').toString(),
      expiryDate: (json['expiryDate'] ?? '').toString(),
      paymentStatus: (json['paymentStatus'] ?? 'Successful').toString(),
      paymentMethod: (json['paymentMethod'] ?? 'UPI').toString(),
      transactionId: (json['transactionId'] ?? '').toString(),
      subscriptionStatus:
          (json['subscriptionStatus'] ?? json['status'] ?? 'Active')
              .toString(),
      bookingsReceived: parsedBookingsRec,
      completedBookings: parsedCompleted,
      daysLeft: parsedDaysLeft,
      createdAt: (json['createdAt'] ?? '').toString(),
      updatedAt: (json['updatedAt'] ?? '').toString(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        driverId,
        driverMongoId,
        driverName,
        driverPhone,
        driverAvatar,
        planId,
        planName,
        amount,
        durationDays,
        billingCycle,
        features,
        localEligible,
        outstationEligible,
        maxRequestsPerDay,
        startDate,
        expiryDate,
        paymentStatus,
        paymentMethod,
        transactionId,
        subscriptionStatus,
        bookingsReceived,
        completedBookings,
        daysLeft,
        createdAt,
        updatedAt,
      ];
}
