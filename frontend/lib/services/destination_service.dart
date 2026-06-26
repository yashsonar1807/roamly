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

  /// Get destinations from DB with filtering and pagination
  Future<Map<String, dynamic>> fetchDestinations({
    String? search,
    String? category,
    double? minRating,
    int page = 1,
    int limit = 6,
  }) async {
    try {
      final Map<String, dynamic> queryParameters = {
        'page': page,
        'limit': limit,
      };
      if (search != null && search.trim().isNotEmpty) {
        queryParameters['search'] = search.trim();
      }
      if (category != null && category != 'All') {
        queryParameters['category'] = category;
      }
      if (minRating != null) {
        queryParameters['minRating'] = minRating;
      }

      final response = await _dio.get('/', queryParameters: queryParameters);
      final data = response.data;
      if (data != null && data['status'] == 'success') {
        return {
          'destinations': data['data']['destinations'] as List<dynamic>,
          'pagination': data['pagination'] as Map<String, dynamic>,
        };
      }
      return {
        'destinations': [],
        'pagination': {'total': 0, 'page': 1, 'pages': 1, 'limit': 6},
      };
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
