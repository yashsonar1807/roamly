import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';

class NotificationService {
  late final Dio _dio;

  NotificationService() {
    final baseUrl = AuthService.apiBaseUrl.replaceAll('/auth', '/notifications');
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
  }

  Future<List<dynamic>> getNotifications(String token) async {
    try {
      final response = await _dio.get(
        '/notifications',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.data['status'] == 'success') {
        return response.data['data']['notifications'] as List<dynamic>;
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<int> getUnreadCount(String token) async {
    try {
      final response = await _dio.get(
        '/notifications/unread-count',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.data['status'] == 'success') {
        return response.data['data']['unreadCount'] as int;
      }
      return 0;
    } on DioException catch (e) {
      debugPrint('Failed to get unread count: $e');
      return 0; // return 0 silently instead of throwing, it's just a badge
    }
  }

  Future<bool> markAsRead(String token, String notificationId) async {
    try {
      final response = await _dio.put(
        '/notifications/$notificationId/read',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data['status'] == 'success';
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> markAllAsRead(String token) async {
    try {
      final response = await _dio.put(
        '/notifications/read-all',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return response.data['status'] == 'success';
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
    return 'Failed to process notification request';
  }
}
