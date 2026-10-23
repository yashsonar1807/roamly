import 'package:flutter/foundation.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _service = NotificationService();

  List<dynamic> _notifications = [];
  List<dynamic> get notifications => _notifications;

  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchNotifications(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _notifications = await _service.getNotifications(token);
      await fetchUnreadCount(token); // Update count
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUnreadCount(String token) async {
    try {
      _unreadCount = await _service.getUnreadCount(token);
      notifyListeners();
    } catch (e) {
      // ignore
    }
  }

  Future<void> markAsRead(String token, String notificationId) async {
    try {
      final success = await _service.markAsRead(token, notificationId);
      if (success) {
        // Update locally
        final index = _notifications.indexWhere((n) => n['_id'] == notificationId);
        if (index != -1 && _notifications[index]['isRead'] == false) {
          _notifications[index]['isRead'] = true;
          _unreadCount = (_unreadCount > 0) ? _unreadCount - 1 : 0;
          notifyListeners();
        }
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> markAllAsRead(String token) async {
    try {
      final success = await _service.markAllAsRead(token);
      if (success) {
        for (var n in _notifications) {
          n['isRead'] = true;
        }
        _unreadCount = 0;
        notifyListeners();
      }
    } catch (e) {
      // ignore
    }
  }
}
