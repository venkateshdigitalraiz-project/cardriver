import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_logger.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../domain/entities/accepted_ride_entity.dart';
import '../../domain/entities/available_ride_entity.dart';
import '../../domain/entities/d_to_d_booking_entity.dart';
import '../../domain/entities/rejected_ride_entity.dart';
import '../models/d_to_d_booking_model.dart';

abstract class AvailableRidesRemoteDataSource {
  Future<List<AvailableRideEntity>> fetchAvailableRides(String token);
  Future<AcceptedRideEntity> acceptRide({
    required String rideId,
    required String token,
  });
  Future<RejectedRideEntity> rejectRide({
    required String rideId,
    required String token,
    String? reason,
  });
  Future<DtoDBookingEntity> createDtoDBooking({
    required DtoDBookingRequestModel request,
    String? token,
  });
  Future<DtoDBookingsPaginatedEntity> getDtoDBookings({
    int page = 1,
    int limit = 10,
    String? token,
    String? status,
    String? serviceType,
    String? tripType,
    int? durationDays,
    int? durationHours,
  });
}

class AvailableRidesRemoteDataSourceImpl implements AvailableRidesRemoteDataSource {
  final http.Client _client;

  AvailableRidesRemoteDataSourceImpl({http.Client? client})
      : _client = client ?? LoggingHttpClient();

  Future<String> _resolveCleanToken(String? provided) async {
    final clean = (provided ?? '').trim();
    if (clean.isNotEmpty) {
      return LocalStorageService.cleanToken(clean);
    }
    return await LocalStorageService.getOrCollectToken();
  }

