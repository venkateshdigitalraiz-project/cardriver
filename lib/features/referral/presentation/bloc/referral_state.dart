import 'package:equatable/equatable.dart';
import '../../domain/entities/referral_entity.dart';

abstract class ReferralState extends Equatable {
  const ReferralState();

  @override
  List<Object?> get props => [];
}

class ReferralInitial extends ReferralState {}

class ReferralLoading extends ReferralState {}

class ReferralLoaded extends ReferralState {
  final ReferralEntity referral;
  final bool isCopied;
  final String? message;

  const ReferralLoaded({
    required this.referral,
    this.isCopied = false,
    this.message,
  });

  ReferralLoaded copyWith({
    ReferralEntity? referral,
    bool? isCopied,
    String? message,
  }) {
    return ReferralLoaded(
      referral: referral ?? this.referral,
      isCopied: isCopied ?? this.isCopied,
      message: message,
    );
  }

  @override
  List<Object?> get props => [referral, isCopied, message];
}

class ReferralError extends ReferralState {
  final String message;

  const ReferralError(this.message);

  @override
  List<Object?> get props => [message];
}

