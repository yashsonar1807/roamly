import 'package:dio/dio.dart';
import 'auth_service.dart';

class ReviewService {
  late final Dio _dio;

  ReviewService() {
    final baseUrl = AuthService.apiBaseUrl.replaceAll('/auth', '/reviews');
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

  Future<Map<String, dynamic>> fetchReviews(String destinationId, {int page = 1, int limit = 10}) async {
    try {
      final response = await _dio.get('/$destinationId', queryParameters: {'page': page, 'limit': limit});
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> addReview({
    required String token,
    required String destinationId,
    required double rating,
    required String comment,
  }) async {
    try {
      final response = await _dio.post(
        '/$destinationId',
        data: {'rating': rating, 'comment': comment},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data['data']['review'];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateReview({
    required String token,
    required String reviewId,
    required double rating,
    required String comment,
  }) async {
    try {
      final response = await _dio.put(
        '/$reviewId',
        data: {'rating': rating, 'comment': comment},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data['data']['review'];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteReview({
    required String token,
    required String reviewId,
  }) async {
    try {
      await _dio.delete(
        '/$reviewId',
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
    return 'Failed to load reviews';
  }
}
