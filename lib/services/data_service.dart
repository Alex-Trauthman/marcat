import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../models/item.dart';

class DataService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Busca a lista de itens da tabela 'items' no Supabase
  Future<List<Item>> fetchItems() async {
    try {
      final response = await _supabase
          .from('items')
          .select()
          .order('created_at', ascending: false);

      if ((response as List).isEmpty) {
        return []; // Retorna lista vazia se não houver itens no banco
      }

      final List itemsData = response;
      return itemsData.map((item) => Item.fromJson(item)).toList();
    } catch (e) {
      print('Erro ao buscar itens do Supabase: $e');
      return []; // Retorna vazio em caso de erro real
    }
  }

  /// Cria um novo item no Supabase
  Future<void> createItem({
    required String title,
    required String description,
    required double price,
    required String condition,
    required String contactInfo,
    File? imageFile,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado. Faça login novamente.');
      }

      String imageUrl = 'https://xonghjzfmktcasplbjcu.supabase.co/storage/v1/object/public/product-images/livros.jpg'; 

      if (imageFile != null) {
        final fileExt = imageFile.path.split('.').last;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        final filePath = '${user.id}/$fileName';

        try {
          await _supabase.storage.from('product-images').upload(filePath, imageFile);
          imageUrl = _supabase.storage.from('product-images').getPublicUrl(filePath);
        } catch (storageError) {
          throw Exception('Erro ao subir imagem: $storageError');
        }
      }

      await _supabase.from('items').insert({
        'title': title,
        'description': description,
        'price': price,
        'condition': condition,
        'contact_info': contactInfo,
        'image_url': imageUrl,
        'seller_id': user.id,
      });
    } catch (e) {
      print('Erro detalhado no DataService: $e');
      rethrow; // Repassa o erro para a UI tratar
    }
  }
}
