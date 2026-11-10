import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_logger.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../models/rating_model.dart';

abstract class RatingRemoteDataSource {
  Future<bool> submitRating({
    required RatingModel model,
    String? token,
  });
}

class RatingRemoteDataSourceImpl implements RatingRemoteDataSource {
  final http.Client _client;

  RatingRemoteDataSourceImpl({http.Client? client})
      : _client = client ?? LoggingHttpClient();

  Future<String> _resolveCleanToken(String? provided) async {
    final clean = (provided ?? '').trim();
    if (clean.isNotEmpty) {
      return LocalStorageService.cleanToken(clean);
    }
    return await LocalStorageService.getOrCollectToken();
  }

  @override
  Future<bool> submitRating({
    required RatingModel model,
    String? token,
  }) async {
    final effectiveToken = await _resolveCleanToken(token);

    // Primary endpoint: /api/driver/bookings/rate
    // Fallback endpoint: /api/driver/bookings/:id/rate
    final uri = Uri.parse('${ApiEndpoints.baseUrl}/driver/bookings/rate');
    log('🚀 [RatingRemoteDataSource] POST $uri body=${jsonEncode(model.toJson())}');

    try {
      final response = await _client.post(
        uri,
        headers: {
          'Authorization': 'Bearer $effectiveToken',
          'Cookie': 'driver_token=$effectiveToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(model.toJson()),
      ).timeout(
        const Duration(seconds: 12),
        onTimeout: () {
          log('⏱️ [RatingRemoteDataSource] Rating request timed out');
          throw Exception('Connection timed out while submitting rating.');
        },
      );

      log('📥 [RatingRemoteDataSource] Response (${response.statusCode}): ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      }

      // If primary endpoint returns 404, attempt fallback endpoint with bookingId in path
      if (response.statusCode == 404 && model.bookingId.isNotEmpty) {
        final fallbackUri = Uri.parse(
          '${ApiEndpoints.baseUrl}/driver/bookings/${model.bookingId}/rate',
        );
        log('🔄 [RatingRemoteDataSource] Trying fallback POST $fallbackUri');
        final fallbackResponse = await _client.post(
          fallbackUri,
          headers: {
            'Authorization': 'Bearer $effectiveToken',
            'Cookie': 'driver_token=$effectiveToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(model.toJson()),
        ).timeout(const Duration(seconds: 10));

        if (fallbackResponse.statusCode >= 200 && fallbackResponse.statusCode < 300) {
          return true;
        }
      }

      String errorMessage = 'Failed to submit rating (${response.statusCode})';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['message'] != null) {
          errorMessage = decoded['message'].toString();
        }
      } catch (_) {}
      throw Exception(errorMessage);
    } catch (e) {
      log('❌ [RatingRemoteDataSource] Error submitting rating: $e');
      rethrow;
    }
  }
}

