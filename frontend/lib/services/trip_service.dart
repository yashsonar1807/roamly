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
  Future<Map<String, dynamic>> createTrip({
    required String token,
    required String title,
    required String destination,
    int? spotsCount,
    String? notes,
  }) async {
    try {
      final response = await _dio.post(
        '/',
        data: {
          'title': title,
          'destination': destination,
          'spotsCount': spotsCount ?? 1,
          'notes': notes ?? '',
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateTrip({
    required String token,
    required String id,
    String? title,
    String? destination,
    int? spotsCount,
    String? notes,
    String? status,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (title != null) data['title'] = title;
      if (destination != null) data['destination'] = destination;
      if (spotsCount != null) data['spotsCount'] = spotsCount;
      if (notes != null) data['notes'] = notes;
      if (status != null) data['status'] = status;
      final response = await _dio.put(
        '/$id',
        data: data,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteTrip({
    required String token,
    required String id,
  }) async {
    try {
      await _dio.delete(
        '/$id',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
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
