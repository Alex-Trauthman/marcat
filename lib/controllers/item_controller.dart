import 'dart:io';
import 'package:flutter/material.dart';
import '../services/item_service.dart';

class ItemController extends ChangeNotifier {
  final ItemService _itemService = ItemService();

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> createItem({
    required String title,
    required String description,
    required double price,
    required String condition,
    required String contactInfo,
    File? imageFile,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _itemService.createItem(
        title: title,
        description: description,
        price: price,
        condition: condition,
        contactInfo: contactInfo,
        imageFile: imageFile,
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
