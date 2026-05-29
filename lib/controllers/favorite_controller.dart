import 'package:flutter/material.dart';
import '../services/favorite_service.dart';

class FavoriteController extends ChangeNotifier {
  final FavoriteService _favoriteService;

  FavoriteController({FavoriteService? favoriteService})
      : _favoriteService = favoriteService ?? FavoriteService();

  Set<String> _favoriteItemIds = {};
  bool _isLoading = false;
  String? _error;

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
      final ids = await _favoriteService.fetchFavoriteItemIds();
      _favoriteItemIds = ids.toSet();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Alterna o estado de favorito de um item
  Future<void> toggleFavorite(String itemId) async {
    _error = null;

    if (isFavorite(itemId)) {
      // Remove localmente primeiro (Optimistic UI)
      _favoriteItemIds.remove(itemId);
      notifyListeners();

      try {
        await _favoriteService.removeFavorite(itemId);
      } catch (e) {
        // Rollback se falhar
        _favoriteItemIds.add(itemId);
        _error = e.toString().replaceAll('Exception: ', '');
        notifyListeners();
      }
    } else {
      // Adiciona localmente primeiro (Optimistic UI)
      _favoriteItemIds.add(itemId);
      notifyListeners();

      try {
        await _favoriteService.addFavorite(itemId);
      } catch (e) {
        // Rollback se falhar
        _favoriteItemIds.remove(itemId);
        _error = e.toString().replaceAll('Exception: ', '');
        notifyListeners();
      }
    }
  }
}
