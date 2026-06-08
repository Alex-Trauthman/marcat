import 'package:flutter/material.dart';
import '../models/item.dart';
import '../services/cart_service.dart';

class CartController extends ChangeNotifier {
  final CartService _cartService;

  CartController({CartService? cartService})
      : _cartService = cartService ?? CartService();

  List<Item> _cartItems = [];
  Set<String> _selectedCartItemIds = {}; // IDs dos itens selecionados para a compra
  bool _isLoading = false;
  String? _error;

  List<Item> get cartItems => _cartItems;
  Set<String> get selectedCartItemIds => _selectedCartItemIds;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Verifica se um item está no carrinho
  bool isInCart(String itemId) => _cartItems.any((item) => item.id == itemId);

  /// Verifica se um item do carrinho está selecionado
  bool isItemSelected(String itemId) => _selectedCartItemIds.contains(itemId);

  /// Calcula o preço total considerando apenas os itens selecionados (caixas marcadas)
  double get totalPrice {
    double total = 0.0;
    for (final item in _cartItems) {
      if (isItemSelected(item.id)) {
        total += item.price;
      }
    }
    return total;
  }

  /// Busca todos os itens no carrinho do Supabase
  Future<void> fetchCart() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cartItems = await _cartService.fetchCartItems();
      // Ao buscar o carrinho, selecionamos todos os itens por padrão
      _selectedCartItemIds = _cartItems.map((item) => item.id).toSet();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Adiciona um item ao carrinho
  Future<bool> addToCart(Item item, {String? currentUserId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    if (currentUserId != null && item.sellerId == currentUserId) {
      _error = 'Você não pode adicionar seu próprio item ao carrinho.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    try {
      await _cartService.addToCart(item.id);
      _cartItems.add(item);
      _selectedCartItemIds.add(item.id); // Seleciona automaticamente
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Remove um item do carrinho
  Future<bool> removeFromCart(String itemId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _cartService.removeFromCart(itemId);
      _cartItems.removeWhere((item) => item.id == itemId);
      _selectedCartItemIds.remove(itemId);
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Alterna a seleção de um item no carrinho
  void toggleItemSelection(String itemId) {
    if (_selectedCartItemIds.contains(itemId)) {
      _selectedCartItemIds.remove(itemId);
    } else {
      _selectedCartItemIds.add(itemId);
    }
    notifyListeners();
  }

  /// Seleciona ou desmarca todos os itens
  void toggleAllSelection(bool selectAll) {
    if (selectAll) {
      _selectedCartItemIds = _cartItems.map((item) => item.id).toSet();
    } else {
      _selectedCartItemIds.clear();
    }
    notifyListeners();
  }

  /// Limpa todos os itens do carrinho (simulação pós compra)
  Future<void> clearCart() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _cartService.clearCart();
      _cartItems.clear();
      _selectedCartItemIds.clear();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearLocal() {
    _cartItems.clear();
    _selectedCartItemIds.clear();
    _error = null;
    notifyListeners();
  }
}
