import 'package:flutter/material.dart';
import '../services/trip_service.dart';

class TripProvider extends ChangeNotifier {
  final TripService _tripService = TripService();

  List<dynamic> _trips = [];
  List<dynamic> get trips => _trips;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Load user trips from database
  Future<void> fetchTrips(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _trips = await _tripService.fetchTrips(token);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new trip log in database
  Future<void> createTrip({
    required String token,
    required String title,
    required String destination,
    DateTime? startDate,
    DateTime? endDate,
    int? spotsCount,
    required String notes,
    double? budget,
    String? hotel,
    String? status,
    void Function()? onSuccess,
    void Function(String error)? onError,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _tripService.createTrip(
        token: token,
        title: title,
        destination: destination,
        
        
        spotsCount: spotsCount,
        notes: notes,
        
        
        
      );

      // Append new trip locally at index 0 for immediate UI response
      final newTrip = response['data']['trip'];
      _trips.insert(0, newTrip);
      
      _isLoading = false;
      notifyListeners();
      
      if (onSuccess != null) onSuccess();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      
      if (onError != null) onError(_errorMessage!);
    }
  }

  Future<void> updateTrip({
    required String token,
    required String id,
    String? title,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    int? spotsCount,
    String? notes,
    double? budget,
    String? hotel,
    String? status,
    void Function()? onSuccess,
    void Function(String error)? onError,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _tripService.updateTrip(
        token: token,
        id: id,
        title: title,
        destination: destination,
        
        
        spotsCount: spotsCount,
        notes: notes,
        
        
        
      );

      // Update locally
      final updatedTrip = response['data']['trip'];
      final index = _trips.indexWhere((t) => t['_id'] == id);
      if (index != -1) {
        _trips[index] = updatedTrip;
      }
      
      _isLoading = false;
      notifyListeners();
      
      if (onSuccess != null) onSuccess();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      
      if (onError != null) onError(_errorMessage!);
    }
  }

  Future<void> deleteTrip({
    required String token,
    required String id,
    void Function()? onSuccess,
    void Function(String error)? onError,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _tripService.deleteTrip(token: token, id: id);

      // Remove locally
      _trips.removeWhere((t) => t['_id'] == id);
      
      _isLoading = false;
      notifyListeners();
      
      if (onSuccess != null) onSuccess();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      
      if (onError != null) onError(_errorMessage!);
    }
  }
}
