import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/item.dart';
import '../controllers/favorite_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/auth_controller.dart';

/// Tela de detalhes que exibe nome, imagem grande, preço, descrição e contato de um único item
class DetailsScreen extends StatelessWidget {
  final Item item;

  const DetailsScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9DB),
      appBar: AppBar(
        title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFFFFF9DB),
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          Consumer<FavoriteController>(
            builder: (context, favoriteController, child) {
              final isFav = favoriteController.isFavorite(item.id);
              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : Colors.black87,
                ),
                onPressed: () => favoriteController.toggleFavorite(item),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animação Hero: cria uma transição suave da imagem do card direto para esta tela
            Hero(
              tag: 'image_${item.id}',
              child: item.imageUrl.isEmpty
                  ? Container(width: double.infinity, height: 320, color: Colors.grey[200], child: const Center(child: Icon(Icons.image_not_supported, size: 64, color: Colors.grey)))
                  : item.imageUrl.startsWith('http')
                      ? Image.network(
                          item.imageUrl,
                          width: double.infinity,
                          height: 320,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox(height: 320, child: Center(child: Icon(Icons.broken_image, size: 64))),
                        )
                      : Image.asset(
                          item.imageUrl,
                          width: double.infinity,
                          height: 320,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox(height: 320, child: Center(child: Icon(Icons.broken_image, size: 64))),
                        ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: item.isFree ? Colors.green.withValues(alpha: 0.1) : Colors.yellow.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.isFree ? 'Grátis' : 'R\$ ${item.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: item.isFree ? Colors.green[800] : Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Descrição',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Contato',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.phone, color: Colors.black54, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        item.contactInfo,
                        style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  if ((item.city != null && item.city!.isNotEmpty) || (item.cep != null && item.cep!.isNotEmpty)) ...[
                    const SizedBox(height: 32),
                    const Text(
                      'Localização',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on, color: Colors.black54, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            [
                              if (item.street != null && item.street!.isNotEmpty)
                                '${item.street}${item.number != null && item.number!.isNotEmpty ? ', ${item.number}' : ''}',
                              if (item.neighborhood != null && item.neighborhood!.isNotEmpty)
                                item.neighborhood!,
                              if (item.city != null && item.city!.isNotEmpty)
                                '${item.city}${item.state != null && item.state!.isNotEmpty ? ' - ${item.state}' : ''}',
                              if (item.cep != null && item.cep!.isNotEmpty)
                                'CEP: ${item.cep}',
                            ].join('\n'),
                            style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.4, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -4)),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Preço', style: TextStyle(fontSize: 12, color: Colors.black54)),
                  const SizedBox(height: 4),
                  Text(
                    item.isFree ? 'Grátis' : 'R\$ ${item.price.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Builder(
                  builder: (context) {
                    final currentUser = context.watch<AuthController>().userProfile;
                    final isOwnItem = currentUser != null && item.sellerId == currentUser.id;

                    if (isOwnItem) {
                      return ElevatedButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.person),
                        label: const Text('Seu Anúncio'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      );
                    }

                    return Consumer<CartController>(
                      builder: (context, cartController, child) {
                        final inCart = cartController.isInCart(item.id);
                        return ElevatedButton.icon(
                          onPressed: () async {
                            if (inCart) {
                              await cartController.removeFromCart(item.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Item removido do carrinho!'), backgroundColor: Colors.orange),
                                );
                              }
                            } else {
                              final success = await cartController.addToCart(item, currentUserId: currentUser?.id);
                              if (context.mounted) {
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Item adicionado ao carrinho!'), backgroundColor: Colors.green),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(cartController.error ?? 'Erro ao adicionar item ao carrinho.'), backgroundColor: Colors.red),
                                  );
                                }
                              }
                            }
                          },
                          icon: Icon(inCart ? Icons.remove_shopping_cart : Icons.add_shopping_cart),
                          label: Text(
                            inCart ? 'Remover do Carrinho' : 'Adicionar ao Carrinho',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: inCart ? Colors.red[700] : Colors.black87,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        );
                      },
                    );
                  }
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
