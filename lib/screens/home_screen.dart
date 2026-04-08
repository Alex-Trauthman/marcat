import 'package:flutter/material.dart';
import '../models/item.dart';
import '../widgets/carousel_widget.dart';
import '../widgets/item_card.dart';
import '../services/auth_service.dart';
import '../services/data_service.dart';
import 'details_screen.dart';
import 'login_screen.dart';
import 'create_item_screen.dart';

/// Tela principal do aplicativo (Home), onde os itens são exibidos no carrossel e no grid
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _dataService = DataService();
  final _authService = AuthService();
  late Future<List<Item>> _itemsFuture;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _itemsFuture = _dataService.fetchItems();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Lógica de navegação para outras abas viria aqui
  }

  void _logout(BuildContext context) async {
    await _authService.logout();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  Future<void> _refreshItems() async {
    setState(() {
      _itemsFuture = _dataService.fetchItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mar Cat',
          style: TextStyle(
            fontSize: 32, 
            fontWeight: FontWeight.bold, 
            fontFamily: 'Cursive',
            color: Colors.black87,
          ),
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black87,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        onTap: (index) async {
          if (index == 2) { // Botão de Anunciar (Index 2 agora)
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateItemScreen()),
            );
            if (result == true) {
              _refreshItems();
            }
          } else {
            _onItemTapped(index);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Favoritos'),
          BottomNavigationBarItem(
            icon: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 14,
              child: Icon(Icons.add, color: Colors.black87, size: 20),
            ), 
            label: 'Anunciar'
          ),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Carrinho'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
        ],
      ),
      body: FutureBuilder<List<Item>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.black87));
          } else if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar itens. Tente novamente mais tarde.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshItems,
              child: const SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: Text('Nenhum item disponível no momento.'),
                  ),
                ),
              ),
            );
          }

          final items = snapshot.data!;
          final carouselItems = items.take(3).toList();

          return RefreshIndicator(
            onRefresh: _refreshItems,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Destaques'),
                  CarouselWidget(
                    items: carouselItems,
                    onItemTap: (item) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DetailsScreen(item: item)),
                      );
                    },
                  ),
                  _buildSectionHeader('Mais Itens'),
                  GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: const Border(left: BorderSide(color: Colors.black87, width: 4)),
      ),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }
}
