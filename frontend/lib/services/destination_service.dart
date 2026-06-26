import 'package:dio/dio.dart';
import 'auth_service.dart';

class DestinationService {
  late final Dio _dio;

  DestinationService() {
    // Dynamically align base URL with AuthService loopback rules
    final baseUrl = AuthService.apiBaseUrl.replaceAll('/auth', '/destinations');
    
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

  /// Get all Indian destinations from DB
  Future<List<dynamic>> fetchDestinations() async {
    try {
      final response = await _dio.get('/');
      final data = response.data;
      if (data != null && data['status'] == 'success') {
        return data['data']['destinations'] as List<dynamic>;
      }
      return [];
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
    return 'Failed to load destinations from database';
  }
}
