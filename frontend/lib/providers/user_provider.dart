import 'package:flutter/material.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();

  List<dynamic> _searchResults = [];
  List<dynamic> get searchResults => _searchResults;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Search users and update state
  Future<void> searchUsers(String query) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _searchResults = await _userService.searchUsers(query);
    } catch (e) {
      _errorMessage = e.toString();
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search users directly without updating state (for SearchAnchor)
  Future<List<dynamic>> searchUsersDirect(String query) async {
    try {
      return await _userService.searchUsers(query);
    } catch (e) {
      return [];
    }
  }

  /// Toggle Follow User
  Future<bool> toggleFollow(String token, String targetUserId) async {
    try {
      final res = await _userService.toggleFollowUser(token, targetUserId);
      return res['isFollowing'] == true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Get Public Profile
  Future<Map<String, dynamic>?> getPublicProfile(String token, String targetUserId) async {
    try {
      final res = await _userService.getProfile(token, userId: targetUserId);
      if (res['success'] == true) {
        return res['data'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Clear search
  void clearSearch() {
    _searchResults = [];
    _errorMessage = null;
    notifyListeners();
  }
}
