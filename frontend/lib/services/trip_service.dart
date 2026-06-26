import 'package:dio/dio.dart';
import 'auth_service.dart';

class TripService {
  late final Dio _dio;

  TripService() {
    // Dynamically align base URL with AuthService loopback rules
    final baseUrl = AuthService.apiBaseUrl.replaceAll('/auth', '/trips');

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  /// Get user logged trips
  Future<List<dynamic>> fetchTrips(String token) async {
    try {
      final response = await _dio.get(
        '/',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final data = response.data;
      if (data != null && data['status'] == 'success') {
        return data['data']['trips'] as List<dynamic>;
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Log a new trip entry to database
  Future<Map<String, dynamic>> logTrip({
    required String token,
    required String title,
    required String destination,
    DateTime? startDate,
    DateTime? endDate,
    int? spotsCount,
    required String notes,
  }) async {
    try {
      final response = await _dio.post(
        '/',
        data: {
          'title': title,
          'destination': destination,
          'startDate': startDate?.toIso8601String(),
          'endDate': endDate?.toIso8601String(),
          'spotsCount': spotsCount ?? 0,
          'notes': notes,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response != null && e.response?.data != null) {
      final data = e.response?.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'].toString();
      }
    }
    return 'Failed to interact with trips database';
  }
}
