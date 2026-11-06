import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_logger.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../domain/entities/subscription_history_response_entity.dart';

abstract class SubscriptionHistoryRemoteDataSource {
  Future<SubscriptionHistoryResponseEntity> getSubscriptionHistory({
    String? token,
  });
}

class SubscriptionHistoryRemoteDataSourceImpl
    implements SubscriptionHistoryRemoteDataSource {
  final http.Client _client;

  SubscriptionHistoryRemoteDataSourceImpl({http.Client? client})
      : _client = client ?? LoggingHttpClient();

  Future<String> _resolveCleanToken(String? provided) async {
    final clean = (provided ?? '').trim();
    if (clean.isNotEmpty) {
      return LocalStorageService.cleanToken(clean);
    }
    return await LocalStorageService.getOrCollectToken();
  }

  @override
  Future<SubscriptionHistoryResponseEntity> getSubscriptionHistory({
    String? token,
  }) async {
    final cleanToken = await _resolveCleanToken(token);

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
