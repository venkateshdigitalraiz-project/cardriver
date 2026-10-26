import 'package:equatable/equatable.dart';
import 'driver_active_subscription_entity.dart';
import 'driver_documents_entity.dart';

/// Clean Architecture Entity representing the driver profile from /api/driver/profile
class DriverProfileEntity extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final String driverId;
  final String licenseNumber;
  final String pancardNumber;
  final String aadhaarNumber;
  final String passportId;
  String get pvcId => passportId;
  String get pvcNumber => passportId;
  final String status;
  final bool isOnline;
  final bool isVerified;
  final String createdAt;
  final String updatedAt;
  final String? fcmToken;
  final bool hasSubscription;
  final DriverActiveSubscriptionEntity? activeSubscription;
  final List<DriverActiveSubscriptionEntity> allSubscriptions;
  final DriverDocumentsEntity? documents;

  const DriverProfileEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.driverId,
    required this.licenseNumber,
    required this.pancardNumber,
    required this.aadhaarNumber,
    required this.passportId,
    required this.status,
    required this.isOnline,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
    this.fcmToken,
    required this.hasSubscription,
    this.activeSubscription,
    this.allSubscriptions = const [],
    this.documents,
  });

  /// Full display name
  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.isNotEmpty ? name : 'Driver';
  }

  /// Custom driver identifier or fallback mongo id
  String get displayDriverId => driverId.isNotEmpty ? driverId : id;

  /// Check whether driver has an active pass with days remaining
  bool get hasActivePass =>
      hasSubscription &&
      (activeSubscription?.isActive ?? false ||
          (activeSubscription != null && activeSubscription!.daysLeft > 0));

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        email,
        phone,
        address,
        driverId,
        licenseNumber,
        pancardNumber,
        aadhaarNumber,
        passportId,
        status,
        isOnline,
        isVerified,
        createdAt,
        updatedAt,
        fcmToken,
        hasSubscription,
        activeSubscription,
        allSubscriptions,
        documents,
      ];
}
