import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/get_d_to_d_bookings_usecase.dart';
import 'd_to_d_bookings_event.dart';
import 'd_to_d_bookings_state.dart';

/// Clean Architecture BLoC managing Driver-to-Driver (D-to-D) Bookings history and pagination.
/// Handles:
/// - Initial loading & pull-to-refresh: GET /api/driver/d-to-d-bookings?page=1&limit=10
/// - Infinite scroll pagination: GET /api/driver/d-to-d-bookings?page={nextPage}&limit=10
class DtoDBookingsBloc extends Bloc<DtoDBookingsEvent, DtoDBookingsState> {
  final GetDtoDBookingsUseCase getDtoDBookingsUseCase;
  final String? driverToken;

  DtoDBookingsBloc({
    required this.getDtoDBookingsUseCase,
    this.driverToken,
  }) : super(const DtoDBookingsInitial()) {
    on<LoadDtoDBookingsEvent>(_onLoadBookings);
    on<LoadMoreDtoDBookingsEvent>(_onLoadMoreBookings);
  }

  Future<void> _onLoadBookings(
    LoadDtoDBookingsEvent event,
    Emitter<DtoDBookingsState> emit,
  ) async {
    final page = event.page;
    final limit = event.limit;
    final token = event.token ?? driverToken;

    developer.log('================================================================');
    developer.log('🚀 [DtoDBookingsBloc] Handling LoadDtoDBookingsEvent (page: $page, limit: $limit, isRefresh: ${event.isRefresh})');
    developer.log('🔍 Filter: status=${event.status}, serviceType=${event.serviceType}, tripType=${event.tripType}, durationDays=${event.durationDays}, durationHours=${event.durationHours}');
    developer.log('🔑 Token: ${token != null && token.length > 20 ? "${token.substring(0, 15)}..." : token}');
    developer.log('================================================================');

    // Only show full loading indicator if it's not a background pull-to-refresh
    if (!event.isRefresh || state is! DtoDBookingsLoaded) {
      emit(const DtoDBookingsLoading());
    }

    try {
      final paginated = await getDtoDBookingsUseCase(
        page: page,
        limit: limit,
        token: token,
        status: event.status,
        serviceType: event.serviceType,
        tripType: event.tripType,
        durationDays: event.durationDays,
        durationHours: event.durationHours,
      );

      developer.log('✅ [DtoDBookingsBloc] Bookings loaded successfully: count = ${paginated.bookings.length}, total = ${paginated.total}, hasMore = ${paginated.hasMore}');

      emit(DtoDBookingsLoaded(
        bookings: paginated.bookings,
        page: paginated.page,
        limit: paginated.limit,
        total: paginated.total,
        totalPages: paginated.totalPages,
        hasMore: paginated.hasMore,
        isLoadingMore: false,
        status: event.status,
        serviceType: event.serviceType,
        tripType: event.tripType,
        durationDays: event.durationDays,
        durationHours: event.durationHours,
      ));
    } catch (e, stack) {
      developer.log('❌ [DtoDBookingsBloc] Error loading bookings: $e\n$stack');
      emit(DtoDBookingsError(
        message: e.toString().replaceFirst(RegExp(r'^(Exception|ServerException|AuthException):\s*'), ''),
      ));
    }
  }

  Future<void> _onLoadMoreBookings(
    LoadMoreDtoDBookingsEvent event,
    Emitter<DtoDBookingsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DtoDBookingsLoaded) return;
    if (currentState.isLoadingMore || !currentState.hasMore) {
      developer.log('ℹ️ [DtoDBookingsBloc] LoadMore skipped (isLoadingMore: ${currentState.isLoadingMore}, hasMore: ${currentState.hasMore})');
      return;
    }

    final nextPage = currentState.page + 1;
    final token = event.token ?? driverToken;

    developer.log('🔄 [DtoDBookingsBloc] Loading more bookings (nextPage: $nextPage, limit: ${currentState.limit})');
    emit(currentState.copyWith(isLoadingMore: true, loadMoreError: null));

    try {
      final paginated = await getDtoDBookingsUseCase(
        page: nextPage,
        limit: currentState.limit,
        token: token,
        status: currentState.status,
        serviceType: currentState.serviceType,
        tripType: currentState.tripType,
        durationDays: currentState.durationDays,
        durationHours: currentState.durationHours,
      );

      developer.log('✅ [DtoDBookingsBloc] More bookings loaded: +${paginated.bookings.length} items (Total in memory: ${currentState.bookings.length + paginated.bookings.length})');

      final updatedList = List.of(currentState.bookings)..addAll(paginated.bookings);

      emit(currentState.copyWith(
        bookings: updatedList,
        page: paginated.page,
        limit: paginated.limit,
        total: paginated.total,
        totalPages: paginated.totalPages,
        hasMore: paginated.hasMore,
        isLoadingMore: false,
      ));
    } catch (e, stack) {
      developer.log('❌ [DtoDBookingsBloc] Error loading more bookings: $e\n$stack');
      emit(currentState.copyWith(
        isLoadingMore: false,
        loadMoreError: e.toString().replaceFirst(RegExp(r'^(Exception|ServerException|AuthException):\s*'), ''),
      ));
    }
  }
}

