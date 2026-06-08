import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/item.dart';

class FavoriteService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Retorna os itens favoritados pelo usuário logado
  Future<List<Item>> fetchFavoriteItems() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final response = await _supabase
          .from('favorites')
          .select('*, items(*)')
          .eq('user_id', user.id);

      final list = response as List;
      final List<Item> items = [];
      for (final row in list) {
        var itemData = row['items'];
        if (itemData is List && itemData.isNotEmpty) {
          itemData = itemData.first;
        }
        if (itemData is Map<String, dynamic>) {
          items.add(Item.fromJson(itemData));
        }
      }
      return items;
    } catch (e) {
      throw Exception('Erro ao buscar favoritos: $e');
    }
  }

  /// Adiciona um item aos favoritos
  Future<void> addFavorite(String itemId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado.');

    try {
      await _supabase.from('favorites').insert({
        'user_id': user.id,
        'item_id': itemId,
      });
    } catch (e) {
      throw Exception('Erro ao favoritar item: $e');
    }
  }

  /// Remove um item dos favoritos
  Future<void> removeFavorite(String itemId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado.');

    try {
      await _supabase
          .from('favorites')
          .delete()
          .eq('user_id', user.id)
          .eq('item_id', itemId);
    } catch (e) {
      throw Exception('Erro ao desfavoritar item: $e');
    }
  }
}
