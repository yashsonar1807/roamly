import 'package:flutter/material.dart';
import '../services/story_service.dart';

class StoryProvider extends ChangeNotifier {
  final StoryService _storyService = StoryService();

  List<dynamic> _stories = [];
  List<dynamic> get stories => _stories;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Load stories from MongoDB
  Future<void> fetchStories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _stories = await _storyService.fetchStories();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
