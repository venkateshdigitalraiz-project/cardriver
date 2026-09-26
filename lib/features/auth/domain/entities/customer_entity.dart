import 'package:equatable/equatable.dart';

enum CustomerPaymentMethod { card, applePay, cash, wallet }

class CustomerEntity extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String name;
  final String email;
  final String phone;
  final String avatarUrl;
  final double rating;
  final int totalRides;
  final CustomerPaymentMethod preferredPayment;
  final String token;

  const CustomerEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.rating,
    required this.totalRides,
    this.preferredPayment = CustomerPaymentMethod.card,
    required this.token,
  });

  CustomerEntity copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    double? rating,
    int? totalRides,
    CustomerPaymentMethod? preferredPayment,
    String? token,
  }) {
    return CustomerEntity(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rating: rating ?? this.rating,
      totalRides: totalRides ?? this.totalRides,
      preferredPayment: preferredPayment ?? this.preferredPayment,
      token: token ?? this.token,
    );
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        name,
        email,
        phone,
        avatarUrl,
        rating,
        totalRides,
        preferredPayment,
        token,
      ];
}
