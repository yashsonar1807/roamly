import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  late final Dio _dio;

  // Base URL auto-detect: use 10.0.2.2 for Android emulator loopback, localhost for web/desktop/iOS
  static final String apiBaseUrl = !kIsWeb && Platform.isAndroid
      ? 'http://10.0.2.2:5000/api/v1/auth'
      : 'http://localhost:5000/api/v1/auth';

  AuthService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Logger Interceptor for clean debugging in development
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('[API Request] ${options.method} ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('[API Response] ${response.statusCode} ${response.data}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          debugPrint('[API Error] ${e.response?.statusCode} - ${e.response?.data ?? e.message}');
          return handler.next(e);
        },
      ),
    );
  }

  // Handle Dio Error to return human-readable message
  String _handleError(DioException e) {
    if (e.response != null && e.response?.data != null) {
      final data = e.response?.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'].toString();
      }
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout, please try again later';
      case DioExceptionType.connectionError:
        return 'Server unreachable. Ensure backend is running.';
      default:
        return 'Something went wrong, please try again';
    }
  }

  /// Register a user
  Future<Map<String, dynamic>> register({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/register', data: {
        'name': name,
        'username': username,
        'email': email,
        'password': password,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Login a user
  Future<Map<String, dynamic>> login({
    required String emailOrUsername,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/login', data: {
        'emailOrUsername': emailOrUsername,
        'password': password,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Fetch user profile (authenticated)
  Future<Map<String, dynamic>> getProfile(String token) async {
    try {
      final response = await _dio.get(
        '/profile',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update user profile (authenticated)
  Future<Map<String, dynamic>> updateProfile({
    required String token,
    String? name,
    String? phone,
    String? bio,
    String? country,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (name != null) data['name'] = name;
      if (phone != null) data['phone'] = phone;
      if (bio != null) data['bio'] = bio;
      if (country != null) data['country'] = country;

      final response = await _dio.put(
        '/profile',
        data: data,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Logout user
  Future<Map<String, dynamic>> logout(String token) async {
    try {
      final response = await _dio.post(
        '/logout',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Refresh token
  Future<Map<String, dynamic>> refresh(String refreshToken) async {
    try {
      final response = await _dio.post('/refresh', data: {
        'refreshToken': refreshToken,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Send forgot password request
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await _dio.post('/forgot-password', data: {
        'email': email,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
}
