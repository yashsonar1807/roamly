import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class JourneyProvider extends ChangeNotifier {
  List<dynamic> _journeys = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get journeys => _journeys;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchJourneys({String search = '', String minRating = ''}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final queryParams = <String, String>{};
      if (search.isNotEmpty) queryParams['search'] = search;
      if (minRating.isNotEmpty) queryParams['minRating'] = minRating;

      final uri = Uri.http(ApiConfig.baseDomain, '/api/v1/journeys', queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _journeys = data['data']['journeys'];
      } else {
        _error = 'Failed to load journeys';
      }
    } catch (e) {
      _error = 'Error connecting to server';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
