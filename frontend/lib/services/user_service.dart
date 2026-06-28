import 'package:dio/dio.dart';
import 'auth_service.dart';

class UserService {
  late final Dio _dio;

  UserService() {
    final baseUrl = AuthService.apiBaseUrl.replaceAll('/auth', '/users');
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

  Future<Map<String, dynamic>> getProfile(String token, {String? userId}) async {
    try {
      final url = userId != null ? '/profile/$userId' : '/profile';
      final response = await _dio.get(url, options: Options(headers: {'Authorization': 'Bearer $token'}));
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getUserPosts(String token, String userId) async {
    try {
      final response = await _dio.get('/$userId/posts', options: Options(headers: {'Authorization': 'Bearer $token'}));
      return response.data['data'] as List<dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getSavedPosts(String token) async {
    try {
      final response = await _dio.get('/saved', options: Options(headers: {'Authorization': 'Bearer $token'}));
      return response.data['data'] as List<dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> toggleSavePost(String token, String postId) async {
    try {
      final response = await _dio.post('/save/$postId', options: Options(headers: {'Authorization': 'Bearer $token'}));
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> searchUsers(String query) async {
    try {
      final response = await _dio.get('/search', queryParameters: {'q': query});
      if (response.data['status'] == 'success') {
        return response.data['data']['users'] as List<dynamic>;
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> toggleSaveDestination(String token, String destinationId) async {
    try {
      final response = await _dio.post('/save-destination/$destinationId', options: Options(headers: {'Authorization': 'Bearer $token'}));
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getSavedDestinations(String token) async {
    try {
      final response = await _dio.get('/saved-destinations', options: Options(headers: {'Authorization': 'Bearer $token'}));
      return response.data['data'] as List<dynamic>;
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
    return 'Failed to load user data';
  }
}
