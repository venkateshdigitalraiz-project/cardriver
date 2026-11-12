import 'package:equatable/equatable.dart';

/// Entity representing Common Charges configured in the backend system.
/// Endpoint: GET /api/common/charges
class CommonChargesEntity extends Equatable {
  final String id;
  final LocalChargesEntity? local;
  final OutstationChargesEntity? outstation;
  final ValetParkingChargesEntity? valetParking;
  final String? createdAt;
  final String? updatedAt;
  final int? version;

  const CommonChargesEntity({
    required this.id,
    this.local,
    this.outstation,
    this.valetParking,
    this.createdAt,
    this.updatedAt,
    this.version,
  });

  @override
  List<Object?> get props => [
        id,
        local,
        outstation,
        valetParking,
        createdAt,
        updatedAt,
        version,
      ];
}

/// Local service charges entity
class LocalChargesEntity extends Equatable {
  final LocalTripChargesEntity? oneWay;
  final LocalTripChargesEntity? roundTrip;

  const LocalChargesEntity({
    this.oneWay,
    this.roundTrip,
  });

  @override
  List<Object?> get props => [oneWay, roundTrip];
}

/// Trip charges for Local service (one_way or round_trip)
class LocalTripChargesEntity extends Equatable {
  final HoursChargeEntity? morningHours;
  final HoursChargeEntity? nightHours;
  final List<String> returnVehicles;

  const LocalTripChargesEntity({
    this.morningHours,
    this.nightHours,
    this.returnVehicles = const [],
  });

  @override
  List<Object?> get props => [morningHours, nightHours, returnVehicles];
}

/// Time bracket charges (morningHours, nightHours)
class HoursChargeEntity extends Equatable {
  final int hours;
  final String timeRange;
  final double customerPrice;
  final double driverPrice;
  final String? chargeType;

  const HoursChargeEntity({
    required this.hours,
    required this.timeRange,
    required this.customerPrice,
    required this.driverPrice,
    this.chargeType,
  });

  @override
  List<Object?> get props => [
        hours,
        timeRange,
        customerPrice,
        driverPrice,
        chargeType,
      ];
}

/// Outstation service charges entity
class OutstationChargesEntity extends Equatable {
  final OutstationTripChargesEntity? oneWay;
  final OutstationTripChargesEntity? roundTrip;

  const OutstationChargesEntity({
    this.oneWay,
    this.roundTrip,
  });

  @override
  List<Object?> get props => [oneWay, roundTrip];
}

/// Trip charges for Outstation service (one_way or round_trip)
class OutstationTripChargesEntity extends Equatable {
  final int day;
  final double customerPrice;
  final double driverPrice;
  final String note;
  final List<String> returnVehicles;

  const OutstationTripChargesEntity({
    required this.day,
    required this.customerPrice,
    required this.driverPrice,
    this.note = '',
    this.returnVehicles = const [],
  });

  @override
  List<Object?> get props => [
        day,
        customerPrice,
        driverPrice,
        note,
        returnVehicles,
      ];
}

/// Valet parking service charges entity
class ValetParkingChargesEntity extends Equatable {
  final int person;
  final int hours;
  final double customerPrice;
  final double driverPrice;

  const ValetParkingChargesEntity({
    required this.person,
    required this.hours,
    required this.customerPrice,
    required this.driverPrice,
  });

  @override
  List<Object?> get props => [
        person,
        hours,
        customerPrice,
        driverPrice,
      ];
}

