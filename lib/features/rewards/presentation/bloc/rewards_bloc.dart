import 'package:flutter_bloc/flutter_bloc.dart';
import 'rewards_event.dart';
import 'rewards_state.dart';

class RewardsBloc extends Bloc<RewardsEvent, RewardsState> {
  RewardsBloc() : super(RewardsInitial()) {
    on<LoadRewardsData>((event, emit) async {
      emit(RewardsLoading());
      // Simulate network request
      await Future.delayed(const Duration(milliseconds: 500));
      emit(RewardsLoaded(
        captainTier: 'Gold captain',
        totalRewards: 1250,
        currentTrips: 7,
        totalTrips: 10,
        tripsToNextTier: 3,
        nextTier: 'Platinum',
        tierProgress: 0.7,
        tasks: [
          RewardTask(
            title: 'Complete 10 trips',
            completed: 7,
            total: 10,
            rewardAmount: 300,
            progress: 0.7,
          ),
          RewardTask(
            title: '5 night trips',
            completed: 3,
            total: 5,
            rewardAmount: 200,
            progress: 0.6,
          ),
        ],
        availableRewards: [
          AvailableReward(amountOrTitle: '₹500', subtitle: 'Bonus'),
          AvailableReward(amountOrTitle: 'Fuel', subtitle: 'Cashback'),
        ],
      ));
    });
  }
}
