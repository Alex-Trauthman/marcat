import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/home_controller.dart';
import '../controllers/auth_controller.dart';
import '../widgets/item_card.dart';
import 'edit_item_screen.dart';

/// Tela de Gestão de Publicações (Meus Anúncios)
class MyItemsScreen extends StatefulWidget {
  const MyItemsScreen({super.key});

  @override
  State<MyItemsScreen> createState() => _MyItemsScreenState();
}

class _MyItemsScreenState extends State<MyItemsScreen> {
  late String _userId;

  @override
  void initState() {
    super.initState();
    final authController = context.read<AuthController>();
    _userId = authController.userProfile?.id ?? '';
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_userId.isNotEmpty) {
        context.read<HomeController>().fetchUserItems(_userId);
      }
    });
  }

  Future<void> _refresh() async {
    if (_userId.isNotEmpty) {
      await context.read<HomeController>().fetchUserItems(_userId);
    }
  }

  void _navigateToEdit(BuildContext context, dynamic item) async {
    final homeController = context.read<HomeController>();
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EditItemScreen(item: item)),
    );
    if (updated == true && mounted) {
      _refresh();
      // Também atualiza o feed principal para manter tudo sincronizado
      homeController.fetchItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeController = context.watch<HomeController>();
    final items = homeController.userItems;
    final isLoading = homeController.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9DB),
      appBar: AppBar(
        title: const Text('Meus Anúncios', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFFFFF9DB),
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.black87))
            : RefreshIndicator(
                onRefresh: _refresh,
                color: Colors.black87,
                child: items.isEmpty
                    ? const SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 160, left: 32, right: 32),
                            child: Column(
                              children: [
                                Icon(Icons.storefront_outlined, size: 64, color: Colors.black38),
                                SizedBox(height: 16),
                                Text(
                                  'Você ainda não publicou nenhum anúncio.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16, color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return ItemCardWidget(
                            item: item,
                            onTap: () => _navigateToEdit(context, item),
                          );
                        },
                      ),
              ),
      ),
    );
  }
}
