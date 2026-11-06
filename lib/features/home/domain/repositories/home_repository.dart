import '../../data/models/d_to_d_booking_model.dart';
import '../entities/accepted_ride_entity.dart';
import '../entities/available_ride_entity.dart';
import '../entities/common_charges_entity.dart';
import '../entities/d_to_d_booking_entity.dart';
import '../entities/rejected_ride_entity.dart';

abstract class HomeRepository {
  Future<List<AvailableRideEntity>> getAvailableRides({String? token});
  Stream<List<AvailableRideEntity>> monitorAvailableRides({
    String? token,
    Duration interval = const Duration(seconds: 4),
  });
  Future<AcceptedRideEntity> acceptRide({
    required String rideId,
    required String token,
  });
  Future<RejectedRideEntity> rejectRide({
    required String rideId,
    required String token,
    String? reason,
  });
  Future<DtoDBookingEntity> createDtoDBooking({
    required DtoDBookingRequestModel request,
    String? token,
  });
  Future<DtoDBookingsPaginatedEntity> getDtoDBookings({
    int page = 1,
    int limit = 10,
    String? token,
    String? status,
    String? serviceType,
    String? tripType,
    int? durationDays,
    int? durationHours,
  });
  Future<List<CommonChargesEntity>> getCommonCharges({String? token});
}
