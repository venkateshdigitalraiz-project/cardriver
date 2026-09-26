import '../../domain/entities/customer_entity.dart';

class CustomerModel extends CustomerEntity {
  const CustomerModel({
    required super.id,
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
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as String,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      avatarUrl: json['avatarUrl'] as String? ?? 'https://i.pravatar.cc/300?u=customer',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      totalRides: json['totalRides'] as int? ?? 0,
      preferredPayment: _paymentFromString(json['preferredPayment'] as String? ?? 'card'),
      token: json['token'] as String? ?? 'jwt_customer_token_sample',
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
    );
  }
}
