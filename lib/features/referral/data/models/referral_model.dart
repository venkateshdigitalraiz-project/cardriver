import '../../domain/entities/referral_entity.dart';

class ReferralModel extends ReferralEntity {
  const ReferralModel({
    required super.referralCode,
    required super.shareLink,
    super.rewardPerReferral,
    super.totalReferrals,
    super.totalEarned,
    super.currency,
    super.howItWorks,
  });

  factory ReferralModel.fromJson(Map<String, dynamic> json, {String? defaultCode}) {
    final code = json['referralCode']?.toString() ??
        json['code']?.toString() ??
        json['referral_code']?.toString() ??
        defaultCode ??
        'DRV-7890';

    final link = json['shareLink']?.toString() ??
        json['share_url']?.toString() ??
        json['link']?.toString() ??
        'https://cardriver.app/join?ref=$code';

    final reward = (json['rewardPerReferral'] ??
            json['reward_amount'] ??
            json['reward'] ??
            100.0)
        .toDouble();

    final referrals = (json['totalReferrals'] ??
            json['total_referrals'] ??
            json['count'] ??
            0) as num;

    final earned = (json['totalEarned'] ??
            json['total_earned'] ??
            json['earned_amount'] ??
            (referrals * reward))
        .toDouble();

    final currency = json['currency']?.toString() ?? '₹';

    List<String> steps = const [
      'Share your unique referral code with fellow drivers & friends.',
      'They register using your code and complete their first ride.',
      'You get ₹100 credited directly to your driver wallet!',
    ];

    if (json['howItWorks'] is List) {
      steps = (json['howItWorks'] as List)
          .map((e) => e.toString())
          .where((e) => e.trim().isNotEmpty)
          .toList();
    }

    return ReferralModel(
      referralCode: code,
      shareLink: link,
      rewardPerReferral: reward,
      totalReferrals: referrals.toInt(),
      totalEarned: earned,
      currency: currency,
      howItWorks: steps,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'referralCode': referralCode,
      'shareLink': shareLink,
      'rewardPerReferral': rewardPerReferral,
      'totalReferrals': totalReferrals,
      'totalEarned': totalEarned,
      'currency': currency,
      'howItWorks': howItWorks,
    };
  }
}

