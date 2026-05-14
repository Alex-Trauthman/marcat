import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/item_service.dart';

class HomeController extends ChangeNotifier {
  final ItemService _itemService = ItemService();

  List<Item> _items = [];
  bool _isLoading = false;
  String? _error;

  List<Item> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Item> get carouselItems => _items.take(3).toList();

  Future<void> fetchItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await _itemService.fetchItems();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshItems() async {
    await fetchItems();
  }
}
