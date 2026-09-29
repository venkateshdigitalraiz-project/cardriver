import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/subscription_transaction.dart';
import 'subscription_history_event.dart';
import 'subscription_history_state.dart';

class SubscriptionHistoryBloc extends Bloc<SubscriptionHistoryEvent, SubscriptionHistoryState> {
  SubscriptionHistoryBloc() : super(SubscriptionHistoryLoading()) {
    on<LoadSubscriptionHistory>((event, emit) async {
      emit(SubscriptionHistoryLoading());
      
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      final dummyTransactions = [
        SubscriptionTransaction(
          id: '1',
          planName: 'Premium Plan',
          duration: 'Monthly Subscription',
          dateRange: '01 Sep 2025 - 30 Sep 2025',
          paymentMethod: 'Paid via UPI • ****1234',
          amount: 499.0,
          status: 'Active',
        ),
        SubscriptionTransaction(
          id: '2',
          planName: 'Standard Plan',
          duration: 'Monthly Subscription',
          dateRange: '01 Aug 2025 - 31 Aug 2025',
          paymentMethod: 'Paid via UPI • ****1234',
          amount: 299.0,
          status: 'Expired',
        ),
        SubscriptionTransaction(
          id: '3',
          planName: 'Basic Plan',
          duration: 'Monthly Subscription',
          dateRange: '01 Jul 2025 - 31 Jul 2025',
          paymentMethod: 'Paid via Card • ****5678',
          amount: 149.0,
          status: 'Expired',
        ),
        SubscriptionTransaction(
          id: '4',
          planName: 'Premium Plan',
          duration: 'Monthly Subscription',
          dateRange: '01 Jun 2025 - 30 Jun 2025',
          paymentMethod: 'Paid via UPI • ****1234',
          amount: 499.0,
          status: 'Cancelled',
        ),
      ];

      emit(SubscriptionHistoryLoaded(
        allTransactions: dummyTransactions,
        filteredTransactions: dummyTransactions,
        currentFilter: 'All',
      ));
    });

    on<FilterSubscriptionHistory>((event, emit) {
      if (state is SubscriptionHistoryLoaded) {
        final currentState = state as SubscriptionHistoryLoaded;
        List<SubscriptionTransaction> filtered;
        
        if (event.status == 'All') {
          filtered = currentState.allTransactions;
        } else {
          filtered = currentState.allTransactions
              .where((t) => t.status == event.status)
              .toList();
        }

        emit(SubscriptionHistoryLoaded(
          allTransactions: currentState.allTransactions,
          filteredTransactions: filtered,
          currentFilter: event.status,
        ));
      }
    });
  }
}
