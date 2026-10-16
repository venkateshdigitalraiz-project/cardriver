import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/subscription_activation_entity.dart';
import '../../domain/entities/subscription_plan_entity.dart';

abstract class SubscriptionRemoteDataSource {
  Future<List<SubscriptionPlanEntity>> getSubscriptionPlans({String? token});

  Future<SubscriptionActivationEntity> activateSubscription({
    required String planId,
    required String paymentMethod,
    String? token,
  });
}

class SubscriptionRemoteDataSourceImpl
    implements SubscriptionRemoteDataSource {
  final http.Client _client;

  // Default driver token as provided in requests
  static const String defaultDriverToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjZhY2YyZDY1NGViY2UxNDlhMzZlOWI1ZCIsInJvbGUiOiJkcml2ZXIiLCJpYXQiOjE3OTIxMjk0OTIsImV4cCI6MTc5MjczNDI5Mn0.kH366huiPeZurFW8CHmlsPmEljQOzag8sHKPmup-OBU';

  SubscriptionRemoteDataSourceImpl({http.Client? client})
      : _client = client ?? http.Client();

  @override
  Future<List<SubscriptionPlanEntity>> getSubscriptionPlans({
    String? token,
  }) async {
    String cleanToken = (token ?? '').trim();
    if (cleanToken.toLowerCase().startsWith('bearer ')) {
      cleanToken = cleanToken.substring(7).trim();
    }
    if (cleanToken.isEmpty) {
      cleanToken = defaultDriverToken;
    }

    final uri = Uri.parse(ApiEndpoints.driverSubscriptionPlans);
    log('🚀 [SubscriptionRemoteDataSource] GET $uri');

    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $cleanToken',
      'Cookie': 'driver_token=$cleanToken',
    };

    final response = await _client.get(uri, headers: headers).timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        log('⏱️ [SubscriptionRemoteDataSource] Request timed out');
        throw Exception(
          'Connection timed out while fetching subscription plans.',
        );
      },
    );

    log('📥 [SubscriptionRemoteDataSource] Status: ${response.statusCode}');
    log('📥 [SubscriptionRemoteDataSource] Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic decoded = jsonDecode(response.body);
      List<dynamic> listJson = [];

      if (decoded is Map) {
        final map = Map<String, dynamic>.from(decoded);
        final dynamic data = map['data'];
        if (data is List) {
          listJson = data;
        } else if (map['plans'] is List) {
          listJson = map['plans'] as List;
        } else if (map['subscriptionPlans'] is List) {
          listJson = map['subscriptionPlans'] as List;
        } else if (data is Map) {
          listJson = [data];
        }
      } else if (decoded is List) {
        listJson = decoded;
      }

      final plans = listJson
          .whereType<Map>()
          .map((m) =>
              SubscriptionPlanEntity.fromJson(Map<String, dynamic>.from(m)))
          .where((p) => p.id.isNotEmpty || p.name.isNotEmpty)
          .toList();

      return plans;
    } else {
      String message = 'Failed to fetch subscription plans.';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['message'] != null) {
          message = decoded['message'].toString();
        }
      } catch (_) {}
      throw Exception(
        '$message (Status code: ${response.statusCode})',
      );
    }
  }

  @override
  Future<SubscriptionActivationEntity> activateSubscription({
    required String planId,
    required String paymentMethod,
    String? token,
  }) async {
    String cleanToken = (token ?? '').trim();
    if (cleanToken.toLowerCase().startsWith('bearer ')) {
      cleanToken = cleanToken.substring(7).trim();
    }
    if (cleanToken.isEmpty) {
      cleanToken = defaultDriverToken;
    }

    final uri = Uri.parse(ApiEndpoints.driverSubscription);
    log('🚀 [SubscriptionRemoteDataSource] POST $uri with planId: $planId, method: $paymentMethod');

    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $cleanToken',
      'Cookie': 'driver_token=$cleanToken',
    };

    final requestBody = jsonEncode({
      'planId': planId,
      'paymentMethod': paymentMethod,
    });

    final response = await _client
        .post(uri, headers: headers, body: requestBody)
        .timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        log('⏱️ [SubscriptionRemoteDataSource] Request timed out while activating pass');
        throw Exception('Connection timed out while activating subscription.');
      },
    );

    log('📥 [SubscriptionRemoteDataSource] Activation Status: ${response.statusCode}');
    log('📥 [SubscriptionRemoteDataSource] Activation Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map) {
        final map = Map<String, dynamic>.from(decoded);
        final dynamic data = map['data'] ?? map;
        final message = map['message']?.toString();
        if (data is Map) {
          return SubscriptionActivationEntity.fromJson(
            Map<String, dynamic>.from(data),
            message: message,
          );
        }
      }
      throw Exception('Unexpected response format from subscription purchase.');
    } else {
      String message = 'Failed to activate subscription.';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['message'] != null) {
          message = decoded['message'].toString();
        }
      } catch (_) {}
      throw Exception(
        '$message (Status code: ${response.statusCode})',
      );
    }
  }
}
