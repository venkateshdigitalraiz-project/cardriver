class RideHistoryEntity {
  final String id;
  final String pickupLocation;
  final String dropLocation;
  final double fare;
  final DateTime date;
  final String status;

  const RideHistoryEntity({
    required this.id,
    required this.pickupLocation,
    required this.dropLocation,
    required this.fare,
    required this.date,
    required this.status,
  });
}
