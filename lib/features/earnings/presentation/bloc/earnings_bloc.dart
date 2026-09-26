import 'package:flutter_bloc/flutter_bloc.dart';
import 'earnings_event.dart';
import 'earnings_state.dart';

class EarningsBloc extends Bloc<EarningsEvent, EarningsState> {
  EarningsBloc() : super(EarningsInitial()) {
    on<LoadEarningsDataEvent>(_onLoadEarningsData);
  }

  void _onLoadEarningsData(
    LoadEarningsDataEvent event,
    Emitter<EarningsState> emit,
  ) async {
    emit(EarningsLoading());
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    emit(
      EarningsLoaded(
        totalEarnings: 2360.0,
        rideEarnings: 2240.0,
        tips: 120.0,
        incentives: 0.0,
        ridesCompleted: 8,
        onlineTime: '6h 32m',
        percentageIncrease: 12.0,
        weeklyData: [
          DailyEarning(day: 'Mon', amount: 1400),
          DailyEarning(day: 'Tue', amount: 1900),
          DailyEarning(day: 'Wed', amount: 1200),
          DailyEarning(day: 'Thu', amount: 2100),
          DailyEarning(day: 'Fri', amount: 1700),
          DailyEarning(day: 'Sat', amount: 2400),
          DailyEarning(day: 'Sun', amount: 2360, isCurrent: true),
        ],
        recentTransactions: [
          TransactionEntity(
            pickupLocation: 'Hitech City, Hyderabad',
            dropoffLocation: 'Madhapur, Hyderabad',
            time: '08:25 PM',
            amount: 320.0,
            status: 'Completed',
          ),
          TransactionEntity(
            pickupLocation: 'Jubilee Hills, Hyderabad',
            dropoffLocation: 'Banjara Hills, Hyderabad',
            time: '06:42 PM',
            amount: 280.0,
            status: 'Completed',
          ),
          TransactionEntity(
            pickupLocation: 'Kondapur, Hyderabad',
            dropoffLocation: 'Gachibowli, Hyderabad',
            time: '04:15 PM',
            amount: 350.0,
            status: 'Completed',
          ),
          TransactionEntity(
            pickupLocation: 'Hitech City, Hyderabad',
            dropoffLocation: 'Madhapur, Hyderabad',
            time: '02:10 PM',
            amount: 290.0,
            status: 'Completed',
          ),
        ],
      ),
    );
  }
}
