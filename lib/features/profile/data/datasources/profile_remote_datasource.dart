import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../models/driver_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<DriverProfileModel> getDriverProfile({String? token});
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final http.Client _client;
  final LocalStorageService? storageService;

  Future<String> _resolveCleanToken(String? provided) async {
    String cleanToken = (provided ?? '').trim();
    if (cleanToken.isNotEmpty) {
      return LocalStorageService.cleanToken(cleanToken);
    }
    return await LocalStorageService.getOrCollectToken(storageService);
  }

  @override
  Future<DriverProfileModel> getDriverProfile({String? token}) async {
    final cleanToken = await _resolveCleanToken(token);

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
      throw const ServerException(
        message: 'Unexpected data format received from driver profile API.',
      );
    } else {
      String serverMessage = '';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded['message'] != null) {
          serverMessage = decoded['message'].toString().trim();
        }
      } catch (_) {}

      String friendlyMessage = serverMessage;
      if (response.statusCode == 401) {
        if (friendlyMessage.isEmpty ||
            friendlyMessage.toLowerCase().contains('unauthorized') ||
            friendlyMessage.toLowerCase().contains('token') ||
            friendlyMessage.toLowerCase().contains('expired')) {
          friendlyMessage = 'Your session has expired. Please log in again to continue.';
        }
        if (storageService != null) {
          try {
            await storageService!.clearLoginData();
          } catch (_) {}
        }
      } else if (response.statusCode == 404) {
        if (friendlyMessage.isEmpty ||
            friendlyMessage.toLowerCase().contains('not found') ||
            friendlyMessage.toLowerCase().contains('driver')) {
          friendlyMessage = 'Driver profile not found. Please log in again.';
        }
        if (storageService != null) {
          try {
            await storageService!.clearLoginData();
          } catch (_) {}
        }
      } else if (friendlyMessage.isEmpty) {
        friendlyMessage = 'Failed to fetch driver profile. Please try again.';
      }

      throw ServerException(
        message: friendlyMessage,
        statusCode: response.statusCode,
      );
    }
  }
}
