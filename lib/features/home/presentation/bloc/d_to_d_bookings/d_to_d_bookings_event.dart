import 'package:equatable/equatable.dart';

abstract class DtoDBookingsEvent extends Equatable {
  const DtoDBookingsEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched to load the initial list or refresh bookings with optional filters.
/// Calls GET /api/driver/d-to-d-bookings?page=1&limit=10&status=...&serviceType=...
class LoadDtoDBookingsEvent extends DtoDBookingsEvent {
  final int page;
  final int limit;
  final bool isRefresh;
  final String? token;
  final String? status;
  final String? serviceType;
  final String? tripType;
  final int? durationDays;
  final int? durationHours;

  const LoadDtoDBookingsEvent({
    this.page = 1,
    this.limit = 10,
    this.isRefresh = false,
    this.token,
    this.status,
    this.serviceType,
    this.tripType,
    this.durationDays,
    this.durationHours,
  });

  @override
  List<Object?> get props => [
        page,
        limit,
        isRefresh,
        token,
        status,
        serviceType,
        tripType,
        durationDays,
        durationHours,
      ];
}

/// Dispatched when scrolling to load next paginated page.
class LoadMoreDtoDBookingsEvent extends DtoDBookingsEvent {
  final String? token;

  const LoadMoreDtoDBookingsEvent({this.token});

  @override
  List<Object?> get props => [token];
}

