import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Faz upload do avatar no bucket 'avatars' e retorna a URL pública
  Future<String> uploadAvatar(File imageFile) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado.');
  
    final fileExt = imageFile.path.split('.').last;
    final filePath = '${user.id}/avatar.$fileExt';
  
    try {
      await _supabase.storage
          .from('avatars')
          .upload(filePath, imageFile, fileOptions: const FileOptions(upsert: true));
  
      final publicUrl = _supabase.storage.from('avatars').getPublicUrl(filePath);
      return '$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}';
    } catch (e) {
      throw Exception('Erro ao subir foto de perfil: $e');
    }
  }

  /// Atualiza o perfil no user_metadata do Supabase Auth
  Future<void> updateProfile({
    required String fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    try {
      final data = <String, dynamic>{'full_name': fullName};
      if (phone != null) data['phone'] = phone;
      if (avatarUrl != null) data['avatar_url'] = avatarUrl;
  
      await _supabase.auth.updateUser(UserAttributes(data: data));
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Erro ao atualizar perfil: $e');
    }
  }
}
