import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isAuthenticated = false;
  String? _error;

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  String? get error => _error;

  AuthProvider() {
    _loadUserFromPreferences();
  }

  Future<void> _loadUserFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('user');
    if (userDataString != null) {
      try {
        _user = User.fromJson(json.decode(userDataString));
        _isAuthenticated = true;
      } catch (e) {
        // Handle error decoding user from shared_preferences
        print("Error loading user from prefs: $e");
        await prefs.remove('user'); // Clear corrupted data
        _user = null;
        _isAuthenticated = false;
      }
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _error = null; // Clear previous errors
    try {
      final apiService = ApiService();
      // ApiService.login already returns a User object
      final User loggedInUser = await apiService.login(email, password);
      
      _user = loggedInUser;
      _isAuthenticated = true;

      final prefs = await SharedPreferences.getInstance();
      // Ensure _user is not null before calling toJson, though it should be after successful login
      if (_user != null) {
        await prefs.setString('user', json.encode(_user!.toJson()));
      } else {
        // This case should ideally not be reached if login was successful
        throw Exception("Login succeeded but user data is null.");
      }
      notifyListeners();
    } catch (e) {
      _user = null;
      _isAuthenticated = false;
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      rethrow; 
    }
  }

  Future<void> logout() async {
    _user = null;
    _isAuthenticated = false;
    _error = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
