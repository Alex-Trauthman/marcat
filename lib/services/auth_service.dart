import 'package:shared_preferences/shared_preferences.dart';

/// Serviço responsável por gerenciar a simulação de autenticação usando shared_preferences
class AuthService {
  // Chaves constantes usadas para salvar dados no armazenamento local
  static const String _tokenKey = 'user_token';
  static const String _nameKey = 'user_name';
  static const String _emailKey = 'user_email';
  static const String _passwordKey = 'user_password';

  /// Simula o processo de login verificando as credenciais presas localmente
  Future<bool> login(String email, String password) async {
    // Simula o tempo de espera de uma requisição real pela internet (1 segundo)
    await Future.delayed(const Duration(seconds: 1));
    
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString(_emailKey);
    final savedPassword = prefs.getString(_passwordKey);

    // Validação estrita do mock
    if (email.isNotEmpty && password.isNotEmpty && email == savedEmail && password == savedPassword) {
      await prefs.setString(_tokenKey, 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}');
      await prefs.setString(_nameKey, email.split('@')[0]);
      return true;
    }
    return false;
  }

  /// Simula o registro salvando as credenciais do novo usuário no armazenamento persistente do dispositivo
  Future<bool> register(String name, String email, String password) async {
    // Simula registro no backend
    await Future.delayed(const Duration(seconds: 1));
    
    if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}');
      await prefs.setString(_nameKey, name);
      await prefs.setString(_emailKey, email);
      await prefs.setString(_passwordKey, password);
      return true;
    }
    return false;
  }

  /// Remove a sessão (logout), apagando o token e o nome salvos localmente
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_nameKey);
  }

  /// Verifica se o usuário tem uma sessão ativa checando a existência do token
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return token != null && token.isNotEmpty;
  }

  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey);
  }
}
