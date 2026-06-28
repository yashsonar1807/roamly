import 'package:flutter/material.dart';
import '../services/post_service.dart';

class PostProvider extends ChangeNotifier {
  final PostService _postService = PostService();

  List<dynamic> _posts = [];
  List<dynamic> get posts => _posts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isFetchingMore = false;
  bool get isFetchingMore => _isFetchingMore;

  double _uploadProgress = 0.0;
  double get uploadProgress => _uploadProgress;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  /// Load feed posts from MongoDB (initial or refresh)
  Future<void> fetchPosts() async {
    _isLoading = true;
    _errorMessage = null;
    _currentPage = 1;
    _hasMore = true;
    notifyListeners();

    try {
      final result = await _postService.fetchPosts(page: _currentPage);
      _posts = result['posts'] ?? [];
      
      final pagination = result['pagination'] ?? {};
      _totalPages = pagination['totalPages'] ?? 1;
      _hasMore = pagination['hasMore'] ?? false;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch more posts (pagination)
  Future<void> fetchMorePosts() async {
    if (_isFetchingMore || !_hasMore) return;

    _isFetchingMore = true;
    notifyListeners();

    try {
      _currentPage++;
      final result = await _postService.fetchPosts(page: _currentPage);
      final newPosts = result['posts'] ?? [];
      
      _posts.addAll(newPosts);
      
      final pagination = result['pagination'] ?? {};
      _totalPages = pagination['totalPages'] ?? _totalPages;
      _hasMore = pagination['hasMore'] ?? false;
    } catch (e) {
      // Don't show major error on pagination failure, just stop fetching
      _hasMore = false;
    } finally {
      _isFetchingMore = false;
      notifyListeners();
    }
  }

  /// Create a new post with upload progress tracking
  Future<void> createPost({
    required String token,
    required String caption,
    required String location,
    List<int>? fileBytes,
    String? fileName,
    required VoidCallback onSuccess,
    required void Function(String) onError,
  }) async {
    _isLoading = true;
    _uploadProgress = 0.0;
    _errorMessage = null;
    notifyListeners();

    try {
      await _postService.createPost(
        token: token,
        caption: caption,
        location: location,
        fileBytes: fileBytes,
        fileName: fileName,
        onProgress: (sent, total) {
          if (total > 0) {
            _uploadProgress = sent / total;
            notifyListeners();
          }
        },
      );
      _uploadProgress = 1.0;
      notifyListeners();

      // Refresh feed posts to include the new one
      await fetchPosts();

      onSuccess();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      onError(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle like status optimistically
  Future<void> toggleLike(String token, String postId) async {
    // Find post index
    final index = _posts.indexWhere((p) => p['_id'] == postId);
    if (index == -1) return;

    final post = _posts[index];
    final bool currentlyLiked = post['isLiked'] ?? false;
    int likesCount = post['likesCount'] ?? 0;

    // Optimistic UI update
    post['isLiked'] = !currentlyLiked;
    post['likesCount'] = currentlyLiked ? (likesCount > 0 ? likesCount - 1 : 0) : likesCount + 1;
    notifyListeners();

    try {
      final result = await _postService.toggleLike(token: token, postId: postId);
      // Sync with server response
      post['isLiked'] = result['isLiked'];
      post['likesCount'] = result['likesCount'];
      notifyListeners();
    } catch (e) {
      // Revert optimistic update on error
      post['isLiked'] = currentlyLiked;
      post['likesCount'] = likesCount;
      notifyListeners();
    }
  }

  /// Delete a post
  Future<bool> deletePost(String token, String postId) async {
    try {
      await _postService.deletePost(token: token, postId: postId);
      // Remove from list
      _posts.removeWhere((p) => p['_id'] == postId);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Fetch comments for a post
  Future<List<dynamic>> fetchComments(String postId) async {
    try {
      return await _postService.fetchComments(postId);
    } catch (e) {
      return [];
    }
  }

  /// Create a comment
  Future<Map<String, dynamic>?> createComment(String token, String postId, String text) async {
    try {
      final comment = await _postService.createComment(token: token, postId: postId, text: text);
      
      // Update comment count
      final index = _posts.indexWhere((p) => p['_id'] == postId);
      if (index != -1) {
        _posts[index]['commentsCount'] = (_posts[index]['commentsCount'] ?? 0) + 1;
        notifyListeners();
      }
      return comment;
    } catch (e) {
      return null;
    }
  }

  /// Delete a comment
  Future<bool> deleteComment(String token, String postId, String commentId) async {
    try {
      await _postService.deleteComment(token: token, postId: postId, commentId: commentId);
      
      // Update comment count
      final index = _posts.indexWhere((p) => p['_id'] == postId);
      if (index != -1) {
        int count = _posts[index]['commentsCount'] ?? 0;
        _posts[index]['commentsCount'] = count > 0 ? count - 1 : 0;
        notifyListeners();
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}
