import '../entities/available_ride_entity.dart';

/// Clean Architecture Use Case to generate a new manual ride entry for the driver.
class CreateManualRideUseCase {
  const CreateManualRideUseCase();

  AvailableRideEntity call({
    required String userName,
    required String mobileNumber,
    required String fromAddress,
    required String toAddress,
    required double price,
    required DateTime dateTime,
    double? pickupLat,
    double? pickupLng,
    double? dropLat,
    double? dropLng,
  }) {
    final now = DateTime.now();
    final cleanPhone = mobileNumber.trim();
    final formattedPhone = cleanPhone.startsWith('+91')
        ? cleanPhone
        : '+91 $cleanPhone';

    return AvailableRideEntity(
      id: 'manual_${now.millisecondsSinceEpoch}',
      bookingId: 'CD-${now.millisecondsSinceEpoch.toString().substring(7)}',
      riderName: userName.trim(),
      riderPhone: formattedPhone,
      vehicleType: 'Sedan',
      serviceType: 'Manual Ride',
      tripType: 'Point-to-Point',
      durationHours: 2,
      fare: price,
      driverFee: (price * 0.85).roundToDouble(),
      paymentMethod: 'Cash',
      pickupAddress: fromAddress.trim(),
      dropAddress: toAddress.trim(),
      pickupLat: pickupLat ?? 17.4435,
      pickupLng: pickupLng ?? 78.3772,
      dropLat: dropLat ?? 17.4924,
      dropLng: dropLng ?? 78.3995,
      startOtp: (1000 + (now.millisecond % 9000)).toString(),
      scheduledStartTime:
          '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}',
      createdAt: now.toIso8601String(),
    );
  }
}
