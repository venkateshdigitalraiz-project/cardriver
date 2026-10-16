import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/trip_entity.dart';

abstract class TripRemoteDataSource {
  Future<List<TripEntity>> getDriverBookings({String? token});
  Future<TripEntity> getDriverBookingDetails({
    required String bookingId,
    String? token,
  });
}

class TripRemoteDataSourceImpl implements TripRemoteDataSource {
  final http.Client _client;

  // Default driver token provided by user
  static const String defaultDriverToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjZhY2YyZDY1NGViY2UxNDlhMzZlOWI1ZCIsInJvbGUiOiJkcml2ZXIiLCJpYXQiOjE3OTIxMjk0OTIsImV4cCI6MTc5MjczNDI5Mn0.kH366huiPeZurFW8CHmlsPmEljQOzag8sHKPmup-OBU';

  TripRemoteDataSourceImpl({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<List<TripEntity>> getDriverBookings({String? token}) async {
    String cleanToken = (token ?? '').trim();
    if (cleanToken.toLowerCase().startsWith('bearer ')) {
      cleanToken = cleanToken.substring(7).trim();
    }
    final effectiveToken =
        (cleanToken.isNotEmpty && cleanToken.split('.').length == 3)
            ? cleanToken
            : defaultDriverToken;

    final uri = Uri.parse(ApiEndpoints.driverBookings);
    log('🚀 [TripRemoteDataSource] GET $uri with Bearer token');

    try {
      final response = await _client.get(
        uri,
        headers: {
          'Authorization': 'Bearer $effectiveToken',
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          log('⏱️ [TripRemoteDataSource] Request timed out after 15 seconds');
          throw Exception('Connection timed out while fetching bookings.');
        },
      );

      log('📥 [TripRemoteDataSource] Status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic decoded = jsonDecode(response.body);
        List<dynamic> bookingListJson = [];

        if (decoded is Map) {
          final data = decoded['data'];
          if (data is Map && data['bookings'] is List) {
            bookingListJson = data['bookings'] as List;
          } else if (decoded['bookings'] is List) {
            bookingListJson = decoded['bookings'] as List;
          } else if (data is List) {
            bookingListJson = data;
          }
        } else if (decoded is List) {
          bookingListJson = decoded;
        }

        final bookings = bookingListJson
            .whereType<Map>()
            .map((item) => TripEntity.fromJson(Map<String, dynamic>.from(item)))
            .toList();

        log('✅ [TripRemoteDataSource] Successfully parsed ${bookings.length} bookings');
        return bookings;
      } else {
        String errorMessage = 'Failed to load bookings (${response.statusCode})';
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map && decoded['message'] != null) {
            errorMessage = decoded['message'].toString();
          }
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      log('❌ [TripRemoteDataSource] Error fetching bookings: $e');
      rethrow;
    }
  }

  @override
  Future<TripEntity> getDriverBookingDetails({
    required String bookingId,
    String? token,
  }) async {
    String cleanToken = (token ?? '').trim();
    if (cleanToken.toLowerCase().startsWith('bearer ')) {
      cleanToken = cleanToken.substring(7).trim();
    }
    final effectiveToken =
        (cleanToken.isNotEmpty && cleanToken.split('.').length == 3)
            ? cleanToken
            : defaultDriverToken;

    final uri = Uri.parse(ApiEndpoints.driverBookingDetails(bookingId));
    log('🚀 [TripRemoteDataSource] GET $uri with Bearer token');

    try {
      final response = await _client.get(
        uri,
        headers: {
          'Authorization': 'Bearer $effectiveToken',
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          log('⏱️ [TripRemoteDataSource] Booking details request timed out');
          throw Exception('Connection timed out while fetching booking details.');
        },
      );

      log('📥 [TripRemoteDataSource] Booking Details Status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is Map) {
          final data = decoded['data'];
          if (data is Map && data['booking'] != null) {
            return TripEntity.fromJson(Map<String, dynamic>.from(data['booking']));
          }
          if (decoded['booking'] != null) {
            return TripEntity.fromJson(Map<String, dynamic>.from(decoded['booking']));
          }
          if (data is Map) {
            return TripEntity.fromJson(Map<String, dynamic>.from(data));
          }
        }
        throw Exception('Invalid booking details response format.');
      } else {
        String errorMessage = 'Failed to load booking details (${response.statusCode})';
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map && decoded['message'] != null) {
            errorMessage = decoded['message'].toString();
          }
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      log('❌ [TripRemoteDataSource] Error fetching booking details: $e');
      rethrow;
    }
  }
}
