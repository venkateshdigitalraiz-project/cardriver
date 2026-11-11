import 'package:equatable/equatable.dart';

class ReferralEntity extends Equatable {
  final String referralCode;
  final String shareLink;
  final double rewardPerReferral;
  final int totalReferrals;
  final double totalEarned;
  final String currency;
  final List<String> howItWorks;

  const ReferralEntity({
    required this.referralCode,
    required this.shareLink,
    this.rewardPerReferral = 100.0,
    this.totalReferrals = 0,
    this.totalEarned = 0.0,
    this.currency = '₹',
    this.howItWorks = const [
      'Share your unique referral code with fellow drivers & friends.',
      'They register using your code and complete their first ride.',
      'You get ₹100 credited directly to your driver wallet!',
    ],
  });

  @override
  List<Object?> get props => [
        referralCode,
        shareLink,
        rewardPerReferral,
        totalReferrals,
        totalEarned,
        currency,
        howItWorks,
      ];
}

