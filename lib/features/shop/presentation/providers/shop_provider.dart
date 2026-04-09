import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/network/api_client.dart';
import '../../data/models/product.dart';

class ShopProvider extends ChangeNotifier {
  List<Photo> _photos = [];
  List<Photo> get photos => _photos;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchPhotos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${ApiClient.photos}?_limit=40'),
        headers: {
          'User-Agent': 'Mozilla/5.0 (compatible; CalendarPlusApp/1.0)',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _photos = data.map((json) => Photo.fromJson(json)).toList();
      } else {
        _error = 'Failed to load photos: HTTP ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Failed to load photos. Please check your connection.';
    }

    _isLoading = false;
    notifyListeners();
  }
}
