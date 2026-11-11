import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_logger.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../models/referral_model.dart';

abstract class ReferralRemoteDataSource {
  Future<ReferralModel> getReferralInfo({String? token});
}

class ReferralRemoteDataSourceImpl implements ReferralRemoteDataSource {
  final http.Client _client;

  ReferralRemoteDataSourceImpl({http.Client? client})
      : _client = client ?? LoggingHttpClient();

  Future<String> _resolveCleanToken(String? provided) async {
    final clean = (provided ?? '').trim();
    if (clean.isNotEmpty) {
      return LocalStorageService.cleanToken(clean);
    }
    return await LocalStorageService.getOrCollectToken();
  }

  @override
  Future<ReferralModel> getReferralInfo({String? token}) async {
    final effectiveToken = await _resolveCleanToken(token);
    String driverId = '7890';
    try {
      final prefs = await SharedPreferences.getInstance();
      driverId = prefs.getString(LocalStorageService.keyDriverCustomId) ??
          prefs.getString(LocalStorageService.keyDriverId) ??
          prefs.getString(LocalStorageService.keyPhone) ??
          prefs.getString('driver_id') ??
          '7890';
    } catch (_) {}

    final fallbackCode = 'DRV-${driverId.length > 4 ? driverId.substring(driverId.length - 4) : driverId.toUpperCase()}';

    final uri = Uri.parse('${ApiEndpoints.baseUrl}/driver/referral');
    log('🚀 [ReferralRemoteDataSource] GET $uri');

    try {
      final response = await _client.get(
        uri,
        headers: {
          'Authorization': 'Bearer $effectiveToken',
          'Cookie': 'driver_token=$effectiveToken',
          'Accept': 'application/json',
        },
      );

      log('📥 [ReferralRemoteDataSource] status=${response.statusCode} body=${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          final data = decoded['data'] is Map<String, dynamic>
              ? decoded['data'] as Map<String, dynamic>
              : decoded;
          return ReferralModel.fromJson(data, defaultCode: fallbackCode);
        }
      }
    } catch (e, stack) {
      log('⚠️ [ReferralRemoteDataSource] API error: $e\n$stack');
    }

    // Default graceful model for resilient offline/mock operation
    return ReferralModel(
      referralCode: fallbackCode,
      shareLink: 'https://cardriver.app/join?ref=$fallbackCode',
      rewardPerReferral: 100.0,
      totalReferrals: 0,
      totalEarned: 0.0,
      currency: '₹',
    );
  }
}

