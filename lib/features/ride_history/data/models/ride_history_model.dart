import '../../domain/entities/ride_history_entity.dart';

class RideHistoryModel extends RideHistoryEntity {
  const RideHistoryModel({
    required super.id,
    required super.pickupLocation,
    required super.dropLocation,
    required super.fare,
    required super.date,
    required super.status,
  });

  factory RideHistoryModel.fromJson(Map<String, dynamic> json) {
    return RideHistoryModel(
      id: json['id'],
      pickupLocation: json['pickupLocation'],
      dropLocation: json['dropLocation'],
      fare: json['fare'].toDouble(),
      date: DateTime.parse(json['date']),
      status: json['status'],
    );
  }
}
