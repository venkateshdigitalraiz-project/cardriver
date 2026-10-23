import '../../domain/entities/driver_active_subscription_entity.dart';
import '../../domain/entities/driver_profile_entity.dart';
import 'driver_documents_model.dart';

class DriverProfileModel extends DriverProfileEntity {
  const DriverProfileModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phone,
    required super.address,
    required super.driverId,
    required super.licenseNumber,
    required super.pancardNumber,
    required super.aadhaarNumber,
    required super.passportId,
    required super.status,
    required super.isOnline,
    required super.isVerified,
    required super.createdAt,
    required super.updatedAt,
    super.fcmToken,
    required super.hasSubscription,
    super.activeSubscription,
    super.allSubscriptions,
    super.documents,
  });

  factory DriverProfileModel.fromJson(Map<String, dynamic> json) {
    DriverActiveSubscriptionEntity? parsedActiveSub;
    if (json['activeSubscription'] is Map) {
      try {
        parsedActiveSub = DriverActiveSubscriptionEntity.fromJson(
          Map<String, dynamic>.from(json['activeSubscription'] as Map),
        );
      } catch (_) {}
    }

    List<DriverActiveSubscriptionEntity> parsedAllSubs = [];
    if (json['allSubscriptions'] is List) {
      parsedAllSubs = (json['allSubscriptions'] as List)
          .whereType<Map>()
          .map(
            (m) => DriverActiveSubscriptionEntity.fromJson(
              Map<String, dynamic>.from(m),
            ),
          )
          .toList();
    }

    final hasSubVal = json['hasSubscription'];
    bool parsedHasSub = false;
    if (hasSubVal is bool) {
      parsedHasSub = hasSubVal;
    } else if (hasSubVal != null) {
      parsedHasSub = hasSubVal.toString().toLowerCase() == 'true';
    } else if (parsedActiveSub != null) {
      parsedHasSub = true;
    }

    final topLicense = (json['licenseNumber'] ?? '').toString().trim();
    final topPancard = (json['pancardNumber'] ?? '').toString().trim();
    final topAadhaar = (json['aadhaarNumber'] ?? '').toString().trim();
    final topPassport = (json['passportId'] ?? '').toString().trim();

    DriverDocumentsModel? parsedDocuments;
    if (json['documents'] is Map) {
      try {
        parsedDocuments = DriverDocumentsModel.fromJson(
          Map<String, dynamic>.from(json['documents'] as Map),
          fallbackAadhaar: topAadhaar,
          fallbackLicense: topLicense,
          fallbackPan: topPancard,
          fallbackPassport: topPassport,
        );
      } catch (_) {}
    } else {
      parsedDocuments = DriverDocumentsModel(
        aadhaarNumber: topAadhaar,
        licenseNumber: topLicense,
        pancardNumber: topPancard,
        passportId: topPassport,
      );
    }

    return DriverProfileModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      driverId: (json['driverId'] ?? '').toString(),
      licenseNumber: topLicense,
      pancardNumber: topPancard,
      aadhaarNumber: topAadhaar,
      passportId: topPassport,
      status: (json['status'] ?? 'verified').toString(),
      isOnline: json['isOnline'] == true,
      isVerified: json['isVerified'] == true,
      createdAt: (json['createdAt'] ?? '').toString(),
      updatedAt: (json['updatedAt'] ?? '').toString(),
      fcmToken: (json['fcmToken'] ?? '').toString(),
      hasSubscription: parsedHasSub,
      activeSubscription: parsedActiveSub,
      allSubscriptions: parsedAllSubs,
      documents: parsedDocuments,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'address': address,
      'driverId': driverId,
      'licenseNumber': licenseNumber,
      'pancardNumber': pancardNumber,
      'aadhaarNumber': aadhaarNumber,
      'passportId': passportId,
      'status': status,
      'isOnline': isOnline,
      'isVerified': isVerified,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'fcmToken': fcmToken,
      'hasSubscription': hasSubscription,
      'activeSubscription': activeSubscription?.toJson(),
      'allSubscriptions': allSubscriptions.map((s) => s.toJson()).toList(),
      'documents': documents is DriverDocumentsModel
          ? (documents as DriverDocumentsModel).toJson()
          : null,
    };
  }
}
