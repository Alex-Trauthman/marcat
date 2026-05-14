import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  String? _error;
  UserProfile? _userProfile;

  bool get isLoading => _isLoading;
  String? get error => _error;
  UserProfile? get userProfile => _userProfile;

  AuthController() {
    _updateUserProfile();
  }

  void _updateUserProfile() {
    final user = _authService.currentUser;
    if (user != null) {
      _userProfile = UserProfile.fromSupabase(
        user.userMetadata ?? {},
        user.id,
        user.email ?? '',
      );
    } else {
      _userProfile = null;
    }
  }

  String? get userName => _userProfile?.fullName;
  String? get avatarUrl => _userProfile?.avatarUrl;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.login(email, password);
      _updateUserProfile();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.register(name, email, password);
      _updateUserProfile();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _userProfile = null;
    notifyListeners();
  }

  void refreshUser() {
    _updateUserProfile();
    notifyListeners();
  }
}
