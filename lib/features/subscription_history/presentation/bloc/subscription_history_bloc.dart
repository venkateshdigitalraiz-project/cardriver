import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/subscription_history_remote_data_source.dart';
import '../../domain/entities/driver_subscription_entity.dart';
import '../../domain/usecases/get_subscription_history_usecase.dart';
import 'subscription_history_event.dart';
import 'subscription_history_state.dart';

class SubscriptionHistoryBloc
    extends Bloc<SubscriptionHistoryEvent, SubscriptionHistoryState> {
  final GetSubscriptionHistoryUseCase getSubscriptionHistoryUseCase;
  final String? driverToken;

  SubscriptionHistoryBloc({
    required this.getSubscriptionHistoryUseCase,
    this.driverToken,
  }) : super(const SubscriptionHistoryLoading()) {
    on<LoadSubscriptionHistory>(_onLoadSubscriptionHistory);
    on<FilterSubscriptionHistory>(_onFilterSubscriptionHistory);
    on<RefreshSubscriptionHistory>(_onRefreshSubscriptionHistory);
  }

  Future<void> _onLoadSubscriptionHistory(
    LoadSubscriptionHistory event,
    Emitter<SubscriptionHistoryState> emit,
  ) async {
    if (!event.silent) {
      emit(const SubscriptionHistoryLoading());
    }

    try {
      final token = event.token ??
          driverToken ??
          SubscriptionHistoryRemoteDataSourceImpl.defaultDriverToken;

      final response = await getSubscriptionHistoryUseCase(
        GetSubscriptionHistoryParams(token: token),
      );

      final currentFilter = state is SubscriptionHistoryLoaded
          ? (state as SubscriptionHistoryLoaded).currentFilter
          : 'All';

      final filtered = _applyFilter(response.subscriptions, currentFilter);

      emit(
        SubscriptionHistoryLoaded(
          hasActiveSubscription: response.hasActiveSubscription,
          activeSubscription: response.activeSubscription,
          allSubscriptions: response.subscriptions,
          filteredSubscriptions: filtered,
          currentFilter: currentFilter,
          isRefreshing: false,
        ),
      );
    } catch (e) {
      log('❌ [SubscriptionHistoryBloc] Error: $e');
      emit(SubscriptionHistoryError(
        e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  void _onFilterSubscriptionHistory(
    FilterSubscriptionHistory event,
    Emitter<SubscriptionHistoryState> emit,
  ) {
    if (state is SubscriptionHistoryLoaded) {
      final current = state as SubscriptionHistoryLoaded;
      final filtered = _applyFilter(current.allSubscriptions, event.status);

      emit(
        current.copyWith(
          filteredSubscriptions: filtered,
          currentFilter: event.status,
        ),
      );
    }
  }

  Future<void> _onRefreshSubscriptionHistory(
    RefreshSubscriptionHistory event,
    Emitter<SubscriptionHistoryState> emit,
  ) async {
    if (state is SubscriptionHistoryLoaded) {
      emit((state as SubscriptionHistoryLoaded).copyWith(isRefreshing: true));
    }
    add(LoadSubscriptionHistory(token: event.token, silent: true));
  }

  List<DriverSubscriptionEntity> _applyFilter(
    List<DriverSubscriptionEntity> list,
    String status,
  ) {
    if (status == 'All') return list;
    return list.where((item) {
      final itemStatus = item.subscriptionStatus.toLowerCase();
      final target = status.toLowerCase();
      if (target == 'active') {
        return itemStatus == 'active' || itemStatus == 'successful';
      }
      return itemStatus == target;
    }).toList();
  }
}
