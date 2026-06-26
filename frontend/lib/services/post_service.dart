import 'package:dio/dio.dart';
import 'auth_service.dart';

class PostService {
  late final Dio _dio;

  PostService() {
    final baseUrl = AuthService.apiBaseUrl.replaceAll('/auth', '/posts');
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

  /// Fetch feed posts from MongoDB
  Future<List<dynamic>> fetchPosts() async {
    try {
      final response = await _dio.get('/');
      final data = response.data;
      if (data != null && data['status'] == 'success') {
        return data['data']['posts'] as List<dynamic>;
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
    return 'Failed to load feed posts';
  }
}
