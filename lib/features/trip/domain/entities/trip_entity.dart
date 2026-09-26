import 'package:equatable/equatable.dart';

class TripEntity extends Equatable {
  final String id;
  final String date;
  final double fare;
  final String customerName;
  final String pickupLocation;
  final String destination;
  final String status;

  const TripEntity({
    required this.id,
    required this.date,
    required this.fare,
    required this.customerName,
    required this.pickupLocation,
    required this.destination,
    required this.status,
  });

  @override
  List<Object?> get props => [
        id,
        date,
        fare,
        customerName,
        pickupLocation,
        destination,
        status,
      ];
}
