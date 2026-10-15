import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/available_ride_entity.dart';

abstract class AvailableRidesRemoteDataSource {
  Future<List<AvailableRideEntity>> fetchAvailableRides(String token);
}

class AvailableRidesRemoteDataSourceImpl implements AvailableRidesRemoteDataSource {
  final http.Client _client;

  static const String defaultDriverToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjZhY2YyZDY1NGViY2UxNDlhMzZlOWI1ZCIsInJvbGUiOiJkcml2ZXIiLCJpYXQiOjE3OTE5NzEyODQsImV4cCI6MTc5MjU3NjA4NH0.L4T_-AyHasOEXO5onMJOI2ynFBu7rpUCoz5971nz3jk';

  AvailableRidesRemoteDataSourceImpl({http.Client? client})
      : _client = client ?? http.Client();

  @override
  Future<List<AvailableRideEntity>> fetchAvailableRides(String token) async {
    String cleanToken = token.trim();
    if (cleanToken.toLowerCase().startsWith('bearer ')) {
      cleanToken = cleanToken.substring(7).trim();
    }

    if (cleanToken.isEmpty) {
      cleanToken = defaultDriverToken;
    }

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
}
