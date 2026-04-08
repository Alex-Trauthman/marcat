import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Serviço responsável por gerenciar a autenticação usando Supabase
class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const _storage = FlutterSecureStorage();
  static const String _nameKey = 'user_name';

  /// Realiza o login usando Supabase
  Future<void> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        // Busca o nome do usuário dos metadados ou usa o email como fallback
        final name = response.user!.userMetadata?['full_name'] ?? email.split('@')[0];
        await _storage.write(key: _nameKey, value: name);
      }
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Erro inesperado no login: $e');
    }
  }

  /// Realiza o registro usando Supabase
  Future<void> register(String name, String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );
      
      if (response.user != null) {
        await _storage.write(key: _nameKey, value: name);
      }
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Erro inesperado no cadastro: $e');
    }
  }

  /// Remove a sessão (logout)
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
      await _storage.delete(key: _nameKey);
    } catch (e) {
      print('Erro no logout Supabase: $e');
    }
  }

  /// Verifica se o usuário tem uma sessão ativa checando o Supabase Auth
  Future<bool> isLoggedIn() async {
    final session = _supabase.auth.currentSession;
    return session != null;
  }

  Future<String?> getUserName() async {
    return await _storage.read(key: _nameKey);
  }
}
