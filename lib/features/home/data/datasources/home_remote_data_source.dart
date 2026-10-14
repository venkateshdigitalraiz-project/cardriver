import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/available_ride_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<AvailableRideModel>> getAvailableRides({String? token});
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
    final effectiveToken = (token != null &&
            token.trim().isNotEmpty &&
            token.split('.').length == 3)
        ? token.trim()
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

        if (data is Map<String, dynamic>) {
          if (data['data'] is Map<String, dynamic> &&
              data['data']['rides'] is List) {
            rideListJson = data['data']['rides'] as List;
          } else if (data['rides'] is List) {
            rideListJson = data['rides'] as List;
          } else if (data['data'] is List) {
            rideListJson = data['data'] as List;
          }
        } else if (data is List) {
          rideListJson = data;
        }

        return rideListJson
            .whereType<Map<String, dynamic>>()
            .map((item) => AvailableRideModel.fromJson(item))
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
}
