import 'package:flutter/material.dart';
import '../services/destination_service.dart';

class DestinationProvider extends ChangeNotifier {
  final DestinationService _destinationService = DestinationService();

  List<dynamic> _destinations = [];
  List<dynamic> get destinations => _destinations;

  // Pagination states
  int _currentPage = 1;
  int get currentPage => _currentPage;

  int _totalPages = 1;
  int get totalPages => _totalPages;

  int _totalResults = 0;
  int get totalResults => _totalResults;

  final int _limit = 6;
  int get limit => _limit;

  // Filtering states
  String _searchQuery = "";
  String get searchQuery => _searchQuery;

  String _selectedCategory = "All";
  String get selectedCategory => _selectedCategory;

  double? _minRating;
  double? get minRating => _minRating;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      _currentPage = 1;
      notifyListeners();
    }
  }

  void setSelectedCategory(String category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      _currentPage = 1;
      notifyListeners();
    }
  }

  void setMinRating(double? rating) {
    if (_minRating != rating) {
      _minRating = rating;
      _currentPage = 1;
      notifyListeners();
    }
  }

  void setPage(int page) {
    if (page >= 1 && page <= _totalPages && page != _currentPage) {
      _currentPage = page;
      fetchDestinations(usePaginationFilters: true);
    }
  }

  void resetFilters() {
    _searchQuery = "";
    _selectedCategory = "All";
    _minRating = null;
    _currentPage = 1;
    notifyListeners();
  }

  /// Fetch destinations from MongoDB
  /// If usePaginationFilters is false, we fetch a large limit (e.g. 20) with no filters (for home screen)
  Future<void> fetchDestinations({bool usePaginationFilters = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _destinationService.fetchDestinations(
        search: usePaginationFilters ? _searchQuery : null,
        category: usePaginationFilters ? _selectedCategory : null,
        minRating: usePaginationFilters ? _minRating : null,
        page: usePaginationFilters ? _currentPage : 1,
        limit: usePaginationFilters ? _limit : 20, // Load all for home screen
      );

      _destinations = result['destinations'] ?? [];
      if (usePaginationFilters) {
        final pag = result['pagination'] ?? {};
        _currentPage = pag['page'] ?? 1;
        _totalPages = pag['pages'] ?? 1;
        _totalResults = pag['total'] ?? 0;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
