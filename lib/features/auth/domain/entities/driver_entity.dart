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
  final String? aadharNumber;
  final String? panNumber;
  final String? passportNumber;
  final String? aadharFrontPath;
  final String? aadharBackPath;
  final String? panCardPath;
  final String? drivingLicensePath;
  final String? passportPath;
  final String? profilePicPath;

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
    this.aadharNumber,
    this.panNumber,
    this.passportNumber,
    this.aadharFrontPath,
    this.aadharBackPath,
    this.panCardPath,
    this.drivingLicensePath,
    this.passportPath,
    this.profilePicPath,
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
    String? aadharNumber,
    String? panNumber,
    String? passportNumber,
    String? aadharFrontPath,
    String? aadharBackPath,
    String? panCardPath,
    String? drivingLicensePath,
    String? passportPath,
    String? profilePicPath,
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
      aadharNumber: aadharNumber ?? this.aadharNumber,
      panNumber: panNumber ?? this.panNumber,
      passportNumber: passportNumber ?? this.passportNumber,
      aadharFrontPath: aadharFrontPath ?? this.aadharFrontPath,
      aadharBackPath: aadharBackPath ?? this.aadharBackPath,
      panCardPath: panCardPath ?? this.panCardPath,
      drivingLicensePath: drivingLicensePath ?? this.drivingLicensePath,
      passportPath: passportPath ?? this.passportPath,
      profilePicPath: profilePicPath ?? this.profilePicPath,
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
        aadharNumber,
        panNumber,
        passportNumber,
        aadharFrontPath,
        aadharBackPath,
        panCardPath,
        drivingLicensePath,
        passportPath,
        profilePicPath,
      ];
}
