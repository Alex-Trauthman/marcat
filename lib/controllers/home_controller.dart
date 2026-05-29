import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/item_service.dart';

class HomeController extends ChangeNotifier {
  final ItemService _itemService = ItemService();

  List<Item> _items = [];
  List<Item> _userItems = [];
  bool _isLoading = false;
  String? _error;

  List<Item> get items => _items;
  List<Item> get userItems => _userItems;
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

  /// Busca os anúncios criados pelo usuário logado
  Future<void> fetchUserItems(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _userItems = await _itemService.fetchItemsBySeller(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
