import 'dart:io';
import 'package:flutter/material.dart';
import '../services/profile_service.dart';
import '../services/auth_service.dart';

class ProfileController extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> updateProfile({
    required String fullName,
    String? phone,
    File? avatarFile,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String? avatarUrl;
      
      if (avatarFile != null) {
        avatarUrl = await _profileService.uploadAvatar(avatarFile);
      }

      await _authService.updateProfile(
        fullName: fullName,
        phone: phone,
        avatarUrl: avatarUrl,
      );
      
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
