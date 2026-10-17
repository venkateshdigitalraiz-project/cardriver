import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../models/driver_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<DriverProfileModel> getDriverProfile({String? token});
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final http.Client _client;
  final LocalStorageService? storageService;

  // Default driver token for the environment
  static const String defaultDriverToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjZhY2YyZDY1NGViY2UxNDlhMzZlOWI1ZCIsInJvbGUiOiJkcml2ZXIiLCJpYXQiOjE3OTIxMjk0OTIsImV4cCI6MTc5MjczNDI5Mn0.kH366huiPeZurFW8CHmlsPmEljQOzag8sHKPmup-OBU';

  ProfileRemoteDataSourceImpl({
    http.Client? client,
    this.storageService,
  }) : _client = client ?? http.Client();

  @override
  Future<DriverProfileModel> getDriverProfile({String? token}) async {
    String cleanToken = (token ?? '').trim();

    if (cleanToken.isEmpty && storageService != null) {
      try {
        final stored = await storageService!.getToken();
        if (stored != null && stored.trim().isNotEmpty) {
          cleanToken = stored.trim();
        }
      } catch (_) {}
    }

    if (cleanToken.toLowerCase().startsWith('bearer ')) {
      cleanToken = cleanToken.substring(7).trim();
    }

    if (cleanToken.isEmpty) {
      cleanToken = defaultDriverToken;
    }

    final uri = Uri.parse(ApiEndpoints.driverProfile);
    log('🚀 [ProfileRemoteDataSource] GET $uri');

    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $cleanToken',
      'Cookie': 'driver_token=$cleanToken',
    };

    final response = await _client.get(uri, headers: headers).timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        log('⏱️ [ProfileRemoteDataSource] Request timed out for driver profile');
        throw Exception('Connection timed out while fetching driver profile.');
      },
    );

    log('📥 [ProfileRemoteDataSource] Status: ${response.statusCode}');
    log('📥 [ProfileRemoteDataSource] Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map) {
        final map = Map<String, dynamic>.from(decoded);
        final dynamic data = map['data'] ?? map['driver'] ?? map;
        if (data is Map) {
          final model =
              DriverProfileModel.fromJson(Map<String, dynamic>.from(data));

          // Also optionally persist updated details to local storage
          if (storageService != null) {
            storageService!.saveLoginData(
              token: cleanToken,
              id: model.id,
              firstName: model.firstName,
              lastName: model.lastName,
              phone: model.phone,
              email: model.email,
              driverId: model.driverId,
            );
          }

          return model;
        }
      }
      throw Exception('Unexpected data format received from driver profile API.');
    } else {
      String message = 'Failed to fetch driver profile.';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['message'] != null) {
          message = decoded['message'].toString();
        }
      } catch (_) {}
      throw Exception('$message (Status code: ${response.statusCode})');
    }
  }
}
