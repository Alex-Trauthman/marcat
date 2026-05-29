import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/address.dart';

class AddressService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Retorna todos os endereços salvos do usuário autenticado
  Future<List<Address>> fetchAddresses() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado.');

    try {
      final response = await _supabase
          .from('addresses')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: true);

      return (response as List).map((json) => Address.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar endereços: $e');
    }
  }

  /// Adiciona um novo endereço para o usuário autenticado
  Future<Address> createAddress(Address address) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado.');

    try {
      final response = await _supabase
          .from('addresses')
          .insert(address.toJson())
          .select()
          .single();

      return Address.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao salvar endereço: $e');
    }
  }

  /// Exclui um endereço
  Future<void> deleteAddress(String id) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado.');

    try {
      await _supabase
          .from('addresses')
          .delete()
          .eq('id', id)
          .eq('user_id', user.id);
    } catch (e) {
      throw Exception('Erro ao excluir endereço: $e');
    }
  }
}
