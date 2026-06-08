import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/favorite_service.dart';

class FavoriteController extends ChangeNotifier {
  final FavoriteService _favoriteService;

  FavoriteController({FavoriteService? favoriteService})
      : _favoriteService = favoriteService ?? FavoriteService();

  List<Item> _favoriteItems = [];
  Set<String> _favoriteItemIds = {};
  bool _isLoading = false;
  String? _error;

  List<Item> get favoriteItems => _favoriteItems;
  Set<String> get favoriteItemIds => _favoriteItemIds;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Verifica se um item está favoritado
  bool isFavorite(String itemId) => _favoriteItemIds.contains(itemId);

  /// Busca todos os IDs favoritos do usuário logado
  Future<void> fetchFavorites() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _favoriteItems = await _favoriteService.fetchFavoriteItems();
      _favoriteItemIds = _favoriteItems.map((item) => item.id).toSet();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Alterna o estado de favorito de um item
  Future<void> toggleFavorite(Item item) async {
    _error = null;
    final itemId = item.id;

    if (isFavorite(itemId)) {
      // Remove localmente primeiro (Optimistic UI)
      _favoriteItemIds.remove(itemId);
      _favoriteItems.removeWhere((i) => i.id == itemId);
      notifyListeners();

      try {
        await _favoriteService.removeFavorite(itemId);
      } catch (e) {
        // Rollback se falhar
        _favoriteItemIds.add(itemId);
        _favoriteItems.add(item);
        _error = e.toString().replaceAll('Exception: ', '');
        notifyListeners();
      }
    } else {
      // Adiciona localmente primeiro (Optimistic UI)
      _favoriteItemIds.add(itemId);
      _favoriteItems.add(item);
      notifyListeners();

      try {
        await _favoriteService.addFavorite(itemId);
      } catch (e) {
        // Rollback se falhar
        _favoriteItemIds.remove(itemId);
        _favoriteItems.removeWhere((i) => i.id == itemId);
        _error = e.toString().replaceAll('Exception: ', '');
        notifyListeners();
      }
    }
  }

  void clearLocal() {
    _favoriteItems.clear();
    _favoriteItemIds.clear();
    _error = null;
    notifyListeners();
  }
}
