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

  /// Fetch feed posts from MongoDB with pagination
  Future<Map<String, dynamic>> fetchPosts({int page = 1, int limit = 10}) async {
    try {
      final response = await _dio.get('/', queryParameters: {'page': page, 'limit': limit});
      final data = response.data;
      if (data != null && data['status'] == 'success') {
        return {
          'posts': data['data']['posts'] as List<dynamic>,
          'pagination': data['pagination'],
        };
      }
      return {'posts': [], 'pagination': {}};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Create a new post with optional file (Image/Video) upload
  Future<Map<String, dynamic>> createPost({
    required String token,
    required String caption,
    required String location,
    List<int>? fileBytes,
    String? fileName,
    void Function(int sent, int total)? onProgress,
  }) async {
    try {
      MultipartFile? multipartFile;
      if (fileBytes != null && fileName != null) {
        multipartFile = MultipartFile.fromBytes(
          fileBytes,
          filename: fileName,
        );
      }

      final formData = FormData.fromMap({
        'caption': caption,
        'location': location,
        if (multipartFile != null) 'media': multipartFile,
      });

      final response = await _dio.post(
        '/',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
        onSendProgress: onProgress,
      );

      final data = response.data;
      if (data != null && data['status'] == 'success') {
        return data['data']['post'] as Map<String, dynamic>;
      }
      throw 'Failed to create post';
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete a post
  Future<void> deletePost({required String token, required String postId}) async {
    try {
      await _dio.delete(
        '/$postId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Toggle like on a post
  Future<Map<String, dynamic>> toggleLike({required String token, required String postId}) async {
    try {
      final response = await _dio.post(
        '/$postId/like',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.data != null && response.data['status'] == 'success') {
        return response.data;
      }
      throw 'Failed to toggle like';
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Fetch comments for a post
  Future<List<dynamic>> fetchComments(String postId) async {
    try {
      final response = await _dio.get('/$postId/comments');
      final data = response.data;
      if (data != null && data['status'] == 'success') {
        return data['data']['comments'] as List<dynamic>;
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Add a comment to a post
  Future<Map<String, dynamic>> createComment({
    required String token,
    required String postId,
    required String text,
  }) async {
    try {
      final response = await _dio.post(
        '/$postId/comments',
        data: {'text': text},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.data != null && response.data['status'] == 'success') {
        return response.data['data']['comment'] as Map<String, dynamic>;
      }
      throw 'Failed to add comment';
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete a comment
  Future<void> deleteComment({
    required String token,
    required String postId,
    required String commentId,
  }) async {
    try {
      await _dio.delete(
        '/$postId/comments/$commentId',
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
    return 'Failed to load feed posts';
  }
}
