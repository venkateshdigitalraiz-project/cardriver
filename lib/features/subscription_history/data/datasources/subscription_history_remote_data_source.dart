import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/subscription_history_response_entity.dart';

abstract class SubscriptionHistoryRemoteDataSource {
  Future<SubscriptionHistoryResponseEntity> getSubscriptionHistory({
    String? token,
  });
}

class SubscriptionHistoryRemoteDataSourceImpl
    implements SubscriptionHistoryRemoteDataSource {
  final http.Client _client;

  // Default driver token from curl requests
  static const String defaultDriverToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjZhY2YyZDY1NGViY2UxNDlhMzZlOWI1ZCIsInJvbGUiOiJkcml2ZXIiLCJpYXQiOjE3OTIxMjk0OTIsImV4cCI6MTc5MjczNDI5Mn0.kH366huiPeZurFW8CHmlsPmEljQOzag8sHKPmup-OBU';

  SubscriptionHistoryRemoteDataSourceImpl({http.Client? client})
      : _client = client ?? http.Client();

  @override
  Future<SubscriptionHistoryResponseEntity> getSubscriptionHistory({
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
    log('🚀 [SubscriptionHistoryRemoteDataSource] GET $uri');

    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $cleanToken',
      'Cookie': 'driver_token=$cleanToken',
    };

    final response = await _client.get(uri, headers: headers).timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        log('⏱️ [SubscriptionHistoryRemoteDataSource] Request timed out');
        throw Exception(
          'Connection timed out while fetching driver subscription history.',
        );
      },
    );

    log('📥 [SubscriptionHistoryRemoteDataSource] Status: ${response.statusCode}');
    log('📥 [SubscriptionHistoryRemoteDataSource] Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map) {
        return SubscriptionHistoryResponseEntity.fromJson(
          Map<String, dynamic>.from(decoded),
        );
      }
      throw Exception('Unexpected response format from subscription API.');
    } else {
      String message = 'Failed to fetch driver subscription.';
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
