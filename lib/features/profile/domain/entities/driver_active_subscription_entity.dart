import 'package:equatable/equatable.dart';

/// Entity representing an active driver subscription details.
class DriverActiveSubscriptionEntity extends Equatable {
  final String id;
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
  final int daysLeft;
  final int bookingsReceived;
  final int completedBookings;
  final String createdAt;

  const DriverActiveSubscriptionEntity({
    required this.id,
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
    required this.daysLeft,
    required this.bookingsReceived,
    required this.completedBookings,
    required this.createdAt,
  });

  bool get isActive =>
      subscriptionStatus.toLowerCase() == 'active' && daysLeft > 0;

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

  String get formattedDateRange {
    final start = _formatShortDate(startDate);
    final end = _formatShortDate(expiryDate);
    if (start.isNotEmpty && end.isNotEmpty) {
      return '$start - $end';
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

  factory DriverActiveSubscriptionEntity.fromJson(Map<String, dynamic> json) {
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

    return DriverActiveSubscriptionEntity(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
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
          (json['subscriptionStatus'] ?? json['status'] ?? 'Active').toString(),
      daysLeft: parsedDaysLeft,
      bookingsReceived: parsedBookingsRec,
      completedBookings: parsedCompleted,
      createdAt: (json['createdAt'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      '_id': id,
      'planId': planId,
      'planName': planName,
      'amount': amount,
      'durationDays': durationDays,
      'billingCycle': billingCycle,
      'features': features,
      'localEligible': localEligible,
      'outstationEligible': outstationEligible,
      'maxRequestsPerDay': maxRequestsPerDay,
      'startDate': startDate,
      'expiryDate': expiryDate,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'subscriptionStatus': subscriptionStatus,
      'daysLeft': daysLeft,
      'bookingsReceived': bookingsReceived,
      'completedBookings': completedBookings,
      'createdAt': createdAt,
    };
  }

  @override
  List<Object?> get props => [
        id,
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
        daysLeft,
        bookingsReceived,
        completedBookings,
        createdAt,
      ];
}
