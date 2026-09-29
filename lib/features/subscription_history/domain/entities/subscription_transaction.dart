class SubscriptionTransaction {
  final String id;
  final String planName;
  final String duration; // e.g. "Monthly Subscription"
  final String dateRange; // e.g. "01 Sep 2025 - 30 Sep 2025"
  final String paymentMethod; // e.g. "Paid via UPI • ****1234"
  final double amount;
  final String status; // "Active", "Expired", "Cancelled"

  SubscriptionTransaction({
    required this.id,
    required this.planName,
    required this.duration,
    required this.dateRange,
    required this.paymentMethod,
    required this.amount,
    required this.status,
  });
}