  @override
  Future<List<AvailableRideEntity>> fetchAvailableRides(String token) async {
    final cleanToken = await _resolveCleanToken(token);

    final uri = Uri.parse(ApiEndpoints.driverAvailableRides);
    log('🚀 [AvailableRidesRemoteDataSource] GET $uri with Bearer token');

    final response = await _client.get(
      uri,
      headers: {
        'Authorization': 'Bearer $cleanToken',
        'Content-Type': 'application/json',
      },
    ).timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        log('⏱️ [AvailableRidesRemoteDataSource] Request timed out after 15 seconds');
        throw Exception('Connection timed out while fetching available rides.');
      },
    );

    log('📥 [AvailableRidesRemoteDataSource] Status: ${response.statusCode}');
    log('📥 [AvailableRidesRemoteDataSource] Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic decoded = jsonDecode(response.body);
      List<dynamic> ridesList = [];

      if (decoded is List) {
        ridesList = decoded;
      } else if (decoded is Map) {
        final mapData = Map<String, dynamic>.from(decoded);
        final innerData = mapData['data'];
        if (innerData is Map) {
          final innerMap = Map<String, dynamic>.from(innerData);
          if (innerMap['rides'] is List) {
            ridesList = innerMap['rides'] as List;
          } else if (innerMap['availableRides'] is List) {
            ridesList = innerMap['availableRides'] as List;
          } else if (innerMap['bookings'] is List) {
            ridesList = innerMap['bookings'] as List;
          }
        } else if (innerData is List) {
          ridesList = innerData;
        } else if (mapData['rides'] is List) {
          ridesList = mapData['rides'] as List;
        } else if (mapData['availableRides'] is List) {
          ridesList = mapData['availableRides'] as List;
        } else if (mapData['bookings'] is List) {
          ridesList = mapData['bookings'] as List;
        }
      }

      return ridesList
          .whereType<Map>()
          .map((item) => AvailableRideEntity.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .where((ride) => ride.id.isNotEmpty)
          .toList();
    } else {
      throw Exception(
        'Failed to fetch available rides. Server returned status code ${response.statusCode}: ${response.body}',
      );
    }
  }

  @override
  Future<AcceptedRideEntity> acceptRide({
    required String rideId,
    required String token,
  }) async {
    final cleanToken = await _resolveCleanToken(token);

    final uri = Uri.parse(ApiEndpoints.driverAcceptRide(rideId));
    log('🚀 [AvailableRidesRemoteDataSource] POST $uri with Bearer token');

    final response = await _client.post(
      uri,
      headers: {
        'Authorization': 'Bearer $cleanToken',
        'Content-Type': 'application/json',
      },
    ).timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        log('⏱️ [AvailableRidesRemoteDataSource] Accept ride request timed out');
        throw Exception('Connection timed out while accepting ride.');
      },
    );

    log('📥 [AvailableRidesRemoteDataSource] Accept Status: ${response.statusCode}');
    log('📥 [AvailableRidesRemoteDataSource] Accept Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map) {
        final mapData = Map<String, dynamic>.from(decoded);
        final dynamic data = mapData['data'] ?? mapData;
        final message = mapData['message']?.toString();
        if (data is Map) {
          return AcceptedRideEntity.fromJson(
            Map<String, dynamic>.from(data),
            defaultMessage: message,
          );
        }
      }
      throw Exception('Unexpected response format when accepting ride.');
    } else {
      String errorMessage = 'Failed to accept ride.';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['message'] != null) {
          errorMessage = decoded['message'].toString();
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }

  @override
  Future<RejectedRideEntity> rejectRide({
    required String rideId,
    required String token,
    String? reason,
  }) async {
    final cleanToken = await _resolveCleanToken(token);

    final uri = Uri.parse(ApiEndpoints.driverRejectRide(rideId));
    log('🚀 [AvailableRidesRemoteDataSource] POST $uri with Bearer token');

    final body = reason != null && reason.trim().isNotEmpty
        ? jsonEncode({'reason': reason.trim()})
        : null;

    final response = await _client.post(
      uri,
      headers: {
        'Authorization': 'Bearer $cleanToken',
        'Content-Type': 'application/json',
      },
      body: body,
    ).timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        log('⏱️ [AvailableRidesRemoteDataSource] Reject ride request timed out');
        throw Exception('Connection timed out while rejecting ride.');
      },
    );

    log('📥 [AvailableRidesRemoteDataSource] Reject Status: ${response.statusCode}');
    log('📥 [AvailableRidesRemoteDataSource] Reject Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map) {
        final mapData = Map<String, dynamic>.from(decoded);
        return RejectedRideEntity.fromJson(mapData);
      }
      throw Exception('Unexpected response format when rejecting ride.');
    } else {
      String errorMessage = 'Failed to reject ride.';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['message'] != null) {
          errorMessage = decoded['message'].toString();
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }

  @override
  Future<DtoDBookingEntity> createDtoDBooking({
    required DtoDBookingRequestModel request,
    String? token,
  }) async {
    final cleanToken = await _resolveCleanToken(token);

    final uri = Uri.parse(ApiEndpoints.driverDtoDBookings);
    final payload = request.toJson();
    final bodyJson = jsonEncode(payload);

    log('================================================================');
    log('🚀 [AvailableRidesRemoteDataSource] POST D-to-D Booking API');
    log('🌐 URL: $uri');
    log('🔑 Authorization: Bearer ${cleanToken.length > 20 ? "${cleanToken.substring(0, 15)}..." : cleanToken}');
    log('📦 Request Payload:\n${const JsonEncoder.withIndent('  ').convert(payload)}');
    log('================================================================');

    try {
      final response = await _client.post(
        uri,
        headers: {
          'Authorization': 'Bearer $cleanToken',
          'Content-Type': 'application/json',
        },
        body: bodyJson,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          log('⏱️ [AvailableRidesRemoteDataSource] Request timed out after 15 seconds');
          throw Exception('Connection timed out while creating D-to-D booking.');
        },
      );

      log('================================================================');
      log('📥 [AvailableRidesRemoteDataSource] D-to-D Booking Response Received');
      log('📊 Status Code: ${response.statusCode}');
      log('📋 Headers: ${response.headers}');
      log('📄 Response Body:\n${response.body}');
      log('================================================================');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is Map) {
          return DtoDBookingResponseModel.fromJson(
            Map<String, dynamic>.from(decoded),
          );
        }
        return DtoDBookingResponseModel.fromJson({
          'status': 'confirmed',
          'message': 'Driver booking confirmed successfully',
          'data': decoded,
        });
      } else {
        String errorMessage =
            'Failed to create D-to-D booking. Status: ${response.statusCode}';
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map &&
              (decoded['message'] != null || decoded['error'] != null)) {
            errorMessage =
                (decoded['message'] ?? decoded['error']).toString();
          }
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      log('❌ [AvailableRidesRemoteDataSource] Error in D-to-D Booking: $e');
      rethrow;
    }
  }

  @override
  Future<DtoDBookingsPaginatedEntity> getDtoDBookings({
    int page = 1,
    int limit = 10,
    String? token,
    String? status,
    String? serviceType,
    String? tripType,
    int? durationDays,
    int? durationHours,
  }) async {
    final cleanToken = await _resolveCleanToken(token);

    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (status != null && status.trim().isNotEmpty && status.trim().toLowerCase() != 'all') {
      queryParams['status'] = status.trim().toLowerCase();
    }
    if (serviceType != null && serviceType.trim().isNotEmpty && serviceType.trim().toLowerCase() != 'all') {
      queryParams['serviceType'] = serviceType.trim().toLowerCase();
    }
    if (tripType != null && tripType.trim().isNotEmpty && tripType.trim().toLowerCase() != 'all') {
      queryParams['tripType'] = tripType.trim().toLowerCase();
    }
    if (durationDays != null && durationDays > 0) {
      queryParams['durationDays'] = durationDays.toString();
    }
    if (durationHours != null && durationHours > 0) {
      queryParams['durationHours'] = durationHours.toString();
    }

    final uri = Uri.parse(ApiEndpoints.driverDtoDBookings).replace(queryParameters: queryParams);

    log('================================================================');
    log('🚀 [AvailableRidesRemoteDataSource] GET D-to-D Bookings API');
    log('🌐 URL: $uri');
    log('🔑 Authorization: Bearer ${cleanToken.length > 20 ? "${cleanToken.substring(0, 15)}..." : cleanToken}');
    log('📋 Query Parameters: $queryParams');
    log('================================================================');

    try {
      final response = await _client.get(
        uri,
        headers: {
          'Authorization': 'Bearer $cleanToken',
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          log('⏱️ [AvailableRidesRemoteDataSource] Request timed out after 15 seconds');
          throw Exception('Connection timed out while fetching bookings.');
        },
      );

      log('================================================================');
      log('📥 [AvailableRidesRemoteDataSource] D-to-D Bookings Status: ${response.statusCode}');
      log('📄 Body: ${response.body}');
      log('================================================================');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is Map) {
          return DtoDBookingsPaginatedModel.fromJson(
            Map<String, dynamic>.from(decoded),
            requestedPage: page,
            requestedLimit: limit,
          );
        }
        if (decoded is List) {
          return DtoDBookingsPaginatedModel.fromJson(
            {'data': decoded},
            requestedPage: page,
            requestedLimit: limit,
          );
        }
        return DtoDBookingsPaginatedModel(page: page, limit: limit);
      } else {
        String errorMessage =
            'Failed to fetch D-to-D bookings. Status: ${response.statusCode}';
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map &&
              (decoded['message'] != null || decoded['error'] != null)) {
            errorMessage =
                (decoded['message'] ?? decoded['error']).toString();
          }
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      log('❌ [AvailableRidesRemoteDataSource] Error fetching D-to-D Bookings: $e');
      rethrow;
    }
  }
}
