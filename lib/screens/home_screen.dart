import 'package:flutter/material.dart';
import '../data/local_service.dart';
import '../widgets/carousel_widget.dart';
import '../widgets/item_card.dart';
import '../services/auth_service.dart';
import 'details_screen.dart';
import 'login_screen.dart';

/// Tela principal do aplicativo (Home), onde os itens são exibidos no carrossel e no grid
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _logout(BuildContext context) async {
    await AuthService().logout(); // Apaga a sessão local
    if (context.mounted) {
      // Navega para o Login e retira a tela atual da pilha de navegação
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = LocalService.mockItems;
    final carouselItems = items.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mar Cat',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600, letterSpacing: 1.2),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFFFF9DB),
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Sair',
          ),
        ],
      ),
      backgroundColor: const Color(0xFFFFF9DB),
      // Permite rolar a tela caso os itens ultrapassem o limite de altura do dispositivo
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Destaques',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            CarouselWidget(
              items: carouselItems,
              onItemTap: (item) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DetailsScreen(item: item)),
                );
              },
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'Mais Itens',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            // Constrói uma grade de itens dinamicamente
            GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shrinkWrap: true, // Ocupa apenas o espaço necessário, permitindo usar dentro do SingleChildScrollView
              physics: const NeverScrollableScrollPhysics(), // Desativa o scroll próprio da grade, delegando ao SingleChildScrollView
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ItemCardWidget(
                  item: items[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DetailsScreen(item: items[index])),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
