import '../entities/referral_entity.dart';

abstract class ReferralRepository {
  Future<ReferralEntity> getReferralInfo({String? token});
}

