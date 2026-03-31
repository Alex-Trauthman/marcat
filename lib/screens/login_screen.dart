import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';

/// Tela de Login: Usa StatefulWidget porque a tela precisa se reconstruir para mostrar o "loading"
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Chave global usada para identificar e validar o formulário
  final _formKey = GlobalKey<FormState>();
  // Controladores que capturam o texto digitado nos campos
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  void _handleLogin() async {
    // Se o formulário não for válido (ex: e-mail sem @), interrompe a função
    if (!_formKey.currentState!.validate()) return;

    // Reconstrói a tela mostrando o indicador de carregamento
    setState(() => _isLoading = true);
    final success = await _authService.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    setState(() => _isLoading = false);

    if (success && mounted) {
      // Navega para a HomeScreen e destrói todo o histórico anterior para o usuário não voltar ao Login usando a seta de "voltar"
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } else if (mounted) {
      // Exibe uma notificação rápida (SnackBar) na parte inferior da tela caso o login falhe
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credenciais inválidas ou usuário não encontrado.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9DB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Mar Cat',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cursive',
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 48),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'O e-mail é obrigatório';
                            if (!value.contains('@')) return 'E-mail inválido, deve conter @';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'A senha é obrigatória';
                            if (value.length < 8) return 'A senha deve ter no mínimo 8 caracteres';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: _isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Entrar', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: const Text('Não tem uma conta? Crie uma', style: TextStyle(color: Colors.black87)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
