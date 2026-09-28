import 'package:flutter_bloc/flutter_bloc.dart';
import 'support_event.dart';
import 'support_state.dart';

class SupportBloc extends Bloc<SupportEvent, SupportState> {
  SupportBloc() : super(SupportInitial()) {
    on<LoadSupportDataEvent>((event, emit) async {
      emit(SupportLoading());
      await Future.delayed(const Duration(milliseconds: 500));
      emit(SupportLoaded(
        categories: [
          SupportCategory(
            title: 'Trip issues',
            subtitle: 'Fare, route, cancellation',
          ),
          SupportCategory(
            title: 'Payments',
            subtitle: 'Payouts, wallet, bank',
          ),
          SupportCategory(
            title: 'Documents',
            subtitle: 'Upload, expiry, rejected',
          ),
          SupportCategory(
            title: 'Rewards',
            subtitle: 'Bonus, tiers, redeem',
          ),
        ],
        recentTickets: [
          SupportTicket(
            title: 'Payout not received',
            description: 'Ticket 20418 · 26 Sep',
            status: 'In progress',
          ),
          SupportTicket(
            title: 'Wrong fare on trip',
            description: 'Ticket 19876 · 18 Sep',
            status: 'Resolved',
          ),
        ],
      ));
    });
  }
}
