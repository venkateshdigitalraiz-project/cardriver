abstract class EarningsState {}

class EarningsInitial extends EarningsState {}

class EarningsLoading extends EarningsState {}

class EarningsLoaded extends EarningsState {
  final double totalEarnings;
  final double rideEarnings;
  final double tips;
  final double incentives;
  final int ridesCompleted;
  final String onlineTime;
  final double percentageIncrease;
  final List<TransactionEntity> recentTransactions;
  final List<DailyEarning> weeklyData;

  EarningsLoaded({
    required this.totalEarnings,
    required this.rideEarnings,
    required this.tips,
    required this.incentives,
    required this.ridesCompleted,
    required this.onlineTime,
    required this.percentageIncrease,
    required this.recentTransactions,
    required this.weeklyData,
  });
}

class EarningsError extends EarningsState {
  final String message;
  EarningsError(this.message);
}

class TransactionEntity {
  final String pickupLocation;
  final String dropoffLocation;
  final String time;
  final double amount;
  final String status;

  TransactionEntity({
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.time,
    required this.amount,
    required this.status,
  });
}

class DailyEarning {
  final String day;
  final double amount;
  final bool isCurrent;

  DailyEarning({
    required this.day,
    required this.amount,
    this.isCurrent = false,
  });
}
