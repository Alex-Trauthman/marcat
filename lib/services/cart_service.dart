import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/item.dart';

class CartService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Retorna os itens adicionados ao carrinho pelo usuário logado
  Future<List<Item>> fetchCartItems() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final response = await _supabase
          .from('cart_items')
          .select('*, items(*)')
          .eq('user_id', user.id);

      final list = response as List;
      final List<Item> items = [];
      for (final row in list) {
        if (row['items'] != null) {
          items.add(Item.fromJson(row['items'] as Map<String, dynamic>));
        }
      }
      return items;
    } catch (e) {
      throw Exception('Erro ao buscar itens do carrinho: $e');
    }
  }

  /// Adiciona um item ao carrinho
  Future<void> addToCart(String itemId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado.');

    try {
      await _supabase.from('cart_items').insert({
        'user_id': user.id,
        'item_id': itemId,
      });
    } catch (e) {
      throw Exception('Erro ao adicionar item ao carrinho: $e');
    }
  }

  /// Remove um item do carrinho
  Future<void> removeFromCart(String itemId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado.');

    try {
      await _supabase
          .from('cart_items')
          .delete()
          .eq('user_id', user.id)
          .eq('item_id', itemId);
    } catch (e) {
      throw Exception('Erro ao remover item do carrinho: $e');
    }
  }

  /// Limpa o carrinho
  Future<void> clearCart() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado.');

    try {
      await _supabase
          .from('cart_items')
          .delete()
          .eq('user_id', user.id);
    } catch (e) {
      throw Exception('Erro ao limpar carrinho: $e');
    }
  }
}
