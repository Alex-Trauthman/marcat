import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';

// Função principal que inicializa o aplicativo Flutter
void main() async {
  // Garante que a ligação com o motor do Flutter esteja pronta antes de chamar código assíncrono
  WidgetsFlutterBinding.ensureInitialized();
  
  // Carrega as variáveis de ambiente do arquivo .env
  await dotenv.load(fileName: ".env");

  // Inicializa o Supabase usando as chaves do arquivo .env
  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL', fallback: 'YOUR_SUPABASE_URL'),
    anonKey: dotenv.get('SUPABASE_ANON_KEY', fallback: 'YOUR_SUPABASE_ANON_KEY'),
  );

  // Instancia o serviço de autenticação para verificar se o usuário já tem uma sessão salva
  final authService = AuthService();
  final isLoggedIn = await authService.isLoggedIn();

  // Inicia o widget raiz do aplicativo, passando o estado de login
  runApp(MarCatApp(isLoggedIn: isLoggedIn));
}

class MarCatApp extends StatelessWidget {
  final bool isLoggedIn;
  
  const MarCatApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    // MaterialApp é o widget principal que provê o design padrão do Material Design e gerencia a navegação
    return MaterialApp(
      title: 'Mar Cat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFFF9DB), primary: Colors.black87),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFF9DB),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black87),
        ),
      ),
      // Define a tela inicial: se o usuário estiver logado, vai direto para a HomeScreen, senão exibe a LoginScreen
      home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}
