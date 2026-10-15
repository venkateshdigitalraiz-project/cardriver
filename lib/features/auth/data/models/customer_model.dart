import '../../domain/entities/customer_entity.dart';

class CustomerModel extends CustomerEntity {
  const CustomerModel({
    super.id = '',
    required super.firstName,
    required super.lastName,
    required super.name,
    required super.email,
    required super.phone,
    required super.avatarUrl,
    required super.rating,
    required super.totalRides,
    super.preferredPayment,
    required super.token,
    super.driverId,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    final firstName = json['firstName'] as String? ?? '';
    final lastName = json['lastName'] as String? ?? '';
    final rawName = json['name'] as String?;
    final computedName = (rawName != null && rawName.isNotEmpty)
        ? rawName
        : ('$firstName $lastName'.trim().isNotEmpty
              ? '$firstName $lastName'.trim()
              : 'Driver');

    return CustomerModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      firstName: firstName,
      lastName: lastName,
      name: computedName,
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      avatarUrl:
          json['avatarUrl'] as String? ??
          'https://i.pravatar.cc/300?u=customer',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      totalRides: json['totalRides'] as int? ?? 0,
      preferredPayment: _paymentFromString(
        json['preferredPayment'] as String? ?? 'card',
      ),
      token: json['token'] as String? ?? '',
      driverId: json['driverId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'name': name,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'rating': rating,
      'totalRides': totalRides,
      'preferredPayment': preferredPayment.name,
      'token': token,
      if (driverId != null) 'driverId': driverId,
    };
  }

  static CustomerPaymentMethod _paymentFromString(String val) {
    switch (val.toLowerCase()) {
      case 'applepay':
        return CustomerPaymentMethod.applePay;
      case 'cash':
        return CustomerPaymentMethod.cash;
      case 'wallet':
        return CustomerPaymentMethod.wallet;
      case 'card':
      default:
        return CustomerPaymentMethod.card;
    }
  }

  factory CustomerModel.fromEntity(CustomerEntity entity) {
    return CustomerModel(
      id: entity.id,
      firstName: entity.firstName,
      lastName: entity.lastName,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      avatarUrl: entity.avatarUrl,
      rating: entity.rating,
      totalRides: entity.totalRides,
      preferredPayment: entity.preferredPayment,
      token: entity.token,
      driverId: entity.driverId,
    );
  }
}
