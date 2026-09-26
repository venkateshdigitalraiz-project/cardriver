import 'package:equatable/equatable.dart';

enum DriverServiceType { taxi, luxury, courier, electric }

class DriverEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String avatarUrl;
  final String vehicleModel;
  final String vehiclePlate;
  final DriverServiceType serviceType;
  final double rating;
  final int totalTrips;
  final double todayEarnings;
  final bool isOnline;
  final String token;

  const DriverEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.vehicleModel,
    required this.vehiclePlate,
    required this.serviceType,
    required this.rating,
    required this.totalTrips,
    required this.todayEarnings,
    this.isOnline = false,
    required this.token,
  });

  DriverEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    String? vehicleModel,
    String? vehiclePlate,
    DriverServiceType? serviceType,
    double? rating,
    int? totalTrips,
    double? todayEarnings,
    bool? isOnline,
    String? token,
  }) {
    return DriverEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      serviceType: serviceType ?? this.serviceType,
      rating: rating ?? this.rating,
      totalTrips: totalTrips ?? this.totalTrips,
      todayEarnings: todayEarnings ?? this.todayEarnings,
      isOnline: isOnline ?? this.isOnline,
      token: token ?? this.token,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        avatarUrl,
        vehicleModel,
        vehiclePlate,
        serviceType,
        rating,
        totalTrips,
        todayEarnings,
        isOnline,
        token,
      ];
}
