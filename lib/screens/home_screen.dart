import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../widgets/carousel_widget.dart';
import '../widgets/item_card.dart';
import '../controllers/home_controller.dart';
import '../controllers/auth_controller.dart';
import 'details_screen.dart';
import 'login_screen.dart';
import 'create_item_screen.dart';
import 'edit_profile_screen.dart';

/// Tela principal do aplicativo (Home), refatorada para o padrão MVCS com Provider
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Inicia o carregamento dos itens ao abrir a tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeController>().fetchItems();
    });
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  void _logout(BuildContext context) async {
    await context.read<AuthController>().logout();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  Future<void> _goToEditProfile() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );
    // Se o usuário salvou alguma coisa, notifica o AuthController para atualizar a UI
    if (updated == true && mounted) {
      context.read<AuthController>().updateUI();
    }
  }

  void _showProfileMenu(BuildContext context) {
    final authController = context.read<AuthController>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  children: [
                    _buildAvatarWidget(context, radius: 28),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authController.userName ?? 'Usuário',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            authController.currentUser?.email ?? '',
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: Colors.black87),
                title: const Text('Editar Perfil'),
                onTap: () {
                  Navigator.pop(context);
                  _goToEditProfile();
                },
              ),
              ListTile(
                leading: const Icon(Icons.storefront_outlined, color: Colors.black87),
                title: const Text('Meus Anúncios'),
                onTap: () => Navigator.pop(context),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Sair', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _logout(context);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatarWidget(BuildContext context, {double radius = 18}) {
    final authController = context.watch<AuthController>();
    final avatarUrl = authController.avatarUrl;
    final userName = authController.userName;

    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;
    final initial = userName?.isNotEmpty == true ? userName![0].toUpperCase() : null;

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade300,
      backgroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
      child: !hasAvatar
          ? Text(
              initial ?? '',
              style: TextStyle(
                fontSize: radius * 0.8,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeController = context.watch<HomeController>();

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
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => _showProfileMenu(context),
              child: _buildAvatarWidget(context, radius: 18),
            ),
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
          if (index == 2) {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateItemScreen()),
            );
            if (result == true && mounted) {
              context.read<HomeController>().refreshItems();
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
            label: 'Anunciar',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Carrinho'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
        ],
      ),
      body: _buildBody(homeController),
    );
  }

  Widget _buildBody(HomeController controller) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.black87));
    }

    if (controller.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Erro ao carregar itens.'),
            TextButton(
              onPressed: controller.refreshItems,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (controller.items.isEmpty) {
      return RefreshIndicator(
        onRefresh: controller.refreshItems,
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

    return RefreshIndicator(
      onRefresh: controller.refreshItems,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Destaques'),
            CarouselWidget(
              items: controller.carouselItems,
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
              itemCount: controller.items.length,
              itemBuilder: (context, index) {
                return ItemCardWidget(
                  item: controller.items[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailsScreen(item: controller.items[index]),
                      ),
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