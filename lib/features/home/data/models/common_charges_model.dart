import '../../domain/entities/common_charges_entity.dart';

/// Data model representing Common Charges from the backend API.
class CommonChargesModel extends CommonChargesEntity {
  const CommonChargesModel({
    required super.id,
    super.local,
    super.outstation,
    super.valetParking,
    super.createdAt,
    super.updatedAt,
    super.version,
  });

  factory CommonChargesModel.fromJson(Map<String, dynamic> json) {
    return CommonChargesModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      local: json['local'] is Map<String, dynamic>
          ? LocalChargesModel.fromJson(json['local'] as Map<String, dynamic>)
          : null,
      outstation: json['outstation'] is Map<String, dynamic>
          ? OutstationChargesModel.fromJson(
              json['outstation'] as Map<String, dynamic>,
            )
          : null,
      valetParking: (json['valletparking'] is Map<String, dynamic>)
          ? ValetParkingChargesModel.fromJson(
              json['valletparking'] as Map<String, dynamic>,
            )
          : (json['valetparking'] is Map<String, dynamic>)
              ? ValetParkingChargesModel.fromJson(
                  json['valetparking'] as Map<String, dynamic>,
                )
              : null,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      version: _parseNullableInt(json['__v']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      if (local != null && local is LocalChargesModel)
        'local': (local as LocalChargesModel).toJson(),
      if (outstation != null && outstation is OutstationChargesModel)
        'outstation': (outstation as OutstationChargesModel).toJson(),
      if (valetParking != null && valetParking is ValetParkingChargesModel)
        'valletparking': (valetParking as ValetParkingChargesModel).toJson(),
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
      if (version != null) '__v': version,
    };
  }
}

class LocalChargesModel extends LocalChargesEntity {
  const LocalChargesModel({super.oneWay, super.roundTrip});

  factory LocalChargesModel.fromJson(Map<String, dynamic> json) {
    return LocalChargesModel(
      oneWay: json['one_way'] is Map<String, dynamic>
          ? LocalTripChargesModel.fromJson(
              json['one_way'] as Map<String, dynamic>,
            )
          : null,
      roundTrip: json['round_trip'] is Map<String, dynamic>
          ? LocalTripChargesModel.fromJson(
              json['round_trip'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (oneWay != null && oneWay is LocalTripChargesModel)
        'one_way': (oneWay as LocalTripChargesModel).toJson(),
      if (roundTrip != null && roundTrip is LocalTripChargesModel)
        'round_trip': (roundTrip as LocalTripChargesModel).toJson(),
    };
  }
}

class LocalTripChargesModel extends LocalTripChargesEntity {
  const LocalTripChargesModel({
    super.morningHours,
    super.nightHours,
    super.returnVehicles,
  });

  factory LocalTripChargesModel.fromJson(Map<String, dynamic> json) {
    return LocalTripChargesModel(
      morningHours: json['morningHours'] is Map<String, dynamic>
          ? HoursChargeModel.fromJson(
              json['morningHours'] as Map<String, dynamic>,
            )
          : null,
      nightHours: json['nightHours'] is Map<String, dynamic>
          ? HoursChargeModel.fromJson(json['nightHours'] as Map<String, dynamic>)
          : null,
      returnVehicles: _parseStringList(json['returnVehicles']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (morningHours != null && morningHours is HoursChargeModel)
        'morningHours': (morningHours as HoursChargeModel).toJson(),
      if (nightHours != null && nightHours is HoursChargeModel)
        'nightHours': (nightHours as HoursChargeModel).toJson(),
      'returnVehicles': returnVehicles,
    };
  }
}

class HoursChargeModel extends HoursChargeEntity {
  const HoursChargeModel({
    required super.hours,
    required super.timeRange,
    required super.customerPrice,
    required super.driverPrice,
    super.chargeType,
  });

  factory HoursChargeModel.fromJson(Map<String, dynamic> json) {
    return HoursChargeModel(
      hours: _parseInt(json['hours']),
      timeRange: json['timeRange']?.toString() ?? '',
      customerPrice: _parseDouble(json['customerPrice'] ?? json['customerprice']),
      driverPrice: _parseDouble(json['driverPrice'] ?? json['driverprice']),
      chargeType: json['chargeType']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hours': hours,
      'timeRange': timeRange,
      'customerPrice': customerPrice,
      'driverPrice': driverPrice,
      if (chargeType != null) 'chargeType': chargeType,
    };
  }
}

class OutstationChargesModel extends OutstationChargesEntity {
  const OutstationChargesModel({super.oneWay, super.roundTrip});

  factory OutstationChargesModel.fromJson(Map<String, dynamic> json) {
    return OutstationChargesModel(
      oneWay: json['one_way'] is Map<String, dynamic>
          ? OutstationTripChargesModel.fromJson(
              json['one_way'] as Map<String, dynamic>,
            )
          : null,
      roundTrip: json['round_trip'] is Map<String, dynamic>
          ? OutstationTripChargesModel.fromJson(
              json['round_trip'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (oneWay != null && oneWay is OutstationTripChargesModel)
        'one_way': (oneWay as OutstationTripChargesModel).toJson(),
      if (roundTrip != null && roundTrip is OutstationTripChargesModel)
        'round_trip': (roundTrip as OutstationTripChargesModel).toJson(),
    };
  }
}

class OutstationTripChargesModel extends OutstationTripChargesEntity {
  const OutstationTripChargesModel({
    required super.day,
    required super.customerPrice,
    required super.driverPrice,
    super.returnVehicles,
  });

  factory OutstationTripChargesModel.fromJson(Map<String, dynamic> json) {
    return OutstationTripChargesModel(
      day: _parseInt(json['day']),
      customerPrice: _parseDouble(json['customerPrice'] ?? json['customerprice']),
      driverPrice: _parseDouble(json['driverPrice'] ?? json['driverprice']),
      returnVehicles: _parseStringList(json['returnVehicles']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'customerPrice': customerPrice,
      'driverPrice': driverPrice,
      'returnVehicles': returnVehicles,
    };
  }
}

class ValetParkingChargesModel extends ValetParkingChargesEntity {
  const ValetParkingChargesModel({
    required super.person,
    required super.hours,
    required super.customerPrice,
    required super.driverPrice,
  });

  factory ValetParkingChargesModel.fromJson(Map<String, dynamic> json) {
    return ValetParkingChargesModel(
      person: _parseInt(json['person']),
      hours: _parseInt(json['hours']),
      customerPrice: _parseDouble(json['customerprice'] ?? json['customerPrice']),
      driverPrice: _parseDouble(json['driverprice'] ?? json['driverPrice']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'person': person,
      'hours': hours,
      'customerprice': customerPrice,
      'driverprice': driverPrice,
    };
  }
}

// -------------------------------------------------------------
// Parsing Helpers for resilient type safety
// -------------------------------------------------------------

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

int? _parseNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double _parseDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

List<String> _parseStringList(dynamic value) {
  if (value is List) {
    return value.map((item) => item?.toString() ?? '').where((s) => s.isNotEmpty).toList();
  }
  return const [];
}

