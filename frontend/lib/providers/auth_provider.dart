import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  AuthStatus _status = AuthStatus.initial;
  AuthStatus get status => _status;

  Map<String, dynamic>? _user;
  Map<String, dynamic>? get user => _user;

  String? _accessToken;
  String? get accessToken => _accessToken;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';

  /// Initial Auto-Login check (runs on Splash screen)
  Future<bool> tryAutoLogin() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString(_keyAccessToken);
      final refreshToken = prefs.getString(_keyRefreshToken);

      if (_accessToken == null) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }

      // Verify the token by getting the profile
      try {
        final profileRes = await _authService.getProfile(_accessToken!);
        _user = profileRes['data']['user'];
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } catch (profileError) {
        debugPrint('[AuthProvider] Token verification failed: $profileError. Attempting token refresh...');
        
        // Access token might be expired. Try to refresh
        if (refreshToken != null) {
          try {
            final refreshRes = await _authService.refresh(refreshToken);
            final tokens = refreshRes['data']['tokens'];
            
            _accessToken = tokens['accessToken'];
            await prefs.setString(_keyAccessToken, _accessToken!);
            
            // Fetch profile again with new access token
            final profileRes = await _authService.getProfile(_accessToken!);
            _user = profileRes['data']['user'];
            _status = AuthStatus.authenticated;
            notifyListeners();
            return true;
          } catch (refreshError) {
            debugPrint('[AuthProvider] Refresh failed: $refreshError. Logging out.');
          }
        }
      }
    } catch (e) {
      debugPrint('[AuthProvider] Auto-login unexpected error: $e');
    }

    // Fallback if everything fails
    await _clearLocalSession();
    _status = AuthStatus.unauthenticated;
    notifyListeners();
    return false;
  }

  /// Register user
  Future<void> register({
    required String name,
    required String username,
    required String email,
    required String password,
    void Function()? onSuccess,
    void Function(String error)? onError,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.register(
        name: name,
        username: username,
        email: email,
        password: password,
      );

      final data = response['data'];
      _user = data['user'];
      _accessToken = data['tokens']['accessToken'];
      final refreshToken = data['tokens']['refreshToken'];

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyAccessToken, _accessToken!);
      await prefs.setString(_keyRefreshToken, refreshToken);

      _status = AuthStatus.authenticated;
      notifyListeners();
      
      if (onSuccess != null) onSuccess();
    } catch (error) {
      _errorMessage = error.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      
      if (onError != null) onError(_errorMessage!);
    }
  }

  /// Login user
  Future<void> login({
    required String emailOrUsername,
    required String password,
    void Function()? onSuccess,
    void Function(String error)? onError,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.login(
        emailOrUsername: emailOrUsername,
        password: password,
      );

      final data = response['data'];
      _user = data['user'];
      _accessToken = data['tokens']['accessToken'];
      final refreshToken = data['tokens']['refreshToken'];

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyAccessToken, _accessToken!);
      await prefs.setString(_keyRefreshToken, refreshToken);

      _status = AuthStatus.authenticated;
      notifyListeners();
      
      if (onSuccess != null) onSuccess();
    } catch (error) {
      _errorMessage = error.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      
      if (onError != null) onError(_errorMessage!);
    }
  }

  /// Update profile details
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? bio,
    String? country,
  }) async {
    if (_accessToken == null) return false;

    try {
      final response = await _authService.updateProfile(
        token: _accessToken!,
        name: name,
        phone: phone,
        bio: bio,
        country: country,
      );
      _user = response['data']['user'];
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[AuthProvider] Update Profile failed: $e');
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      if (_accessToken != null) {
        await _authService.logout(_accessToken!);
      }
    } catch (e) {
      debugPrint('[AuthProvider] Logout API call error (clearing locally anyway): $e');
    }

    await _clearLocalSession();
    _user = null;
    _accessToken = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  /// Clear SharedPreferences session keys
  Future<void> _clearLocalSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
  }
}
