import 'package:supabase_flutter/supabase_flutter.dart';

class FavoriteService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Retorna os IDs dos itens favoritados pelo usuário logado
  Future<List<String>> fetchFavoriteItemIds() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final response = await _supabase
          .from('favorites')
          .select('item_id')
          .eq('user_id', user.id);

      return (response as List).map((row) => row['item_id'] as String).toList();
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
