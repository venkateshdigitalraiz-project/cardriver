import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/accepted_ride_entity.dart';
import '../../domain/entities/rejected_ride_entity.dart';
import '../models/available_ride_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<AvailableRideModel>> getAvailableRides({String? token});
  Future<AcceptedRideEntity> acceptRide({
    required String rideId,
    required String token,
  });
  Future<RejectedRideEntity> rejectRide({
    required String rideId,
    required String token,
    String? reason,
  });
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final Dio dio;

  // Default driver token as requested by user
  static const String defaultDriverToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjZhY2YyZDY1NGViY2UxNDlhMzZlOWI1ZCIsInJvbGUiOiJkcml2ZXIiLCJpYXQiOjE3OTE5NzEyODQsImV4cCI6MTc5MjU3NjA4NH0.L4T_-AyHasOEXO5onMJOI2ynFBu7rpUCoz5971nz3jk';

  HomeRemoteDataSourceImpl({Dio? dioClient})
      : dio = dioClient ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
              ),
            );

  @override
  Future<List<AvailableRideModel>> getAvailableRides({String? token}) async {
    String cleanToken = (token ?? '').trim();
    if (cleanToken.toLowerCase().startsWith('bearer ')) {
      cleanToken = cleanToken.substring(7).trim();
    }

    final effectiveToken =
        (cleanToken.isNotEmpty && cleanToken.split('.').length == 3)
            ? cleanToken
            : defaultDriverToken;

    try {
      final response = await dio.get(
        ApiEndpoints.driverAvailableRides,
        options: Options(
          headers: {
            'Authorization': 'Bearer $effectiveToken',
            'content-type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> rideListJson = [];

        if (data is Map) {
          final mapData = Map<String, dynamic>.from(data);
          final innerData = mapData['data'];
          if (innerData is Map) {
            final innerMap = Map<String, dynamic>.from(innerData);
            if (innerMap['rides'] is List) {
              rideListJson = innerMap['rides'] as List;
            } else if (innerMap['availableRides'] is List) {
              rideListJson = innerMap['availableRides'] as List;
            } else if (innerMap['bookings'] is List) {
              rideListJson = innerMap['bookings'] as List;
            }
          } else if (innerData is List) {
            rideListJson = innerData;
          } else if (mapData['rides'] is List) {
            rideListJson = mapData['rides'] as List;
          } else if (mapData['availableRides'] is List) {
            rideListJson = mapData['availableRides'] as List;
          } else if (mapData['bookings'] is List) {
            rideListJson = mapData['bookings'] as List;
          }
        } else if (data is List) {
          rideListJson = data;
        }

        return rideListJson
            .whereType<Map>()
            .map((item) =>
                AvailableRideModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } else {
        throw ServerException(
          message: 'Failed to fetch available rides: Status ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const AuthException(message: 'Authentication session expired.');
      }
      throw ServerException(
        message: e.response?.data?['message']?.toString() ??
            e.message ??
            'Network error while fetching available rides.',
      );
    } catch (e) {
      if (e is ServerException || e is AuthException) rethrow;
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<AcceptedRideEntity> acceptRide({
    required String rideId,
    required String token,
  }) async {
    String cleanToken = token.trim();
    if (cleanToken.toLowerCase().startsWith('bearer ')) {
      cleanToken = cleanToken.substring(7).trim();
    }
    final effectiveToken =
        (cleanToken.isNotEmpty && cleanToken.split('.').length == 3)
            ? cleanToken
            : defaultDriverToken;

    try {
      final response = await dio.post(
        ApiEndpoints.driverAcceptRide(rideId),
        options: Options(
          headers: {
            'Authorization': 'Bearer $effectiveToken',
            'content-type': 'application/json',
          },
        ),
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final data = response.data;
        if (data is Map) {
          final mapData = Map<String, dynamic>.from(data);
          final dynamic innerData = mapData['data'] ?? mapData;
          final message = mapData['message']?.toString();
          if (innerData is Map) {
            return AcceptedRideEntity.fromJson(
              Map<String, dynamic>.from(innerData),
              defaultMessage: message,
            );
          }
        }
        throw ServerException(
          message: 'Unexpected response format when accepting ride.',
        );
      } else {
        throw ServerException(
          message: 'Failed to accept ride: Status ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const AuthException(message: 'Authentication session expired.');
      }
      throw ServerException(
        message: e.response?.data?['message']?.toString() ??
            e.message ??
            'Network error while accepting ride.',
      );
    } catch (e) {
      if (e is ServerException || e is AuthException) rethrow;
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<RejectedRideEntity> rejectRide({
    required String rideId,
    required String token,
    String? reason,
  }) async {
    String cleanToken = token.trim();
    if (cleanToken.toLowerCase().startsWith('bearer ')) {
      cleanToken = cleanToken.substring(7).trim();
    }
    final effectiveToken =
        (cleanToken.isNotEmpty && cleanToken.split('.').length == 3)
            ? cleanToken
            : defaultDriverToken;

    try {
      final response = await dio.post(
        ApiEndpoints.driverRejectRide(rideId),
        data: reason != null && reason.trim().isNotEmpty
            ? {'reason': reason.trim()}
            : null,
        options: Options(
          headers: {
            'Authorization': 'Bearer $effectiveToken',
            'content-type': 'application/json',
          },
        ),
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final data = response.data;
        if (data is Map) {
          return RejectedRideEntity.fromJson(
            Map<String, dynamic>.from(data),
          );
        }
        throw ServerException(
          message: 'Unexpected response format when rejecting ride.',
        );
      } else {
        throw ServerException(
          message: 'Failed to reject ride: Status ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const AuthException(message: 'Authentication session expired.');
      }
      throw ServerException(
        message: e.response?.data?['message']?.toString() ??
            e.message ??
            'Network error while rejecting ride.',
      );
    } catch (e) {
      if (e is ServerException || e is AuthException) rethrow;
      throw ServerException(message: 'Unexpected error: ${e.toString()}');
    }
  }
}
