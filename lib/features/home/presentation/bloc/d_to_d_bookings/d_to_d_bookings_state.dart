import 'package:equatable/equatable.dart';

import '../../../domain/entities/d_to_d_booking_entity.dart';

/// Clean Architecture states for Driver-to-Driver Bookings screen.
abstract class DtoDBookingsState extends Equatable {
  const DtoDBookingsState();

  @override
  List<Object?> get props => [];
}

/// Initial uninitialized state.
class DtoDBookingsInitial extends DtoDBookingsState {
  const DtoDBookingsInitial();
}

/// Initial or full refresh loading state.
class DtoDBookingsLoading extends DtoDBookingsState {
  final String? message;

  const DtoDBookingsLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// Successfully loaded list of D-to-D bookings with pagination info.
class DtoDBookingsLoaded extends DtoDBookingsState {
  final List<DtoDBookingEntity> bookings;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasMore;
  final bool isLoadingMore;
  final String? loadMoreError;
  final String? status;
  final String? serviceType;
  final String? tripType;
  final int? durationDays;
  final int? durationHours;

  const DtoDBookingsLoaded({
    required this.bookings,
    this.page = 1,
    this.limit = 10,
    this.total = 0,
    this.totalPages = 1,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.loadMoreError,
    this.status,
    this.serviceType,
    this.tripType,
    this.durationDays,
    this.durationHours,
  });

  DtoDBookingsLoaded copyWith({
    List<DtoDBookingEntity>? bookings,
    int? page,
    int? limit,
    int? total,
    int? totalPages,
    bool? hasMore,
    bool? isLoadingMore,
    String? loadMoreError,
    String? status,
    String? serviceType,
    String? tripType,
    int? durationDays,
    int? durationHours,
  }) {
    return DtoDBookingsLoaded(
      bookings: bookings ?? this.bookings,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      total: total ?? this.total,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreError: loadMoreError,
      status: status ?? this.status,
      serviceType: serviceType ?? this.serviceType,
      tripType: tripType ?? this.tripType,
      durationDays: durationDays ?? this.durationDays,
      durationHours: durationHours ?? this.durationHours,
    );
  }

  @override
  List<Object?> get props => [
        bookings,
        page,
        limit,
        total,
        totalPages,
        hasMore,
        isLoadingMore,
        loadMoreError,
        status,
        serviceType,
        tripType,
        durationDays,
        durationHours,
      ];
}

/// Failure state when fetching bookings failed.
class DtoDBookingsError extends DtoDBookingsState {
  final String message;
  final int? statusCode;

  const DtoDBookingsError({
    required this.message,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, statusCode];
}

