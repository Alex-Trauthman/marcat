import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import '../models/item.dart';

class ItemService {
  final SupabaseClient _supabase;
  final http.Client _httpClient;

  ItemService({SupabaseClient? supabaseClient, http.Client? httpClient})
      : _supabase = supabaseClient ?? Supabase.instance.client,
        _httpClient = httpClient ?? http.Client();

  /// Consulta o ViaCEP para buscar os detalhes do endereço
  Future<Map<String, dynamic>?> fetchAddressFromCep(String cep) async {
    try {
      final cleanCep = cep.replaceAll(RegExp(r'\D'), '');
      if (cleanCep.length != 8) return null;

      final url = Uri.parse('https://viacep.com.br/ws/$cleanCep/json/');
      final response = await _httpClient.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['erro'] == true) {
          return null;
        }
        return data; // Retorna o mapa contendo logradouro, bairro, localidade, uf
      }
    } catch (e) {
      debugPrint('Erro ao buscar CEP: $e');
    }
    return null;
  }

  /// Busca a lista de itens da tabela 'items' no Supabase
  Future<List<Item>> fetchItems() async {
    try {
      final response = await _supabase
          .from('items')
          .select()
          .order('created_at', ascending: false);

      final List itemsData = response;
      return itemsData.map((item) => Item.fromJson(item)).toList();
    } catch (e) {
      debugPrint('Erro ao buscar itens do Supabase: $e');
      return [];
    }
  }

  /// Busca itens postados exclusivamente por um usuário específico (para a área de Meus Anúncios)
  Future<List<Item>> fetchItemsBySeller(String sellerId) async {
    try {
      final response = await _supabase
          .from('items')
          .select()
          .eq('seller_id', sellerId)
          .order('created_at', ascending: false);

      final List itemsData = response;
      return itemsData.map((item) => Item.fromJson(item)).toList();
    } catch (e) {
      debugPrint('Erro ao buscar itens do usuário: $e');
      return [];
    }
  }

  /// Cria um novo item no Supabase com suporte a endereço completo
  Future<void> createItem({
    required String title,
    required String description,
    required double price,
    required String condition,
    required String contactInfo,
    File? imageFile,
    String? cep,
    String? street,
    String? neighborhood,
    String? city,
    String? state,
    String? number,
    String? complement,
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
        'cep': cep,
        'street': street,
        'neighborhood': neighborhood,
        'city': city,
        'state': state,
        'number': number,
        'complement': complement,
      });
    } catch (e) {
      debugPrint('Erro detalhado no ItemService (create): $e');
      rethrow;
    }
  }

  /// Atualiza um item existente no Supabase
  Future<void> updateItem({
    required String id,
    required String title,
    required String description,
    required double price,
    required String condition,
    required String contactInfo,
    File? imageFile,
    String? existingImageUrl,
    String? cep,
    String? street,
    String? neighborhood,
    String? city,
    String? state,
    String? number,
    String? complement,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado. Faça login novamente.');
      }

      String imageUrl = existingImageUrl ?? '';

      if (imageFile != null) {
        final fileExt = imageFile.path.split('.').last;
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
        final filePath = '${user.id}/$fileName';

        try {
          await _supabase.storage.from('product-images').upload(filePath, imageFile);
          imageUrl = _supabase.storage.from('product-images').getPublicUrl(filePath);
        } catch (storageError) {
          throw Exception('Erro ao subir nova imagem: $storageError');
        }
      }

      await _supabase.from('items').update({
        'title': title,
        'description': description,
        'price': price,
        'condition': condition,
        'contact_info': contactInfo,
        'image_url': imageUrl,
        'cep': cep,
        'street': street,
        'neighborhood': neighborhood,
        'city': city,
        'state': state,
        'number': number,
        'complement': complement,
      }).eq('id', id);
    } catch (e) {
      debugPrint('Erro detalhado no ItemService (update): $e');
      rethrow;
    }
  }

  /// Remove fisicamente um item da tabela 'items' no Supabase
  Future<void> deleteItem(String id) async {
    try {
      await _supabase.from('items').delete().eq('id', id);
    } catch (e) {
      debugPrint('Erro detalhado no ItemService (delete): $e');
      rethrow;
    }
  }
}
