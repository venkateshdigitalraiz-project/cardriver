import '../../domain/entities/driver_entity.dart';

class DriverModel extends DriverEntity {
  const DriverModel({
    required super.id,
    required super.name,
    required super.email,
    required super.phone,
    required super.avatarUrl,
    required super.vehicleModel,
    required super.vehiclePlate,
    required super.serviceType,
    required super.rating,
    required super.totalTrips,
    required super.todayEarnings,
    super.isOnline,
    required super.token,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      avatarUrl: json['avatarUrl'] as String? ?? 'https://i.pravatar.cc/300?u=driver',
      vehicleModel: json['vehicleModel'] as String,
      vehiclePlate: json['vehiclePlate'] as String,
      serviceType: _serviceTypeFromString(json['serviceType'] as String? ?? 'taxi'),
      rating: (json['rating'] as num?)?.toDouble() ?? 4.9,
      totalTrips: json['totalTrips'] as int? ?? 0,
      todayEarnings: (json['todayEarnings'] as num?)?.toDouble() ?? 0.0,
      isOnline: json['isOnline'] as bool? ?? false,
      token: json['token'] as String? ?? 'jwt_token_sample',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'vehicleModel': vehicleModel,
      'vehiclePlate': vehiclePlate,
      'serviceType': serviceType.name,
      'rating': rating,
      'totalTrips': totalTrips,
      'todayEarnings': todayEarnings,
      'isOnline': isOnline,
      'token': token,
    };
  }

  static DriverServiceType _serviceTypeFromString(String value) {
    switch (value.toLowerCase()) {
      case 'luxury':
        return DriverServiceType.luxury;
      case 'courier':
        return DriverServiceType.courier;
      case 'electric':
        return DriverServiceType.electric;
      case 'taxi':
      default:
        return DriverServiceType.taxi;
    }
  }

  factory DriverModel.fromEntity(DriverEntity entity) {
    return DriverModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      avatarUrl: entity.avatarUrl,
      vehicleModel: entity.vehicleModel,
      vehiclePlate: entity.vehiclePlate,
      serviceType: entity.serviceType,
      rating: entity.rating,
      totalTrips: entity.totalTrips,
      todayEarnings: entity.todayEarnings,
      isOnline: entity.isOnline,
      token: entity.token,
    );
  }
}
