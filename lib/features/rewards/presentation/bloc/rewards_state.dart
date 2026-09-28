abstract class RewardsState {}

class RewardsInitial extends RewardsState {}

class RewardsLoading extends RewardsState {}

class RewardTask {
  final String title;
  final int completed;
  final int total;
  final int rewardAmount;
  final double progress;

  RewardTask({
    required this.title,
    required this.completed,
    required this.total,
    required this.rewardAmount,
    required this.progress,
  });
}

class AvailableReward {
  final String amountOrTitle;
  final String subtitle;

  AvailableReward({
    required this.amountOrTitle,
    required this.subtitle,
  });
}

class RewardsLoaded extends RewardsState {
  final String captainTier;
  final int totalRewards;
  final int currentTrips;
  final int totalTrips;
  final int tripsToNextTier;
  final String nextTier;
  final double tierProgress;
  final List<RewardTask> tasks;
  final List<AvailableReward> availableRewards;

  RewardsLoaded({
    required this.captainTier,
    required this.totalRewards,
    required this.currentTrips,
    required this.totalTrips,
    required this.tripsToNextTier,
    required this.nextTier,
    required this.tierProgress,
    required this.tasks,
    required this.availableRewards,
  });
}

class RewardsError extends RewardsState {
  final String message;
  RewardsError(this.message);
}
